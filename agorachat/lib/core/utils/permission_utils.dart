import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  PermissionUtils._();

  static Future<bool> requestContacts() async {
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  static Future<bool> requestMicrophone() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Requests both contacts and microphone permissions.
  static Future<Map<Permission, PermissionStatus>> requestAll() async {
    return await [
      Permission.contacts,
      Permission.microphone,
    ].request();
  }

  static Future<bool> isContactsGranted() async =>
      await Permission.contacts.isGranted;

  static Future<bool> isMicrophoneGranted() async =>
      await Permission.microphone.isGranted;

  /// Opens app settings for the user to manually grant permissions.
  static Future<void> openSettings() async => openAppSettings();
}
