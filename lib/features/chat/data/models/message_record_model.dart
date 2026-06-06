class MessageRecordModel {
  final String id;
  final String conversationId;
  final String? senderId;
  final String? receiverId;
  final String messageType;
  final String content;
  final String status;
  final String agoraMessageId;
  final DateTime createdAt;

  MessageRecordModel({
    required this.id,
    required this.conversationId,
    this.senderId,
    this.receiverId,
    required this.messageType,
    required this.content,
    required this.status,
    required this.agoraMessageId,
    required this.createdAt,
  });

  factory MessageRecordModel.fromJson(Map<String, dynamic> json) {
    return MessageRecordModel(
      id: json['id'],
      conversationId: json['conversation']?['id'] ?? '',
      senderId: json['sender']?['id'],
      receiverId: json['receiver']?['id'],
      messageType: json['messageType'],
      content: json['content'],
      status: json['status'],
      agoraMessageId: json['agoraMessageId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}