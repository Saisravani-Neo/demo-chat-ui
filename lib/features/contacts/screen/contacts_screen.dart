import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../widgets/common_text_field.dart';
import '../../../core/utils/phone_number_utils.dart';

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
            icon: const Icon(Icons.person_add),
            tooltip: 'Add Manually',
            onPressed: () => showAddManualContactDialog(context),
          ),
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
            context.push(
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.people_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No contacts with valid phone numbers found.',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => showAddManualContactDialog(context),
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
            ],
          ),
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
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => showAddManualContactDialog(context),
              icon: const Icon(Icons.person_add, color: AppTheme.primary),
              label: const Text(
                'Add Contact Manually',
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

void showAddManualContactDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return _AddManualContactDialog(
        contactsBloc: context.read<ContactsBloc>(),
      );
    },
  );
}

class _AddManualContactDialog extends StatefulWidget {
  const _AddManualContactDialog({required this.contactsBloc});

  final ContactsBloc contactsBloc;

  @override
  State<_AddManualContactDialog> createState() => _AddManualContactDialogState();
}

class _AddManualContactDialogState extends State<_AddManualContactDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    widget.contactsBloc.add(AddManualContact(
      name: name,
      phoneNumber: phone,
    ));

    Navigator.pop(context);
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
          onPressed: () => Navigator.pop(context),
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
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
