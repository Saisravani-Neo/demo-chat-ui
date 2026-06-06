import 'package:flutter/material.dart';

import 'domain/presentation/screens/conversation_list_screen.dart';

class ChatRouteExample {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/chat/conversations':
        return MaterialPageRoute(
          builder: (_) => const ConversationListScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const ConversationListScreen(),
        );
    }
  }
}