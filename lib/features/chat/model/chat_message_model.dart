import 'package:equatable/equatable.dart';

enum MessageType { text, voice }

enum MessageDirection { sent, received }

class ChatMessageModel extends Equatable {
  const ChatMessageModel({
    required this.messageId,
    required this.content,
    required this.type,
    required this.direction,
    required this.timestamp,
    this.voiceDuration,
    this.localPath,
    this.isPlaying = false,
  });

  final String messageId;

  /// Text content or remote voice file URL.
  final String content;

  final MessageType type;
  final MessageDirection direction;
  final DateTime timestamp;

  /// Voice message duration in seconds.
  final int? voiceDuration;

  /// Local file path for voice messages that were recorded on this device.
  final String? localPath;

  /// Playback state (UI only, not persisted).
  final bool isPlaying;

  bool get isSent => direction == MessageDirection.sent;

  ChatMessageModel copyWith({bool? isPlaying}) {
    return ChatMessageModel(
      messageId: messageId,
      content: content,
      type: type,
      direction: direction,
      timestamp: timestamp,
      voiceDuration: voiceDuration,
      localPath: localPath,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  @override
  List<Object?> get props => [messageId, content, type, direction, timestamp];
}
