import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/application/auth_controller.dart';
import '../config/env_config.dart';
import 'auth_interceptor.dart';
import 'token_storage.dart';

/// Configured [Dio] instance for communicating with the Spring Boot backend.
///
/// Timeouts:
///   - connectTimeout: 10 s
///   - receiveTimeout: 30 s (longer for AI-backed endpoints)
///   - sendTimeout:    10 s
///
/// Interceptor order:
///   1. [AuthInterceptor]  — attaches Bearer token, handles 401 → single-flight refresh
///   2. [LogInterceptor]   — logs in debug mode only
final dioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);

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

  final authInterceptor = AuthInterceptor.withStorage(
    tokenStorage: tokenStorage,
    refreshApi: (refreshToken) async {
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: EnvConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      final res = await refreshDio.post<Map<String, dynamic>>(
        '/api/v1/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = res.data;
      final newAccessToken =
          data?['accessToken'] as String? ??
          data?['data']?['accessToken'] as String? ??
          '';
      final newRefreshToken =
          data?['refreshToken'] as String? ??
          data?['data']?['refreshToken'] as String?;
      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        await tokenStorage.rotateTokens(
          newAccessToken: newAccessToken,
          newRefreshToken: newRefreshToken,
        );
      }
      return newAccessToken;
    },
    onSessionExpired: () async {
      await ref.read(authProvider.notifier).logout(revokeRemote: false);
    },
  );

  dio.interceptors.addAll([
    authInterceptor,
    if (EnvConfig.isDebugLogging)
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint('[Dio] $obj'),
      ),
  ]);

  return dio;
}, name: 'dioProvider');
