import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  const UserModel({
    required this.userId,
    required this.mobileNumber,
  });

  final String userId;
  final String mobileNumber;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as String,
      mobileNumber: json['mobileNumber'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'mobileNumber': mobileNumber,
      };

  @override
  List<Object?> get props => [userId, mobileNumber];
}
