import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class DioProvider {
  DioProvider._();

  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        responseType: ResponseType.json,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );

    dio.interceptors.addAll([
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ),
      _ErrorInterceptor(),
    ]);

    return dio;
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message = 'Something went wrong. Please try again.';

    if (err.type == DioExceptionType.connectionTimeout) {
      message = 'Connection timed out.';
    } else if (err.type == DioExceptionType.receiveTimeout) {
      message = 'Server took too long to respond.';
    } else if (err.type == DioExceptionType.connectionError) {
      message = 'No internet connection. Please check your network.';
    } else if (err.type == DioExceptionType.badResponse) {
      final data = err.response?.data;

      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      } else {
        message = 'Server error (${err.response?.statusCode}).';
      }
    }

    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        error: message,
        type: err.type,
        response: err.response,
      ),
    );
  }
}