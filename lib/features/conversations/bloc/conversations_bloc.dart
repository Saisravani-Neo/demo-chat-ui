import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/conversations_repository.dart';
import 'conversations_event.dart';
import 'conversations_state.dart';

class ConversationsBloc extends Bloc<ConversationsEvent, ConversationsState> {
  ConversationsBloc({required this.repository}) : super(const ConversationsInitial()) {
    on<LoadConversations>(_onLoadConversations);
    on<RefreshConversations>(_onRefreshConversations);

    // Register event handler to listen for incoming messages in real-time
    // so the conversations history list updates automatically.
    ChatClient.getInstance.chatManager.addEventHandler(
      'conversations_bloc_listener',
      ChatEventHandler(
        onMessagesReceived: (_) => add(const RefreshConversations()),
        onMessagesDelivered: (_) => add(const RefreshConversations()),
        onMessagesRead: (_) => add(const RefreshConversations()),
      ),
    );
  }

  final ConversationsRepository repository;

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<ConversationsState> emit,
  ) async {
    emit(const ConversationsLoading());
    try {
      final conversations = await repository.fetchConversations();
      if (conversations.isEmpty) {
        emit(const ConversationsEmpty());
      } else {
        emit(ConversationsLoaded(conversations: conversations));
      }
    } catch (e) {
      emit(ConversationsFailure(message: e.toString()));
    }
  }

  Future<void> _onRefreshConversations(
    RefreshConversations event,
    Emitter<ConversationsState> emit,
  ) async {
    try {
      final conversations = await repository.fetchConversations();
      if (conversations.isEmpty) {
        emit(const ConversationsEmpty());
      } else {
        emit(ConversationsLoaded(conversations: conversations));
      }
    } catch (_) {
      // Silently ignore refresh errors to prevent disrupting active user UI
    }
  }

  @override
  Future<void> close() {
    ChatClient.getInstance.chatManager.removeEventHandler('conversations_bloc_listener');
    return super.close();
  }
}
