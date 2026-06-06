import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/register_repository.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterRepository repository;

  RegisterBloc({required this.repository}) : super(RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());

    try {
      final response = await repository.registerUser(
        mobileNumber: event.mobileNumber,
      );

      emit(RegisterSuccess(message: response.message));
    } catch (e) {
      emit(RegisterFailure(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());

    try {
      await repository.loginUser(
        mobileNumber: event.mobileNumber,
      );

      emit(RegisterSuccess(message: 'Logged in successfully'));
    } catch (e) {
      emit(RegisterFailure(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}