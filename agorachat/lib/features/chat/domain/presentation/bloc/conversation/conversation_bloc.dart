import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../usecase/get_conversations_usecase.dart';
import 'conversation_event.dart';
import 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final GetConversationsUseCase getConversationsUseCase;

  ConversationBloc({
    required this.getConversationsUseCase,
  }) : super(ConversationInitial()) {
    on<LoadConversations>(_onLoad);
  }

  Future<void> _onLoad(
    LoadConversations event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      emit(ConversationLoading());

      final conversations = await getConversationsUseCase();

      emit(ConversationLoaded(conversations));
    } catch (e) {
      emit(ConversationFailure(e.toString()));
    }
  }
}