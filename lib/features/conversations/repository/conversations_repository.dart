import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter/foundation.dart';

import '../../../core/constants/agora_constants.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/storage/local_storage.dart';
import '../../contacts/model/user_token_response.dart';
import '../model/conversation_model.dart';

class ConversationsRepository {
  ConversationsRepository();

  bool _isLoggedIn = false;

  /// Ensures user is logged into Agora Chat.
  /// If the cached token is empty, fetches it from the server and caches it.
  Future<void> ensureLoggedIn() async {
    if (_isLoggedIn) return;

    final userId = LocalStorage.userId;
    if (userId == null) {
      throw Exception('User is not registered/logged in locally.');
    }

    // 1. Fetch token if not cached
    String? token = LocalStorage.chatToken;
    if (token == null || token.isEmpty) {
      final response = await DioProvider.instance.get(
        ApiConstants.agoraUserTokenEndpoint(userId),
      );
      final json = Map<String, dynamic>.from(response.data);
      final tokenRes = UserTokenResponse.fromJson(
        json['data'] != null
            ? Map<String, dynamic>.from(json['data'])
            : json,
      );
      token = tokenRes.token;
      if (token.isNotEmpty) {
        await LocalStorage.saveChatToken(token);
      } else {
        throw Exception('Failed to retrieve Agora chat token from server.');
      }
    }

    // 2. Initialise SDK if needed
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
      // 3. Authenticate with Agora server
      await ChatClient.getInstance.loginWithToken(userId, token);
      _isLoggedIn = true;
    } on ChatError catch (e) {
      if (e.code == 200) {
        _isLoggedIn = true;
        return;
      }
      rethrow;
    }
  }

  /// Fetches the local conversations and remote conversations in the background.
  Future<List<ConversationItem>> fetchConversations() async {
    await ensureLoggedIn();

    // 1. Load local conversations from device database
    List<ChatConversation> localConvs =
        await ChatClient.getInstance.chatManager.loadAllConversations();

    // 2. Parse local conversations
    final items = <ConversationItem>[];
    for (final conv in localConvs) {
      final item = await _parseConversation(conv);
      if (item != null) {
        items.add(item);
      }
    }

    // 3. Trigger remote conversations load asynchronously in the background.
    // This fills up history when logging in on a new device.
    _fetchRemoteConversationsInBackground();

    return items;
  }

  /// Triggers a fetch of remote conversations from the Agora server.
  Future<void> _fetchRemoteConversationsInBackground() async {
    try {
      await ChatClient.getInstance.chatManager.fetchConversationsByOptions(
        options: ConversationFetchOptions(pageSize: 50),
      );
    } catch (e) {
      // Background operation failure; log and ignore so local list isn't blocked
      debugPrint('Background remote conversation fetch error: $e');
    }
  }

  /// Parses an SDK `ChatConversation` into our frontend `ConversationItem`.
  Future<ConversationItem?> _parseConversation(ChatConversation conv) async {
    final lastMsg = await conv.latestMessage();
    if (lastMsg == null) return null;

    final unread = await conv.unreadCount();
    final contactName = LocalStorage.getContactName(conv.id) ?? conv.id;

    String bodyText = '';
    final body = lastMsg.body;
    if (body is ChatTextMessageBody) {
      bodyText = body.content;
    } else if (body is ChatVoiceMessageBody) {
      bodyText = '🎤 Voice message';
    } else {
      bodyText = 'Message';
    }

    final ts = DateTime.fromMillisecondsSinceEpoch(lastMsg.serverTime);

    return ConversationItem(
      receiverUserId: conv.id,
      contactName: contactName,
      latestMessageText: bodyText,
      unreadCount: unread,
      timestamp: ts,
    );
  }
}
