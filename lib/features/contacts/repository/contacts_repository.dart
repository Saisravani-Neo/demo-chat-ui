import 'package:agorachat/features/chat/model/chat_response.dart';
import 'package:agorachat/features/contacts/model/user_token_response.dart';
import 'package:agorachat/features/contacts/model/verify_contact_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';

import '../model/contact_model.dart';
import '../model/chat_channel_model.dart';
import '../../../core/utils/phone_number_utils.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/constants/api_constants.dart';

class ContactsRepository {
  const ContactsRepository();

  Future<List<ContactModel>> fetchDeviceContacts() async {
    final contacts = await FlutterContacts.getContacts(withProperties: true);

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

  Future<ChatChannelModel> checkAndCreate(String contactNumber) async {
    try {
      // Step 1: Verify contact
      final verifyRes = await DioProvider.instance.post(
        ApiConstants.verifyContactEndpoint,
        data: {
          'mobileNumber': contactNumber,
        },
      );

      final verifyJson = Map<String, dynamic>.from(verifyRes.data);

      final verify = VerifyContactResponse.fromJson(
        verifyJson['data'] != null
            ? Map<String, dynamic>.from(verifyJson['data'])
            : verifyJson,
      );

      if (!verify.registered) {
        return ChatChannelModel.fromJson({
          'registered': false,
          'currentUserId': LocalStorage.userId,
          'receiverUserId': null,
          'channelName': null,
          'chatToken': null,
          'voiceCallToken': null,
        });
      }

      final senderUserId = LocalStorage.userId ?? '';
      final receiverUserId = verify.userId ?? '';

      // Check if we already have this conversation and its channelName cached
      final existingConversation = await ChatClient.getInstance.chatManager.getConversation(
        receiverUserId,
        createIfNeed: false,
      );
      final cachedChannelName = LocalStorage.getChannelName(receiverUserId);

      if (existingConversation != null && cachedChannelName != null && cachedChannelName.isNotEmpty) {
        final tokenRes = await DioProvider.instance.get(
          ApiConstants.agoraUserTokenEndpoint(senderUserId),
        );
        final tokenJson = Map<String, dynamic>.from(tokenRes.data);
        final token = UserTokenResponse.fromJson(
          tokenJson['data'] != null
              ? Map<String, dynamic>.from(tokenJson['data'])
              : tokenJson,
        );

        return ChatChannelModel(
          registered: true,
          currentUserId: senderUserId,
          receiverUserId: receiverUserId,
          channelName: cachedChannelName,
          chatToken: token.token,
          voiceCallToken: '',
        );
      }

      // Step 2: Create chat room
      final roomRes = await DioProvider.instance.post(
        ApiConstants.createChatRoomEndpoint,
        data: {
          'senderUserId': senderUserId,
          'receiverUserId': receiverUserId,
        },
      );

      final roomJson = Map<String, dynamic>.from(roomRes.data);

      final room = CreateChatRoomResponse.fromJson(
        roomJson['data'] != null
            ? Map<String, dynamic>.from(roomJson['data'])
            : roomJson,
      );

      final tokenRes = await DioProvider.instance.get(
        ApiConstants.agoraUserTokenEndpoint(senderUserId),
      );

      final tokenJson = Map<String, dynamic>.from(tokenRes.data);

      final token = UserTokenResponse.fromJson(
        tokenJson['data'] != null
            ? Map<String, dynamic>.from(tokenJson['data'])
            : tokenJson,
      );

      return ChatChannelModel.fromJson({
        'registered': true,
        'currentUserId': senderUserId,
        'receiverUserId': receiverUserId,
        'channelName': room.channelName,
        'chatToken': token.token,
        'voiceCallToken': '',
      });
    } on DioException catch (e) {
      throw Exception(e.error.toString());
    } catch (e) {
      throw Exception('Failed to create chat room.');
    }
  }
}
