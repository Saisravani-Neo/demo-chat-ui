import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/storage/local_storage.dart';

import '../features/register/bloc/register_bloc.dart';
import '../features/register/repository/register_repository.dart';
import '../features/register/screen/register_screen.dart';

import '../features/contacts/bloc/contacts_bloc.dart';
import '../features/contacts/model/chat_channel_model.dart';
import '../features/contacts/repository/contacts_repository.dart';
import '../features/contacts/screen/contacts_screen.dart';

import '../features/chat/bloc/chat_bloc.dart';
import '../features/chat/repository/chat_repository.dart';
import '../features/chat/screen/chat_screen.dart';

import '../features/voice_call/screen/voice_call_screen.dart';

import '../features/conversations/bloc/conversations_bloc.dart';
import '../features/conversations/repository/conversations_repository.dart';
import '../features/conversations/screen/conversations_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/register',
  redirect: (context, state) {
    final loggedIn = LocalStorage.isLoggedIn;
    final onRegister = state.matchedLocation == '/register';

    // Not logged in and trying to access a protected route → back to register
    if (!loggedIn && !onRegister) return '/register';

    // Already logged in and sitting on register → skip to home
    if (loggedIn && onRegister) return '/';

    return null; // no redirect needed
  },
  routes: [
    // ── Conversations (Home) ──────────────────────────────────────────────────
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _fade(
        state,
        BlocProvider(
          create: (_) => ConversationsBloc(
            repository: ConversationsRepository(),
          ),
          child: const ConversationsScreen(),
        ),
      ),
    ),

    // ── Register ──────────────────────────────────────────────────────────────
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => _fade(
        state,
        BlocProvider(
          create: (_) => RegisterBloc(
            repository: const RegisterRepository(),
          ),
          child: const RegisterScreen(),
        ),
      ),
    ),

    // ── Contacts ──────────────────────────────────────────────────────────────
    GoRoute(
      path: '/contacts',
      pageBuilder: (context, state) => _fade(
        state,
        BlocProvider(
          create: (_) => ContactsBloc(
            repository: const ContactsRepository(),
          ),
          child: const ContactsScreen(),
        ),
      ),
    ),

    // ── Chat ──────────────────────────────────────────────────────────────────
    GoRoute(
      path: '/chat',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final channel = extra['channel'] as ChatChannelModel;
        final contactName = extra['contactName'] as String;

        return _fade(
          state,
          BlocProvider(
            create: (_) => ChatBloc(
              repository: ChatRepository(
                userId: LocalStorage.userId ?? '',
                chatToken: channel.chatToken ?? '',
              ),
              receiverId: channel.receiverUserId ?? '',
            ),
            child: ChatScreen(
              channel: channel,
              contactName: contactName,
            ),
          ),
        );
      },
    ),

    // ── Voice Call ────────────────────────────────────────────────────────────
    GoRoute(
      path: '/voice-call',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final channel = extra['channel'] as ChatChannelModel;
        final contactName = extra['contactName'] as String;

        return _slide(
          state,
          VoiceCallScreen(
            channel: channel,
            contactName: contactName,
          ),
        );
      },
    ),
  ],
);

// ── Page transition helpers ──────────────────────────────────────────────────

CustomTransitionPage<void> _fade(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (_, animation, __, widget) =>
        FadeTransition(opacity: animation, child: widget),
  );
}

CustomTransitionPage<void> _slide(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (_, animation, __, widget) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
      child: widget,
    ),
  );
}
