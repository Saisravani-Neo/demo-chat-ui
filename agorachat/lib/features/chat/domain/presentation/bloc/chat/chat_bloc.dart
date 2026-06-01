import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../usecase/send_text_message_usecase.dart';
import '../../../usecase/send_voice_message_usecase.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendTextMessageUseCase sendTextMessageUseCase;
  final SendVoiceMessageUseCase sendVoiceMessageUseCase;

  ChatBloc({
    required this.sendTextMessageUseCase,
    required this.sendVoiceMessageUseCase,
  }) : super(ChatInitial()) {
    on<SendTextMessageEvent>(_onSendText);
    on<SendVoiceMessageEvent>(_onSendVoice);
  }

  Future<void> _onSendText(
    SendTextMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatSending());

      final message = await sendTextMessageUseCase(
        conversationId: event.conversationId,
        receiverId: event.receiverId,
        receiverAgoraUserId: event.receiverAgoraUserId,
        text: event.text,
      );

      emit(ChatMessageSent(message));
    } catch (e) {
      emit(ChatFailure(e.toString()));
    }
  }

  Future<void> _onSendVoice(
    SendVoiceMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatSending());

      final message = await sendVoiceMessageUseCase(
        conversationId: event.conversationId,
        receiverId: event.receiverId,
        receiverAgoraUserId: event.receiverAgoraUserId,
        filePath: event.filePath,
        duration: event.duration,
      );

      emit(ChatMessageSent(message));
    } catch (e) {
      emit(ChatFailure(e.toString()));
    }
  }
}