import 'package:dio/dio.dart';
import 'dio_provider.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  final Dio _dio = DioProvider.instance;

  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _extractMessage(e);
    }
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _extractMessage(e);
    }
  }

  String _extractMessage(DioException e) {
    if (e.error is String) return e.error as String;
    return e.message ?? 'Unexpected error occurred.';
  }
}
