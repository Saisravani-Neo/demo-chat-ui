import 'package:agora_chat_sdk/agora_chat_sdk.dart';

import '../../data/models/agora_chat_token_model.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/message_record_model.dart';
import '../../data/models/rtc_token_model.dart';

abstract class ChatRepository {
  Future<AgoraChatTokenModel> getAgoraChatToken();

  Future<void> loginAgoraChat({
    required String agoraUserId,
    required String token,
  });

  Future<List<ConversationModel>> getConversations();

  Future<ConversationModel> createConversation({
    required String receiverId,
  });

  Future<MessageRecordModel> sendTextMessage({
    required String conversationId,
    required String receiverId,
    required String receiverAgoraUserId,
    required String text,
  });

  Future<MessageRecordModel> sendVoiceMessage({
    required String conversationId,
    required String receiverId,
    required String receiverAgoraUserId,
    required String filePath,
    required int duration,
  });

  Stream<ChatMessage> incomingMessages();

  Future<void> createGroup({
    required String name,
    required List<String> memberIds,
  });

  Future<RtcTokenModel> getRtcToken({
    required String receiverId,
  });

  Future<void> endCall({
    required String callId,
    required String status,
    required int durationSeconds,
  });
}