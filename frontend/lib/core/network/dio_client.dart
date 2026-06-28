import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class DioClient {
  static Dio create() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.timeout,
      receiveTimeout: ApiConstants.timeout,
      headers: {'Accept': 'application/json'},
    ));

    dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
    ));

    return dio;
  }

  DioClient._();
}
