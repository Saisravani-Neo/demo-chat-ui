import 'dart:async';
import 'package:agora_chat_sdk/agora_chat_sdk.dart'
    hide MessageType, MessageDirection;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'chat_event.dart';
import 'chat_state.dart';
import '../model/chat_message_model.dart';
import '../repository/chat_repository.dart';
import '../../../core/storage/local_storage.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({
    required this.repository,
    required this.receiverId,
  }) : super(const ChatInitial()) {
    on<ChatInitialized>(_onInitialized);
    on<ChatTextSent>(_onTextSent);
    on<ChatRecordingStarted>(_onRecordingStarted);
    on<ChatRecordingStopped>(_onRecordingStopped);
    on<ChatMessageReceived>(_onMessageReceived);
    on<ChatVoicePlayToggled>(_onVoicePlayToggled);
    on<ChatReadReceiptReceived>(_onReadReceiptReceived);
  }

  final ChatRepository repository;
  final String receiverId;

  final AudioRecorder _recorder = AudioRecorder();
  String? _currentRecordingPath;

  // ─── Init ──────────────────────────────────────────────────────────────────

  Future<void> _onInitialized(
    ChatInitialized event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatConnecting());

    try {
      await repository.login();

      // Register incoming-message and read receipt listeners
      ChatClient.getInstance.chatManager.addEventHandler(
        'chat_bloc_listener',
        ChatEventHandler(
          onMessagesReceived: (messages) {
            for (final msg in messages) {
              _handleIncomingMessage(msg);
            }
          },
          onConversationRead: (from, to) {
            if (from == receiverId) {
              add(const ChatReadReceiptReceived());
            }
          },
          onMessagesRead: (messages) {
            add(const ChatReadReceiptReceived());
          },
        ),
      );

      final history = await repository.fetchHistory(event.receiverId);
      await repository.markAsRead(event.receiverId);
      emit(ChatReady(messages: history));
    } catch (e) {
      emit(ChatFailure(message: e.toString()));
    }
  }

  void _handleIncomingMessage(ChatMessage msg) {
    final body = msg.body;

    ChatMessageModel? model;

    final isSent = msg.from?.toLowerCase() == LocalStorage.userId?.toLowerCase();
    final direction = isSent ? MessageDirection.sent : MessageDirection.received;

    if (body is ChatTextMessageBody) {
      model = ChatMessageModel(
        messageId: msg.msgId,
        content: body.content,
        type: MessageType.text,
        direction: direction,
        timestamp: DateTime.fromMillisecondsSinceEpoch(msg.serverTime),
        hasRead: msg.hasRead,
        hasReadAck: msg.hasReadAck,
      );
    } else if (body is ChatVoiceMessageBody) {
      model = ChatMessageModel(
        messageId: msg.msgId,
        content: body.remotePath ?? '',
        type: MessageType.voice,
        direction: direction,
        timestamp: DateTime.fromMillisecondsSinceEpoch(msg.serverTime),
        voiceDuration: body.duration,
        localPath: body.localPath,
        hasRead: msg.hasRead,
        hasReadAck: msg.hasReadAck,
      );
    }

    if (model != null) {
      add(ChatMessageReceived(message: model));
    }
  }

  // ─── Send text ─────────────────────────────────────────────────────────────

  Future<void> _onTextSent(
    ChatTextSent event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    if (current is! ChatReady) return;

    emit(current.copyWith(isSending: true, clearError: true));

    try {
      final sdkMsg = await repository.sendTextMessage(
        receiverId: receiverId,
        text: event.text,
      );

      final newMsg = ChatMessageModel(
        messageId: sdkMsg.msgId,
        content: event.text,
        type: MessageType.text,
        direction: MessageDirection.sent,
        timestamp: DateTime.now(),
      );

      emit(current.copyWith(
        messages: [...current.messages, newMsg],
        isSending: false,
      ));
    } catch (e) {
      emit(current.copyWith(isSending: false, error: e.toString()));
    }
  }

  // ─── Voice recording ───────────────────────────────────────────────────────

  Future<void> _onRecordingStarted(
    ChatRecordingStarted event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    if (current is! ChatReady || current.isRecording) return;

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      emit(current.copyWith(error: 'Microphone permission denied.'));
      return;
    }

    final dir = await getTemporaryDirectory();
    _currentRecordingPath =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: _currentRecordingPath!,
    );

    emit(current.copyWith(isRecording: true));
  }

  Future<void> _onRecordingStopped(
    ChatRecordingStopped event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    if (current is! ChatReady || !current.isRecording) return;

    emit(current.copyWith(isRecording: false, isSending: true));

    try {
      final recordStart = DateTime.now();
      final path = await _recorder.stop();

      if (path == null) {
        emit(current.copyWith(isRecording: false, isSending: false));
        return;
      }

      final durationSecs =
          DateTime.now().difference(recordStart).inSeconds.clamp(1, 60);

      final sdkMsg = await repository.sendVoiceMessage(
        receiverId: receiverId,
        filePath: path,
        durationSeconds: durationSecs,
      );

      final newMsg = ChatMessageModel(
        messageId: sdkMsg.msgId,
        content: path,
        type: MessageType.voice,
        direction: MessageDirection.sent,
        timestamp: DateTime.now(),
        voiceDuration: durationSecs,
        localPath: path,
      );

      emit(current.copyWith(
        messages: [...current.messages, newMsg],
        isSending: false,
      ));
    } catch (e) {
      emit(current.copyWith(isSending: false, error: e.toString()));
    }
  }

  // ─── Incoming message ──────────────────────────────────────────────────────

  void _onMessageReceived(
    ChatMessageReceived event,
    Emitter<ChatState> emit,
  ) {
    final current = state;
    if (current is! ChatReady) return;

    // Mark conversation read in local db and send ack to peer
    repository.markAsRead(receiverId);

    // Show message as read in our UI immediately
    final messageWithRead = event.message.copyWith(hasRead: true);

    emit(current.copyWith(messages: [...current.messages, messageWithRead]));
  }

  // ─── Voice playback toggle (UI state only) ─────────────────────────────────

  void _onVoicePlayToggled(
    ChatVoicePlayToggled event,
    Emitter<ChatState> emit,
  ) {
    final current = state;
    if (current is! ChatReady) return;

    final updated = current.messages.map((m) {
      if (m.messageId == event.messageId) {
        return m.copyWith(isPlaying: !m.isPlaying);
      }
      // Stop any other voice message that was playing
      return m.type == MessageType.voice ? m.copyWith(isPlaying: false) : m;
    }).toList();

    emit(current.copyWith(messages: updated));
  }

  // ─── Read receipt received ──────────────────────────────────────────────────

  void _onReadReceiptReceived(
    ChatReadReceiptReceived event,
    Emitter<ChatState> emit,
  ) {
    final current = state;
    if (current is! ChatReady) return;

    final updated = current.messages.map((m) {
      if (m.isSent) {
        return m.copyWith(hasReadAck: true);
      }
      return m;
    }).toList();

    emit(current.copyWith(messages: updated));
  }

  // ─── Dispose ───────────────────────────────────────────────────────────────

  @override
  Future<void> close() async {
    ChatClient.getInstance.chatManager.removeEventHandler('chat_bloc_listener');
    await _recorder.dispose();
    await repository.logout();
    return super.close();
  }
}
