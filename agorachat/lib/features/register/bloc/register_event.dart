abstract class RegisterEvent {}

class RegisterSubmitted extends RegisterEvent {
  final String mobileNumber;

  RegisterSubmitted({required this.mobileNumber});
}