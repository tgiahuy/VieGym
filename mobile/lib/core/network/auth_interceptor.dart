import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  // In M2, this will interact with secure storage and refresh token logic
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: Add Authorization header if token exists
    // final token = ...
    // if (token != null) {
    //   options.headers['Authorization'] = 'Bearer $token';
    // }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // TODO: Handle 401 Unauthorized for refresh token logic in M2
    super.onError(err, handler);
  }
}
