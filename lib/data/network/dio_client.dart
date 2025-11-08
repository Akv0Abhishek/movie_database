import 'package:dio/dio.dart';
import '../../utils/constants.dart';

class DioClient {
  final Dio dio;

  DioClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: TMDB_BASE_URL,
            queryParameters: {'api_key': TMDB_API_KEY},
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        ) {
    // Add interceptors or logging if needed
    dio.interceptors.add(LogInterceptor(responseBody: false, requestBody: false));
  }
}
