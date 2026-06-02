import '../model/user_model.dart';

// ignore: unused_import
import '../../../core/network/api_client.dart';
// ignore: unused_import
import '../../../core/constants/api_constants.dart';
import '../../../core/storage/local_storage.dart';

class RegisterRepository {
  const RegisterRepository();

  Future<UserModel> register(String mobileNumber) async {
    // ── DUMMY DATA ──────────────────────────────────────────────
    // Replace the block below with the real API call when backend is ready:
    //
    // final response = await ApiClient.instance.post(
    //   ApiConstants.registerEndpoint,
    //   data: {'mobileNumber': mobileNumber},
    // );
    // final user = UserModel.fromJson(response);
    // ────────────────────────────────────────────────────────────

    await Future.delayed(const Duration(milliseconds: 800)); // simulate latency

    final user = UserModel(
      userId: 'USR_${mobileNumber.substring(mobileNumber.length - 4)}',
      mobileNumber: mobileNumber,
    );

    await LocalStorage.saveUser(
      userId: user.userId,
      mobileNumber: user.mobileNumber,
    );

    return user;
  }
}
