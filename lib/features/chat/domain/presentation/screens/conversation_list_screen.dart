import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/conversation/conversation_bloc.dart';
import '../bloc/conversation/conversation_event.dart';
import '../bloc/conversation/conversation_state.dart';
import 'chat_screen.dart';

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key});

  @override
  State<ConversationListScreen> createState() =>
      _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ConversationBloc>().add(LoadConversations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
      ),
      body: BlocBuilder<ConversationBloc, ConversationState>(
        builder: (context, state) {
          if (state is ConversationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ConversationFailure) {
            return Center(child: Text(state.message));
          }

          if (state is ConversationLoaded) {
            if (state.conversations.isEmpty) {
              return const Center(child: Text('No conversations found'));
            }

            return ListView.builder(
              itemCount: state.conversations.length,
              itemBuilder: (context, index) {
                final item = state.conversations[index];

                return ListTile(
                  title: Text(item.receiverName ?? 'User'),
                  subtitle: Text(item.lastMessage ?? ''),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          conversationId: item.id,
                          receiverId: item.receiverId ?? '',
                          receiverAgoraUserId: item.receiverId ?? '',
                          receiverName: item.receiverName ?? 'User',
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}