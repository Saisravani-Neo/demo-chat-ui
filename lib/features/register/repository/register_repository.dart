import 'package:agorachat/features/register/model/user_model.dart';
import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/storage/local_storage.dart';


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
}