import 'package:equatable/equatable.dart';
import '../model/contact_model.dart';
import '../model/chat_channel_model.dart';

abstract class ContactsState extends Equatable {
  const ContactsState();

  @override
  List<Object?> get props => [];
}

class ContactsInitial extends ContactsState {
  const ContactsInitial();
}

class ContactsPermissionDenied extends ContactsState {
  const ContactsPermissionDenied();
}

class ContactsLoading extends ContactsState {
  const ContactsLoading();
}

class ContactsLoaded extends ContactsState {
  const ContactsLoaded({
    required this.contacts,
    this.selectedContact,
    this.isAddingContact = false,
  });

  final List<ContactModel> contacts;
  final ContactModel? selectedContact;
  final bool isAddingContact;

  ContactsLoaded copyWith({
    List<ContactModel>? contacts,
    ContactModel? selectedContact,
    bool clearSelection = false,
    bool? isAddingContact,
  }) {
    return ContactsLoaded(
      contacts: contacts ?? this.contacts,
      selectedContact: clearSelection ? null : (selectedContact ?? this.selectedContact),
      isAddingContact: isAddingContact ?? this.isAddingContact,
    );
  }

  @override
  List<Object?> get props => [contacts, selectedContact, isAddingContact];
}

class ContactsNavigateToChat extends ContactsState {
  const ContactsNavigateToChat({
    required this.channel,
    required this.contactName,
  });

  final ChatChannelModel channel;
  final String contactName;

  @override
  List<Object?> get props => [channel, contactName];
}

class ContactNotRegistered extends ContactsState {
  const ContactNotRegistered();
}

class ContactsFailure extends ContactsState {
  const ContactsFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
