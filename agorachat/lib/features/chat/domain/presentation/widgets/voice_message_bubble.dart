import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class VoiceMessageBubble extends StatefulWidget {
  final String filePath;
  final bool isMe;

  const VoiceMessageBubble({
    super.key,
    required this.filePath,
    required this.isMe,
  });

  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble> {
  final AudioPlayer _player = AudioPlayer();

  Future<void> _play() async {
    await _player.setFilePath(widget.filePath);
    await _player.play();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: IconButton(
        icon: const Icon(Icons.play_circle_fill),
        onPressed: _play,
      ),
    );
  }
}