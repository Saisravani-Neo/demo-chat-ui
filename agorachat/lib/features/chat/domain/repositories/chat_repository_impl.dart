import 'package:agora_chat_sdk/agora_chat_sdk.dart';

import 'chat_repository.dart';
import '../../data/datasource/chat_remote_datasource.dart';
import '../../data/models/agora_chat_token_model.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/message_record_model.dart';
import '../../data/models/rtc_token_model.dart';
import '../../data/services/agora_chat_service.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final AgoraChatService agoraChatService;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.agoraChatService,
  });

  @override
  Future<AgoraChatTokenModel> getAgoraChatToken() {
    return remoteDataSource.getAgoraChatToken();
  }

  @override
  Future<void> loginAgoraChat({
    required String agoraUserId,
    required String token,
  }) {
    return agoraChatService.login(
      agoraUserId: agoraUserId,
      token: token,
    );
  }

  @override
  Future<List<ConversationModel>> getConversations() {
    return remoteDataSource.getConversations();
  }

  @override
  Future<ConversationModel> createConversation({
    required String receiverId,
  }) {
    return remoteDataSource.createConversation(receiverId: receiverId);
  }

  @override
  Future<MessageRecordModel> sendTextMessage({
    required String conversationId,
    required String receiverId,
    required String receiverAgoraUserId,
    required String text,
  }) async {
    final message = await agoraChatService.sendTextMessage(
      receiverAgoraUserId: receiverAgoraUserId,
      text: text,
    );

    return remoteDataSource.saveMessage(
      conversationId: conversationId,
      receiverId: receiverId,
      messageType: 'TEXT',
      content: text,
      agoraMessageId: message.msgId,
      status: 'SENT',
    );
  }

  @override
  Future<MessageRecordModel> sendVoiceMessage({
    required String conversationId,
    required String receiverId,
    required String receiverAgoraUserId,
    required String filePath,
    required int duration,
  }) async {
    final message = await agoraChatService.sendVoiceMessage(
      receiverAgoraUserId: receiverAgoraUserId,
      filePath: filePath,
      duration: duration,
    );

    return remoteDataSource.saveMessage(
      conversationId: conversationId,
      receiverId: receiverId,
      messageType: 'VOICE',
      content: filePath,
      agoraMessageId: message.msgId,
      status: 'SENT',
    );
  }

  @override
  Stream<ChatMessage> incomingMessages() {
    return agoraChatService.messageStream;
  }

  @override
  Future<void> createGroup({
    required String name,
    required List<String> memberIds,
  }) {
    return remoteDataSource.createGroup(
      name: name,
      memberIds: memberIds,
    );
  }

  @override
  Future<RtcTokenModel> getRtcToken({
    required String receiverId,
  }) {
    return remoteDataSource.getRtcToken(receiverId: receiverId);
  }

  @override
  Future<void> endCall({
    required String callId,
    required String status,
    required int durationSeconds,
  }) {
    return remoteDataSource.endCall(
      callId: callId,
      status: status,
      durationSeconds: durationSeconds,
    );
  }
}