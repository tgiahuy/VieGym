import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/env_config.dart';
import 'auth_interceptor.dart';

/// Configured [Dio] instance for communicating with the Spring Boot backend.
///
/// Timeouts:
///   - connectTimeout: 10 s
///   - receiveTimeout: 30 s (longer for AI-backed endpoints)
///   - sendTimeout:    10 s
///
/// Interceptor order:
///   1. [AuthInterceptor]  — attaches Bearer token, handles 401 → refresh
///   2. [LogInterceptor]   — logs in debug mode only
final dioProvider = Provider<Dio>((ref) {
  final options = BaseOptions(
    baseUrl: EnvConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 10),
    headers: const {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  final dio = Dio(options);

  dio.interceptors.addAll([
    // M1: stub interceptor — replaced with real AuthInterceptor in M2
    StubAuthInterceptor(),
    if (EnvConfig.isDebugLogging)
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint('[Dio] $obj'),
      ),
  ]);

  return dio;
}, name: 'dioProvider');
