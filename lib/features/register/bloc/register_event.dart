abstract class RegisterEvent {}

class RegisterSubmitted extends RegisterEvent {
  final String mobileNumber;

  RegisterSubmitted({required this.mobileNumber});
}

class LoginSubmitted extends RegisterEvent {
  final String mobileNumber;

  LoginSubmitted({required this.mobileNumber});
}