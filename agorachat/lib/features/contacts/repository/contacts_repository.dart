import 'package:flutter_contacts/flutter_contacts.dart';
import '../model/contact_model.dart';
import '../model/chat_channel_model.dart';
import '../../../core/utils/phone_number_utils.dart';
import '../../../core/storage/local_storage.dart';

// ignore: unused_import
import '../../../core/network/api_client.dart';
// ignore: unused_import
import '../../../core/constants/api_constants.dart';

class ContactsRepository {
  const ContactsRepository();

  /// Fetches device contacts and maps them to [ContactModel].
  Future<List<ContactModel>> fetchDeviceContacts() async {
    final contacts = await FlutterContacts.getContacts(
      withProperties: true,
    );

    final result = <ContactModel>[];

    for (final contact in contacts) {
      for (final phone in contact.phones) {
        final normalized = PhoneNumberUtils.normalize(phone.number);
        if (normalized != null) {
          result.add(
            ContactModel.fromRaw(
              displayName: contact.displayName,
              phoneNumber: normalized,
            ),
          );
        }
      }
    }

    return result;
  }

  /// Checks if a contact is registered and creates/fetches the chat channel.
  Future<ChatChannelModel> checkAndCreate(String contactNumber) async {
    // ── DUMMY DATA ──────────────────────────────────────────────
    // Replace with real API call when backend is ready:
    //
    // final response = await ApiClient.instance.post(
    //   ApiConstants.checkAndCreateEndpoint,
    //   data: {
    //     'currentUserId': LocalStorage.userId,
    //     'contactNumber': contactNumber,
    //   },
    // );
    // return ChatChannelModel.fromJson(response);
    // ────────────────────────────────────────────────────────────

    await Future.delayed(const Duration(milliseconds: 800));

    final currentUserId = LocalStorage.userId ?? 'USR_SELF';
    final receiverUserId = 'USR_${contactNumber.substring(contactNumber.length - 4)}';

    // Simulates a registered response — toggle `registered: false` to test unregistered flow.
    return ChatChannelModel.fromJson({
      'registered': true,
      'currentUserId': currentUserId,
      'receiverUserId': receiverUserId,
      'channelName': 'chat_${currentUserId}_$receiverUserId',
      'chatToken': 'DUMMY_CHAT_TOKEN',
      'voiceCallToken': 'DUMMY_VOICE_CALL_TOKEN',
    });
  }
}
