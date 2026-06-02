import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/services/voice_recording_service.dart';
import '../bloc/chat/chat_bloc.dart';
import '../bloc/chat/chat_event.dart';
import '../bloc/chat/chat_state.dart';
import '../widgets/message_bubble.dart';
import 'voice_call_screen.dart';

class _ChatMessage {
  final String text;
  final bool isMe;
  final String time;
  final String status;
  final String senderName;
  final String? actionLabel;
  final bool isDateSeparator;

  const _ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
    required this.status,
    required this.senderName,
    this.actionLabel,
    this.isDateSeparator = false,
  });
}

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

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: 'Lorem ipsum dolor sit amet consectetur.',
      isMe: false,
      time: '3:53 PM',
      status: 'DELIVERED',
      senderName: 'Ramakrishna',
    ),
    _ChatMessage(
      text: 'Lorem ipsum dolor.',
      isMe: true,
      time: '3:53 PM',
      status: 'SENT',
      senderName: 'Janakiram',
    ),
    _ChatMessage(
      text: 'Subtract undo boolean arrow thumbnail hand duplicate object.',
      isMe: true,
      time: '3:53 PM',
      status: 'SENT',
      senderName: 'Janakiram',
    ),
    _ChatMessage(
      text: 'Fresh sauce pesto pepperoni steak',
      isMe: true,
      time: '3:53 PM',
      status: 'SENT',
      senderName: 'Janakiram',
    ),
    _ChatMessage(
      text: '',
      isMe: false,
      time: '3:53 PM',
      status: 'DELIVERED',
      senderName: 'Anandh reddy (Electrician4)',
    ),
    _ChatMessage(
      text: 'Nithin (Plumber)',
      isMe: false,
      time: '3:53 PM',
      status: 'DELIVERED',
      senderName: 'Nithin (Plumber)',
      actionLabel: 'Add To My TudBook',
    ),
    _ChatMessage(
      text: '5:53 PM',
      isMe: false,
      time: '',
      status: '',
      senderName: '',
      isDateSeparator: true,
    ),
  ];

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

    final now = TimeOfDay.now();
    final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';

    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isMe: true,
        time: '$hour:$minute $period',
        status: 'SENT',
        senderName: 'Me',
      ));
    });

    _controller.clear();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
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
        backgroundColor: const Color(0xFFF0EBF8),
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  if (msg.isDateSeparator) {
                    return _DateSeparator(label: msg.text);
                  }
                  return MessageBubble(
                    text: msg.text,
                    isMe: msg.isMe,
                    time: msg.time,
                    status: msg.status,
                    senderName: msg.senderName,
                    actionLabel: msg.actionLabel,
                  );
                },
              ),
            ),
            _buildInputArea(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      leadingWidth: 32,
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white24,
            child: Text(
              widget.receiverName.isNotEmpty
                  ? widget.receiverName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.receiverName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VoiceCallScreen(receiverId: widget.receiverId),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Message',
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _sendText(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_file,
                          color: Colors.grey),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 22,
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.camera_alt,
                          color: Colors.grey),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 22,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onLongPressStart: (_) => _startRecording(),
              onLongPressEnd: (_) => _stopRecording(),
              onTap: _sendText,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, child) {
                    return Icon(
                      value.text.isEmpty ? Icons.mic : Icons.send,
                      color: Colors.white,
                      size: 22,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  final String label;

  const _DateSeparator({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: CustomPaint(
              painter: _DashedLinePainter(),
              child: const SizedBox(height: 1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: CustomPaint(
              painter: _DashedLinePainter(),
              child: const SizedBox(height: 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1;

    double x = 0;
    const dashWidth = 5.0;
    const dashSpace = 3.0;

    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) => false;
}
