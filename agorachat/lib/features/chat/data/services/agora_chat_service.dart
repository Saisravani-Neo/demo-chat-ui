import 'dart:async';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';

class AgoraChatService {
  final StreamController<ChatMessage> _messageController =
      StreamController<ChatMessage>.broadcast();

  Stream<ChatMessage> get messageStream => _messageController.stream;

  Future<void> init({
    required String appKey,
  }) async {
    final options = ChatOptions(
      appKey: appKey,
      autoLogin: false,
    );

    await ChatClient.getInstance.init(options);
    await ChatClient.getInstance.startCallback();
  }

  Future<void> login({
    required String agoraUserId,
    required String token,
  }) async {
    await ChatClient.getInstance.loginWithToken(
      agoraUserId,
      token,
    );

    ChatClient.getInstance.chatManager.addMessageEvent(
      'chat_listener',
      ChatMessageEvent(
        onSuccess: (msgId, msg) {},
        onProgress: (msgId, progress) {},
        onError: (msgId, msg, error) {},
      ),
    );

    ChatClient.getInstance.chatManager.addEventHandler(
      'incoming_message_listener',
      ChatEventHandler(
        onMessagesReceived: (messages) {
          for (final message in messages) {
            _messageController.add(message);
          }
        },
      ),
    );
  }

  Future<void> renewToken(String token) async {
    await ChatClient.getInstance.renewAgoraToken(token);
  }

  Future<ChatMessage> sendTextMessage({
    required String receiverAgoraUserId,
    required String text,
  }) async {
    final message = ChatMessage.createTxtSendMessage(
      targetId: receiverAgoraUserId,
      content: text,
    );

    await ChatClient.getInstance.chatManager.sendMessage(message);

    return message;
  }

  Future<ChatMessage> sendVoiceMessage({
    required String receiverAgoraUserId,
    required String filePath,
    required int duration,
  }) async {
    final message = ChatMessage.createVoiceSendMessage(
      targetId: receiverAgoraUserId,
      filePath: filePath,
      duration: duration,
    );

    await ChatClient.getInstance.chatManager.sendMessage(message);

    return message;
  }

  Future<List<ChatMessage>> loadMessages({
    required String conversationId,
    required String startMsgId,
    int pageSize = 20,
  }) async {
    final conversation = await ChatClient.getInstance.chatManager
        .getConversation(conversationId);

    final messages = await conversation?.loadMessages(
      startMsgId: startMsgId,
      loadCount: pageSize,
    );

    return messages ?? [];
  }

  Future<void> sendTyping({
    required String receiverAgoraUserId,
  }) async {
    await ChatClient.getInstance.chatManager.sendConversationReadAck(
      receiverAgoraUserId,
    );
  }

  Future<void> logout() async {
    await ChatClient.getInstance.logout(true);
  }

  void dispose() {
    _messageController.close();
  }
}