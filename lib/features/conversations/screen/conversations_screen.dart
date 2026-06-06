import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';

import '../bloc/conversations_bloc.dart';
import '../bloc/conversations_event.dart';
import '../bloc/conversations_state.dart';
import '../../contacts/model/chat_channel_model.dart';
import '../../contacts/repository/contacts_repository.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/common_snackbar.dart';
import '../../../widgets/common_text_field.dart';
import '../../../core/utils/phone_number_utils.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ConversationsBloc>().add(const LoadConversations());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await LocalStorage.clear();
    try {
      await ChatClient.getInstance.logout();
    } catch (_) {}
    if (mounted) context.go('/register');
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(dt.year, dt.month, dt.day);

    if (msgDate == today) {
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (msgDate == yesterday) {
      return 'Yesterday';
    } else {
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year;
      return '$day/$month/$year';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Add Manually',
            onPressed: () => showAddManualContactDialogHome(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: BlocConsumer<ConversationsBloc, ConversationsState>(
        listener: (context, state) {
          if (state is ConversationsFailure) {
            CommonSnackbar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is ConversationsLoading) {
            return const LoadingWidget(message: 'Loading chats...');
          }

          if (state is ConversationsFailure) {
            return _ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<ConversationsBloc>().add(const LoadConversations()),
            );
          }

          if (state is ConversationsLoaded) {
            final conversations = state.conversations;
            final filtered = conversations.where((c) {
              return c.contactName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  c.receiverUserId.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();

            return Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search chats...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // Conversations List
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text(
                            'No chats found.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, indent: 76),
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            final initial = item.contactName.isNotEmpty
                                ? item.contactName[0].toUpperCase()
                                : '?';

                            return ListTile(
                              onTap: () {
                                final channel = ChatChannelModel(
                                  registered: true,
                                  currentUserId: LocalStorage.userId,
                                  receiverUserId: item.receiverUserId,
                                  channelName: LocalStorage.getChannelName(item.receiverUserId),
                                  chatToken: LocalStorage.chatToken,
                                  contactName: item.contactName,
                                );
                                context.push(
                                  '/chat',
                                  extra: {
                                    'channel': channel,
                                    'contactName': item.contactName,
                                  },
                                );
                              },
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: AppTheme.primary,
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              title: Text(
                                item.contactName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                item.latestMessageText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: item.unreadCount > 0
                                      ? Colors.black87
                                      : Colors.grey.shade600,
                                  fontWeight: item.unreadCount > 0
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatTime(item.timestamp),
                                    style: TextStyle(
                                      color: item.unreadCount > 0
                                          ? AppTheme.primary
                                          : Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (item.unreadCount > 0)
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: AppTheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${item.unreadCount}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          if (state is ConversationsEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.forum_outlined, size: 72, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No conversation history',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Start chatting by entering a phone number manually or selecting from your contacts list.',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => showAddManualContactDialogHome(context),
                      icon: const Icon(Icons.person_add),
                      label: const Text('Add Contact Manually'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => context.push('/contacts'),
                      icon: const Icon(Icons.contacts, color: AppTheme.primary),
                      label: const Text(
                        'Select from Contacts',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/contacts'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        tooltip: 'New Chat',
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.chat),
      ),
    );
  }
}

// ─── Error view ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Retry', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

// ─── Add manual contact dialog ───────────────────────────────────────────────

void showAddManualContactDialogHome(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return const _AddManualContactDialogHome();
    },
  );
}

class _AddManualContactDialogHome extends StatefulWidget {
  const _AddManualContactDialogHome();

  @override
  State<_AddManualContactDialogHome> createState() => _AddManualContactDialogHomeState();
}

class _AddManualContactDialogHomeState extends State<_AddManualContactDialogHome> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showNotRegisteredDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Contact Not Found'),
        content: const Text(
          'This contact is not registered in this app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    try {
      const repository = ContactsRepository();
      final channel = await repository.checkAndCreate(phone);

      if (!mounted) return;

      if (!channel.registered) {
        setState(() {
          _isLoading = false;
        });
        _showNotRegisteredDialog();
        return;
      }

      // Cache details in LocalStorage for conversation history lookup
      if (channel.receiverUserId != null) {
        await LocalStorage.saveContactName(channel.receiverUserId!, name);
        if (channel.channelName != null) {
          await LocalStorage.saveChannelName(channel.receiverUserId!, channel.channelName!);
        }
        if (channel.chatToken != null) {
          await LocalStorage.saveChatToken(channel.chatToken!);
        }
      }

      if (!mounted) return;
      Navigator.pop(context); // Close dialog

      // Navigate to chat
      context.push(
        '/chat',
        extra: {
          'channel': channel,
          'contactName': name,
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      CommonSnackbar.showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Add Contact Manually',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonTextField(
                controller: _nameController,
                hint: 'Enter contact name',
                label: 'Name',
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CommonTextField(
                controller: _phoneController,
                hint: 'Enter 10-digit number',
                label: 'Mobile Number',
                prefixText: '+91 ',
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 10,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: PhoneNumberUtils.validateInput,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: const Size(80, 40),
          ),
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Add'),
        ),
      ],
    );
  }
}
