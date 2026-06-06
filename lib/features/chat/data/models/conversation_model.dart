class ConversationModel {
  final String id;
  final String? receiverId;
  final String? receiverName;
  final String type;
  final String? lastMessage;
  final DateTime? updatedAt;

  ConversationModel({
    required this.id,
    this.receiverId,
    this.receiverName,
    required this.type,
    this.lastMessage,
    this.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      receiverId: json['receiver']?['id'],
      receiverName: json['receiver']?['name'],
      type: json['type'],
      lastMessage: json['lastMessage'],
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}