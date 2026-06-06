import 'package:flutter_bloc/flutter_bloc.dart';
import 'contacts_event.dart';
import 'contacts_state.dart';
import '../repository/contacts_repository.dart';
import '../../../core/utils/permission_utils.dart';
import '../../../core/storage/local_storage.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  ContactsBloc({required this.repository}) : super(const ContactsInitial()) {
    on<LoadContacts>(_onLoadContacts);
    on<ToggleContactSelection>(_onToggleSelection);
    on<AddContact>(_onAddContact);
    on<AddManualContact>(_onAddManualContact);
  }

  final ContactsRepository repository;

  Future<void> _onLoadContacts(
    LoadContacts event,
    Emitter<ContactsState> emit,
  ) async {
    emit(const ContactsLoading());

    final granted = await PermissionUtils.requestContacts();
    if (!granted) {
      emit(const ContactsPermissionDenied());
      return;
    }

    try {
      final contacts = await repository.fetchDeviceContacts();
      emit(ContactsLoaded(contacts: contacts));
    } catch (e) {
      emit(ContactsFailure(message: e.toString()));
    }
  }

  void _onToggleSelection(
    ToggleContactSelection event,
    Emitter<ContactsState> emit,
  ) {
    final current = state;
    if (current is! ContactsLoaded) return;

    final isSame = current.selectedContact == event.contact;
    emit(current.copyWith(
      selectedContact: isSame ? null : event.contact,
      clearSelection: isSame,
    ));
  }

  Future<void> _onAddContact(
    AddContact event,
    Emitter<ContactsState> emit,
  ) async {
    final current = state;
    if (current is! ContactsLoaded) return;

    final selected = current.selectedContact;
    if (selected == null) return;

    emit(current.copyWith(isAddingContact: true));

    try {
      final channel = await repository.checkAndCreate(selected.phoneNumber);

      if (!channel.registered) {
        emit(const ContactNotRegistered());
        // Restore loaded state so the UI remains interactive
        emit(current.copyWith(isAddingContact: false));
        return;
      }

      // Cache details in LocalStorage for conversation history lookup
      if (channel.receiverUserId != null) {
        await LocalStorage.saveContactName(channel.receiverUserId!, selected.displayName);
        if (channel.channelName != null) {
          await LocalStorage.saveChannelName(channel.receiverUserId!, channel.channelName!);
        }
        if (channel.chatToken != null) {
          await LocalStorage.saveChatToken(channel.chatToken!);
        }
      }

      emit(ContactsNavigateToChat(
        channel: channel,
        contactName: selected.displayName,
      ));
    } catch (e) {
      emit(ContactsFailure(message: e.toString()));
      emit(current.copyWith(isAddingContact: false));
    }
  }

  Future<void> _onAddManualContact(
    AddManualContact event,
    Emitter<ContactsState> emit,
  ) async {
    final current = state;

    if (current is ContactsLoaded) {
      emit(current.copyWith(isAddingContact: true));
    }

    try {
      final channel = await repository.checkAndCreate(event.phoneNumber);

      if (!channel.registered) {
        emit(const ContactNotRegistered());
        emit(current);
        return;
      }

      // Cache details in LocalStorage for conversation history lookup
      if (channel.receiverUserId != null) {
        await LocalStorage.saveContactName(channel.receiverUserId!, event.name);
        if (channel.channelName != null) {
          await LocalStorage.saveChannelName(channel.receiverUserId!, channel.channelName!);
        }
        if (channel.chatToken != null) {
          await LocalStorage.saveChatToken(channel.chatToken!);
        }
      }

      emit(ContactsNavigateToChat(
        channel: channel,
        contactName: event.name,
      ));
    } catch (e) {
      emit(ContactsFailure(message: e.toString()));
      emit(current);
    }
  }
}
