import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/contacts_bloc.dart';
import '../bloc/contacts_event.dart';
import '../bloc/contacts_state.dart';
import '../model/contact_model.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/common_snackbar.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ContactsBloc>().add(const LoadContacts());
  }

  Future<void> _logout() async {
    await LocalStorage.clear();
    if (mounted) context.go('/register');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Contact'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: BlocConsumer<ContactsBloc, ContactsState>(
        listener: (context, state) {
          if (state is ContactsNavigateToChat) {
            context.go(
              '/chat',
              extra: {
                'channel': state.channel,
                'contactName': state.contactName,
              },
            );
          } else if (state is ContactNotRegistered) {
            _showNotRegisteredDialog();
          } else if (state is ContactsFailure) {
            CommonSnackbar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is ContactsLoading) {
            return const LoadingWidget(message: 'Loading contacts...');
          }

          if (state is ContactsPermissionDenied) {
            return _PermissionDeniedView(
              onRetry: () =>
                  context.read<ContactsBloc>().add(const LoadContacts()),
            );
          }

          if (state is ContactsFailure) {
            return _ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<ContactsBloc>().add(const LoadContacts()),
            );
          }

          if (state is ContactsLoaded) {
            return _ContactsListView(state: state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─── Contacts list ───────────────────────────────────────────────────────────

class _ContactsListView extends StatelessWidget {
  const _ContactsListView({required this.state});

  final ContactsLoaded state;

  @override
  Widget build(BuildContext context) {
    final contacts = state.contacts;

    if (contacts.isEmpty) {
      return const Center(
        child: Text(
          'No contacts with valid phone numbers found.',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: contacts.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final contact = contacts[index];
              final isSelected = state.selectedContact == contact;
              return _ContactTile(
                contact: contact,
                isSelected: isSelected,
                onTap: () => context
                    .read<ContactsBloc>()
                    .add(ToggleContactSelection(contact: contact)),
              );
            },
          ),
        ),
        _AddButton(state: state),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.contact,
    required this.isSelected,
    required this.onTap,
  });

  final ContactModel contact;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: AppTheme.primary,
        child: Text(
          contact.initials,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        contact.displayName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        contact.phoneNumber,
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
      trailing: Checkbox(
        value: isSelected,
        onChanged: (_) => onTap(),
        activeColor: AppTheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.state});

  final ContactsLoaded state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: PrimaryButton(
        label: state.selectedContact == null ? 'Select a Contact' : 'Add',
        isLoading: state.isAddingContact,
        onPressed: state.selectedContact == null
            ? null
            : () => context.read<ContactsBloc>().add(const AddContact()),
      ),
    );
  }
}

// ─── Permission denied ────────────────────────────────────────────────────────

class _PermissionDeniedView extends StatelessWidget {
  const _PermissionDeniedView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.contacts_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Contacts permission is required\nto use this feature.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Grant Permission', onPressed: onRetry),
          ],
        ),
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
