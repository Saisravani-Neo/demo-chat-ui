import 'package:agorachat/features/register/model/user_model.dart';
import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/storage/local_storage.dart';
import '../../contacts/model/verify_contact_model.dart';
import '../../contacts/model/user_token_response.dart';


class RegisterRepository {
  const RegisterRepository();

  Future<RegisterUserResponse> registerUser({
    required String mobileNumber,
  }) async {
    try {
      final response = await DioProvider.instance.post(
        ApiConstants.registerEndpoint,
        data: {
          'mobileNumber': mobileNumber,
        },
      );

      final result = RegisterUserResponse.fromJson(response.data);

      await LocalStorage.saveUser(
        userId: result.userId,
        mobileNumber: result.mobileNumber,
      );

      return result;
    } on DioException catch (e) {
      throw Exception(e.error.toString());
    } catch (e) {
      throw Exception('Failed to register user.');
    }
  }

  Future<VerifyContactResponse> loginUser({
    required String mobileNumber,
  }) async {
    try {
      final response = await DioProvider.instance.post(
        ApiConstants.verifyContactEndpoint,
        data: {
          'mobileNumber': mobileNumber,
        },
      );

      final verifyJson = Map<String, dynamic>.from(response.data);
      final result = VerifyContactResponse.fromJson(
        verifyJson['data'] != null
            ? Map<String, dynamic>.from(verifyJson['data'])
            : verifyJson,
      );

      if (!result.registered) {
        throw Exception('User is not registered. Please register first.');
      }

      await LocalStorage.saveUser(
        userId: result.userId ?? '',
        mobileNumber: result.mobileNumber ?? '',
      );

      // Now fetch and save the Agora chatToken!
      final tokenRes = await DioProvider.instance.get(
        ApiConstants.agoraUserTokenEndpoint(result.userId ?? ''),
      );
      final tokenJson = Map<String, dynamic>.from(tokenRes.data);
      final tokenObj = UserTokenResponse.fromJson(
        tokenJson['data'] != null
            ? Map<String, dynamic>.from(tokenJson['data'])
            : tokenJson,
      );

      if (tokenObj.token.isNotEmpty) {
        await LocalStorage.saveChatToken(tokenObj.token);
      }

      return result;
    } on DioException catch (e) {
      throw Exception(e.error.toString());
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}