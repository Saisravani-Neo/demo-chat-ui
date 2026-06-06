import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../model/chat_message_model.dart';
import '../../contacts/model/chat_channel_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/common_snackbar.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/constants/api_constants.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.channel,
    required this.contactName,
  });

  final ChatChannelModel channel;
  final String contactName;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context
        .read<ChatBloc>()
        .add(ChatInitialized(receiverId: widget.channel.receiverUserId!));
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendText() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    context.read<ChatBloc>().add(ChatTextSent(text: text));
  }

  Future<void> _handleVoiceCall() async {
    final channel = widget.channel;

    String? channelName = channel.channelName;
    if (channelName == null || channelName.isEmpty) {
      channelName = LocalStorage.getChannelName(channel.receiverUserId ?? '');
    }

    if (channelName == null || channelName.isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );

      try {
        final senderUserId = LocalStorage.userId ?? '';
        final receiverUserId = channel.receiverUserId ?? '';

        final response = await DioProvider.instance.post(
          ApiConstants.createChatRoomEndpoint,
          data: {
            'senderUserId': senderUserId,
            'receiverUserId': receiverUserId,
          },
        );

        final json = Map<String, dynamic>.from(response.data);
        final roomJson = json['data'] != null
            ? Map<String, dynamic>.from(json['data'])
            : json;

        channelName = roomJson['channelName']?.toString();

        if (channelName != null && channelName.isNotEmpty) {
          await LocalStorage.saveChannelName(receiverUserId, channelName);
        }

        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          CommonSnackbar.showError(context, 'Failed to connect voice call room.');
        }
        return;
      }
    }

    if (channelName == null || channelName.isEmpty) {
      if (mounted) {
        CommonSnackbar.showError(context, 'Voice call room is not available.');
      }
      return;
    }

    final populatedChannel = ChatChannelModel(
      registered: channel.registered,
      currentUserId: channel.currentUserId,
      receiverUserId: channel.receiverUserId,
      channelName: channelName,
      chatToken: channel.chatToken,
      voiceCallToken: channel.voiceCallToken,
      contactName: channel.contactName,
    );

    if (mounted) {
      context.go(
        '/voice-call',
        extra: {
          'channel': populatedChannel,
          'contactName': widget.contactName,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: Text(
                widget.contactName.isNotEmpty
                    ? widget.contactName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(widget.contactName),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            tooltip: 'Voice Call',
            onPressed: _handleVoiceCall,
          ),
        ],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatReady) {
            if (state.error != null) {
              CommonSnackbar.showError(context, state.error!);
            }
            _scrollToBottom();
          } else if (state is ChatFailure) {
            CommonSnackbar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is ChatConnecting) {
            return const LoadingWidget(message: 'Connecting to chat...');
          }
          if (state is ChatFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }
          if (state is ChatReady) {
            return Column(
              children: [
                Expanded(child: _MessageList(
                  messages: state.messages,
                  scrollController: _scrollController,
                )),
                _InputBar(
                  controller: _textController,
                  isSending: state.isSending,
                  isRecording: state.isRecording,
                  onSend: _sendText,
                  onRecordStart: () =>
                      context.read<ChatBloc>().add(const ChatRecordingStarted()),
                  onRecordStop: () =>
                      context.read<ChatBloc>().add(const ChatRecordingStopped()),
                ),
              ],
            );
          }
          return const LoadingWidget();
        },
      ),
    );
  }
}

// ─── Message list ─────────────────────────────────────────────────────────────

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.messages,
    required this.scrollController,
  });

  final List<ChatMessageModel> messages;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(
        child: Text(
          'No messages yet.\nSay hello!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: messages.length,
      itemBuilder: (_, index) => _MessageBubble(message: messages[index]),
    );
  }
}

// ─── Message bubble ───────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    final isSent = message.isSent;

    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSent ? AppTheme.senderBubble : AppTheme.receiverBubble,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isSent ? 16 : 4),
              bottomRight: Radius.circular(isSent ? 4 : 16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              message.type == MessageType.text
                  ? Text(
                      message.content,
                      style: TextStyle(
                        color: isSent
                            ? AppTheme.senderText
                            : AppTheme.receiverText,
                        fontSize: 15,
                      ),
                    )
                  : _VoiceBubble(message: message, isSent: isSent),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isSent ? Colors.white70 : Colors.grey,
                    ),
                  ),
                  if (isSent) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.hasReadAck ? Icons.done_all : Icons.done,
                      size: 16,
                      color: message.hasReadAck ? Colors.cyanAccent : Colors.white70,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Voice bubble ─────────────────────────────────────────────────────────────

class _VoiceBubble extends StatelessWidget {
  const _VoiceBubble({required this.message, required this.isSent});

  final ChatMessageModel message;
  final bool isSent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context
          .read<ChatBloc>()
          .add(ChatVoicePlayToggled(messageId: message.messageId)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            message.isPlaying ? Icons.stop_circle : Icons.play_circle_fill,
            color: isSent ? Colors.white : AppTheme.primary,
            size: 32,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Voice message',
                style: TextStyle(fontSize: 13),
              ),
              if (message.voiceDuration != null)
                Text(
                  '${message.voiceDuration}s',
                  style: TextStyle(
                    fontSize: 11,
                    color: isSent ? Colors.white70 : Colors.grey,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Input bar ────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.isSending,
    required this.isRecording,
    required this.onSend,
    required this.onRecordStart,
    required this.onRecordStop,
  });

  final TextEditingController controller;
  final bool isSending;
  final bool isRecording;
  final VoidCallback onSend;
  final VoidCallback onRecordStart;
  final VoidCallback onRecordStop;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Voice record button
            GestureDetector(
              onLongPressStart: (_) => onRecordStart(),
              onLongPressEnd: (_) => onRecordStop(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isRecording
                      ? AppTheme.primary
                      : const Color(0xFFF5F5F5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isRecording ? Icons.fiber_manual_record : Icons.mic,
                  color: isRecording ? Colors.white : AppTheme.primary,
                  size: 22,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Text field
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: isRecording
                      ? 'Recording... release to send'
                      : 'Type a message',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSending
                  ? const SizedBox(
                      width: 42,
                      height: 42,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppTheme.primary,
                        ),
                      ),
                    )
                  : IconButton(
                      onPressed: onSend,
                      icon: const Icon(Icons.send_rounded),
                      color: AppTheme.primary,
                      iconSize: 26,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
