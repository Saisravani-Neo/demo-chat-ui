import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted({required this.mobileNumber});

  final String mobileNumber;

  @override
  List<Object?> get props => [mobileNumber];
}
