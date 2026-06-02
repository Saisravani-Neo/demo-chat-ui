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

      // Register incoming-message listener
      ChatClient.getInstance.chatManager.addEventHandler(
        'chat_bloc_listener',
        ChatEventHandler(
          onMessagesReceived: (messages) {
            for (final msg in messages) {
              _handleIncomingMessage(msg);
            }
          },
        ),
      );

      final history = await repository.fetchHistory(event.receiverId);
      emit(ChatReady(messages: history));
    } catch (e) {
      emit(ChatFailure(message: e.toString()));
    }
  }

  void _handleIncomingMessage(ChatMessage msg) {
    final body = msg.body;

    ChatMessageModel? model;

    if (body is ChatTextMessageBody) {
      model = ChatMessageModel(
        messageId: msg.msgId,
        content: body.content,
        type: MessageType.text,
        direction: MessageDirection.received,
        timestamp: DateTime.fromMillisecondsSinceEpoch(msg.serverTime),
      );
    } else if (body is ChatVoiceMessageBody) {
      model = ChatMessageModel(
        messageId: msg.msgId,
        content: body.remotePath ?? '',
        type: MessageType.voice,
        direction: MessageDirection.received,
        timestamp: DateTime.fromMillisecondsSinceEpoch(msg.serverTime),
        voiceDuration: body.duration,
        localPath: body.localPath,
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

    emit(current.copyWith(messages: [...current.messages, event.message]));
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

  // ─── Dispose ───────────────────────────────────────────────────────────────

  @override
  Future<void> close() async {
    ChatClient.getInstance.chatManager.removeEventHandler('chat_bloc_listener');
    await _recorder.dispose();
    await repository.logout();
    return super.close();
  }
}
