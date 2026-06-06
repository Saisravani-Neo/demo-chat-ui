import 'package:dio/dio.dart';

import '../models/agora_chat_token_model.dart';
import '../models/conversation_model.dart';
import '../models/message_record_model.dart';
import '../models/rtc_token_model.dart';
import 'chat_remote_datasource.dart';

class MockChatRemoteDataSource extends ChatRemoteDataSource {
  MockChatRemoteDataSource() : super(Dio());

  @override
  Future<AgoraChatTokenModel> getAgoraChatToken() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return AgoraChatTokenModel(
      agoraUserId: 'mock-user-001',
      token: 'mock-agora-token',
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    );
  }

  @override
  Future<RtcTokenModel> getRtcToken({required String receiverId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return RtcTokenModel(
      callId: 'mock-call-001',
      channelName: 'mock-channel',
      token: 'mock-rtc-token',
      uid: 1001,
      appId: 'mock-app-id',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  @override
  Future<List<ConversationModel>> getConversations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      ConversationModel(
        id: 'conv-1',
        receiverId: 'user-2',
        receiverName: 'Alice Johnson',
        type: 'ONE_TO_ONE',
        lastMessage: 'Hey, how are you doing?',
        updatedAt: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      ConversationModel(
        id: 'conv-2',
        receiverId: 'user-3',
        receiverName: 'Bob Smith',
        type: 'ONE_TO_ONE',
        lastMessage: 'See you at the meeting tomorrow!',
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      ConversationModel(
        id: 'conv-3',
        receiverId: 'user-4',
        receiverName: 'Carol White',
        type: 'ONE_TO_ONE',
        lastMessage: 'Thanks for the update.',
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      ConversationModel(
        id: 'conv-4',
        receiverId: 'user-5',
        receiverName: 'David Lee',
        type: 'ONE_TO_ONE',
        lastMessage: 'Can you send me the file?',
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  @override
  Future<ConversationModel> createConversation(
      {required String receiverId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ConversationModel(
      id: 'conv-new-${DateTime.now().millisecondsSinceEpoch}',
      receiverId: receiverId,
      receiverName: 'New Contact',
      type: 'ONE_TO_ONE',
      lastMessage: null,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> createGroup(
      {required String name, required List<String> memberIds}) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<MessageRecordModel> saveMessage({
    required String conversationId,
    required String receiverId,
    required String messageType,
    required String content,
    required String agoraMessageId,
    required String status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MessageRecordModel(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      receiverId: receiverId,
      messageType: messageType,
      content: content,
      agoraMessageId: agoraMessageId,
      status: status,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> endCall({
    required String callId,
    required String status,
    required int durationSeconds,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
