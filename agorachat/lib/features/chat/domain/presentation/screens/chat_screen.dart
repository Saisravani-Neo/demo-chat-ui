import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/services/voice_recording_service.dart';
import '../bloc/chat/chat_bloc.dart';
import '../bloc/chat/chat_event.dart';
import '../bloc/chat/chat_state.dart';
import '../widgets/message_bubble.dart';
import 'voice_call_screen.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String receiverId;
  final String receiverAgoraUserId;
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.receiverId,
    required this.receiverAgoraUserId,
    required this.receiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final VoiceRecordingService _recordingService = VoiceRecordingService();

  final List<String> _messages = [];

  void _sendText() {
    final text = _controller.text.trim();

    if (text.isEmpty) return;

    context.read<ChatBloc>().add(
          SendTextMessageEvent(
            conversationId: widget.conversationId,
            receiverId: widget.receiverId,
            receiverAgoraUserId: widget.receiverAgoraUserId,
            text: text,
          ),
        );

    setState(() {
      _messages.add(text);
    });

    _controller.clear();

    Future.delayed(const Duration(milliseconds: 200), () {
      _scrollController.jumpTo(
        _scrollController.position.maxScrollExtent,
      );
    });
  }

  Future<void> _startRecording() async {
    await _recordingService.startRecording();
  }

  Future<void> _stopRecording() async {
    final path = await _recordingService.stopRecording();

    if (path == null || !mounted) return;

    context.read<ChatBloc>().add(
          SendVoiceMessageEvent(
            conversationId: widget.conversationId,
            receiverId: widget.receiverId,
            receiverAgoraUserId: widget.receiverAgoraUserId,
            filePath: path,
            duration: 1,
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _recordingService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.receiverName),
          actions: [
            IconButton(
              icon: const Icon(Icons.call),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VoiceCallScreen(
                      receiverId: widget.receiverId,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return MessageBubble(
                    text: _messages[index],
                    isMe: true,
                    time: TimeOfDay.now().format(context),
                    status: 'SENT',
                  );
                },
              ),
            ),
            SafeArea(
              child: Row(
                children: [
                  GestureDetector(
                    onLongPressStart: (_) => _startRecording(),
                    onLongPressEnd: (_) => _stopRecording(),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.mic),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type message',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendText,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}