import 'package:equatable/equatable.dart';
import '../model/contact_model.dart';

abstract class ContactsEvent extends Equatable {
  const ContactsEvent();

  @override
  List<Object?> get props => [];
}

/// Load device contacts after permission is granted.
class LoadContacts extends ContactsEvent {
  const LoadContacts();
}

/// Toggle selection state of a contact.
class ToggleContactSelection extends ContactsEvent {
  const ToggleContactSelection({required this.contact});

  final ContactModel contact;

  @override
  List<Object?> get props => [contact];
}

/// Initiate chat with the selected contact.
class AddContact extends ContactsEvent {
  const AddContact();
}
