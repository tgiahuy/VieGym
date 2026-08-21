import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/env_config.dart';
import 'auth_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final options = BaseOptions(
    baseUrl: EnvConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 10),
    contentType: 'application/json',
  );

  final dio = Dio(options);

  dio.interceptors.addAll([
    AuthInterceptor(),
    LogInterceptor(requestBody: true, responseBody: true),
  ]);

  return dio;
});
