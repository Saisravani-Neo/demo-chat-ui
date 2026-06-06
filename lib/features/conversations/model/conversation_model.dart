import 'package:equatable/equatable.dart';

class ConversationItem extends Equatable {
  const ConversationItem({
    required this.receiverUserId,
    required this.contactName,
    required this.latestMessageText,
    required this.unreadCount,
    required this.timestamp,
  });

  final String receiverUserId;
  final String contactName;
  final String latestMessageText;
  final int unreadCount;
  final DateTime timestamp;

  @override
  List<Object?> get props => [
        receiverUserId,
        contactName,
        latestMessageText,
        unreadCount,
        timestamp,
      ];
}
