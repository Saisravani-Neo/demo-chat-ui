import 'package:equatable/equatable.dart';

class ContactModel extends Equatable {
  const ContactModel({
    required this.displayName,
    required this.phoneNumber,
    this.initials = '',
  });

  final String displayName;
  final String phoneNumber;
  final String initials;

  factory ContactModel.fromRaw({
    required String displayName,
    required String phoneNumber,
  }) {
    final parts = displayName.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : displayName.isNotEmpty
            ? displayName[0].toUpperCase()
            : '?';

    return ContactModel(
      displayName: displayName,
      phoneNumber: phoneNumber,
      initials: initials,
    );
  }

  @override
  List<Object?> get props => [displayName, phoneNumber];
}
