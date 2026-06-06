import 'package:dio/dio.dart';

import '../models/agora_chat_token_model.dart';
import '../models/conversation_model.dart';
import '../models/message_record_model.dart';
import '../models/rtc_token_model.dart';

class ChatRemoteDataSource {
  final Dio dio;

  ChatRemoteDataSource(this.dio);

  Future<AgoraChatTokenModel> getAgoraChatToken() async {
    final response = await dio.get('/api/agora/chat-token');
    return AgoraChatTokenModel.fromJson(response.data['data']);
  }

  Future<RtcTokenModel> getRtcToken({
    required String receiverId,
  }) async {
    final response = await dio.post(
      '/api/agora/rtc-token',
      data: {
        'receiverId': receiverId,
        'callType': 'VOICE',
      },
    );

    return RtcTokenModel.fromJson(response.data['data']);
  }

  Future<List<ConversationModel>> getConversations() async {
    final response = await dio.get('/api/chat/conversations');

    final List data = response.data['data'];

    return data.map((e) => ConversationModel.fromJson(e)).toList();
  }

  Future<ConversationModel> createConversation({
    required String receiverId,
  }) async {
    final response = await dio.post(
      '/api/chat/conversation',
      data: {
        'receiverId': receiverId,
        'type': 'ONE_TO_ONE',
      },
    );

    return ConversationModel.fromJson(response.data['data']);
  }

  Future<void> createGroup({
    required String name,
    required List<String> memberIds,
  }) async {
    await dio.post(
      '/api/chat/groups',
      data: {
        'name': name,
        'memberIds': memberIds,
      },
    );
  }

  Future<MessageRecordModel> saveMessage({
    required String conversationId,
    required String receiverId,
    required String messageType,
    required String content,
    required String agoraMessageId,
    required String status,
  }) async {
    final response = await dio.post(
      '/api/chat/messages',
      data: {
        'conversationId': conversationId,
        'receiverId': receiverId,
        'messageType': messageType,
        'content': content,
        'agoraMessageId': agoraMessageId,
        'status': status,
      },
    );

    return MessageRecordModel.fromJson(response.data['data']);
  }

  Future<void> endCall({
    required String callId,
    required String status,
    required int durationSeconds,
  }) async {
    await dio.post(
      '/api/calls/end',
      data: {
        'callId': callId,
        'status': status,
        'durationSeconds': durationSeconds,
      },
    );
  }
}