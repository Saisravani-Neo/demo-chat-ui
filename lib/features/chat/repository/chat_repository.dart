// Hide agora's own MessageType/MessageDirection to avoid name collision with
// our ChatMessageModel enums.
import 'package:agora_chat_sdk/agora_chat_sdk.dart'
    hide MessageType, MessageDirection;

import '../../../core/constants/agora_constants.dart';
import '../model/chat_message_model.dart';

class ChatRepository {
  ChatRepository({required this.userId, required this.chatToken});

  final String userId;
  final String chatToken;

  bool _isLoggedIn = false;

  // ─── Agora Chat Login ──────────────────────────────────────────────────────

  /// Initialises the Agora Chat SDK and logs in with [chatToken].
  ///
  /// How it works:
  /// - [ChatOptions.appKey] binds the SDK to your Agora project.
  /// - [loginWithToken] exchanges [userId] + [chatToken] for an authenticated
  ///   session with Agora's messaging servers.
  /// - Token is generated server-side using your App Certificate.
  Future<void> login() async {
    if (_isLoggedIn) return;

    final options = ChatOptions(
      appKey: AgoraConstants.chatAppKey,
      autoLogin: false,
      requireAck: true,
    );

    await ChatClient.getInstance.init(options);

    final alreadyLoggedIn = await ChatClient.getInstance.isLoginBefore();
    if (alreadyLoggedIn) {
      _isLoggedIn = true;
      return;
    }

    try {
      await ChatClient.getInstance.loginWithToken(userId, chatToken);
      _isLoggedIn = true;
    } on ChatError catch (e) {
      if (e.code == 200) {
        _isLoggedIn = true;
        return;
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    if (!_isLoggedIn) return;
    await ChatClient.getInstance.logout();
    _isLoggedIn = false;
  }

  // ─── Message history ───────────────────────────────────────────────────────

  /// Loads locally-cached conversation messages.
  /// Once the backend is live, replace the body with a server-fetch call.
  Future<List<ChatMessageModel>> fetchHistory(String receiverId) async {
    final conversation = await ChatClient.getInstance.chatManager
        .getConversation(receiverId, createIfNeed: true);

    if (conversation == null) return [];

    final messages = await conversation.loadMessages(startMsgId: '');
    return messages
        .map((m) => _fromSdkMessage(m, myUserId: userId))
        .whereType<ChatMessageModel>()
        .toList();
  }

  /// Marks all messages in the conversation as read locally and sends a read ack.
  Future<void> markAsRead(String receiverId) async {
    try {
      final conversation = await ChatClient.getInstance.chatManager
          .getConversation(receiverId);
      await conversation?.markAllMessagesAsRead();
      await ChatClient.getInstance.chatManager.sendConversationReadAck(receiverId);
    } catch (_) {
      // Ignored: network failure during read receipt sending shouldn't crash the app
    }
  }

  // ─── Send messages ─────────────────────────────────────────────────────────

  /// Sends a plain-text message to [receiverId].
  Future<ChatMessage> sendTextMessage({
    required String receiverId,
    required String text,
  }) async {
    final message = ChatMessage.createTxtSendMessage(
      targetId: receiverId,
      content: text,
    );
    await ChatClient.getInstance.chatManager.sendMessage(message);
    return message;
  }

  /// Sends a voice message recorded at [filePath].
  ///
  /// Agora uploads the file to its CDN and delivers the remote URL to the peer.
  Future<ChatMessage> sendVoiceMessage({
    required String receiverId,
    required String filePath,
    required int durationSeconds,
  }) async {
    final message = ChatMessage.createVoiceSendMessage(
      targetId: receiverId,
      filePath: filePath,
      duration: durationSeconds,
    );
    await ChatClient.getInstance.chatManager.sendMessage(message);
    return message;
  }

  // ─── Internal helpers ──────────────────────────────────────────────────────

  ChatMessageModel? _fromSdkMessage(
    ChatMessage message, {
    required String myUserId,
  }) {
    final isSent = message.from?.toLowerCase() == myUserId.toLowerCase();
    final direction =
        isSent ? MessageDirection.sent : MessageDirection.received;
    final ts = DateTime.fromMillisecondsSinceEpoch(message.serverTime);

    final body = message.body;

    if (body is ChatTextMessageBody) {
      return ChatMessageModel(
        messageId: message.msgId,
        content: body.content,
        type: MessageType.text,
        direction: direction,
        timestamp: ts,
        hasRead: message.hasRead,
        hasReadAck: message.hasReadAck,
      );
    }

    if (body is ChatVoiceMessageBody) {
      return ChatMessageModel(
        messageId: message.msgId,
        content: body.remotePath ?? '',
        type: MessageType.voice,
        direction: direction,
        timestamp: ts,
        voiceDuration: body.duration,
        localPath: body.localPath,
        hasRead: message.hasRead,
        hasReadAck: message.hasReadAck,
      );
    }

    return null;
  }
}
