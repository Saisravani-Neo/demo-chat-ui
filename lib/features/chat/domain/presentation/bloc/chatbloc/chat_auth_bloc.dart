import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../usecase/get_agora_chat_token_usecase.dart';
import '../../../usecase/login_agora_chat_usecase.dart';
import 'chat_auth_event.dart';
import 'chat_auth_state.dart';

class ChatAuthBloc extends Bloc<ChatAuthEvent, ChatAuthState> {
  final GetAgoraChatTokenUseCase getTokenUseCase;
  final LoginAgoraChatUseCase loginUseCase;

  ChatAuthBloc({
    required this.getTokenUseCase,
    required this.loginUseCase,
  }) : super(ChatAuthInitial()) {
    on<ChatAuthStarted>(_onStarted);
  }

  Future<void> _onStarted(
    ChatAuthStarted event,
    Emitter<ChatAuthState> emit,
  ) async {
    try {
      emit(ChatAuthLoading());

      final token = await getTokenUseCase();

      await loginUseCase(
        agoraUserId: token.agoraUserId,
        token: token.token,
      );

      emit(ChatAuthSuccess());
    } catch (e) {
      emit(ChatAuthFailure(e.toString()));
    }
  }
}