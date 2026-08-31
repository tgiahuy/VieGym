import 'dart:async';

import 'package:dio/dio.dart';
import 'token_storage.dart';

/// Dio interceptor implementing ADR-004:
///   1. Attaches the `Authorization: Bearer <token>` header on every request
///      when a valid in-memory access token is available.
///   2. Intercepts `401 Unauthorized` responses and performs a **single-flight**
///      token refresh — concurrent requests that hit 401 simultaneously wait for
///      the same refresh call instead of each launching their own.
///   3. Retries the original request once with the new access token.
///   4. Clears credentials via [TokenStorage] and triggers [onRefreshFailed]
///      if the refresh fails, enforcing secure logout.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.getAccessToken,
    required this.getRefreshToken,
    required this.refreshAccessToken,
    required this.onRefreshFailed,
  });

  /// Factory constructing AuthInterceptor with a [TokenStorage] backend.
  factory AuthInterceptor.withStorage({
    required TokenStorage tokenStorage,
    required Future<String> Function(String refreshToken) refreshApi,
    required Future<void> Function() onSessionExpired,
  }) {
    return AuthInterceptor(
      getAccessToken: tokenStorage.getAccessToken,
      getRefreshToken: tokenStorage.getRefreshToken,
      refreshAccessToken: (refreshToken) async {
        final newToken = await refreshApi(refreshToken);
        await tokenStorage.updateAccessToken(newToken);
        return newToken;
      },
      onRefreshFailed: () async {
        await tokenStorage.clearTokens();
        await onSessionExpired();
      },
    );
  }

  /// Returns the current access token, or `null` if not authenticated.
  final Future<String?> Function() getAccessToken;

  /// Returns the current refresh token, or `null` if not available.
  final Future<String?> Function() getRefreshToken;

  /// Exchanges [refreshToken] for a new access token.
  /// Returns the new access token on success, or throws on failure.
  final Future<String> Function(String refreshToken) refreshAccessToken;

  /// Called when the refresh attempt fails — the app clears credentials
  /// and updates session to unauthenticated.
  final Future<void> Function() onRefreshFailed;

  /// Single-flight mutex: the in-progress refresh completer.
  Completer<String>? _refreshCompleter;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;

    // Only handle 401 from backend business endpoints, not from the refresh endpoint
    // to avoid infinite recursion loops.
    final isUnauthorized = response?.statusCode == 401;
    final isRefreshPath = err.requestOptions.path.contains('/auth/refresh');

    if (!isUnauthorized || isRefreshPath) {
      return super.onError(err, handler);
    }

    try {
      final newToken = await _singleFlightRefresh();
      // Retry original request with new token
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newToken';
      final dio = Dio();
      final retryResponse = await dio.fetch<dynamic>(opts);
      return handler.resolve(retryResponse);
    } catch (_) {
      await onRefreshFailed();
      return super.onError(err, handler);
    }
  }

  /// Ensures only one refresh call is in-flight at a time.
  /// Subsequent callers await the same [Completer].
  Future<String> _singleFlightRefresh() async {
    if (_refreshCompleter != null) {
      // Another refresh is already in progress — wait for it.
      return _refreshCompleter!.future;
    }

    final completer = Completer<String>();
    _refreshCompleter = completer;
    // Attach dummy catchError returning empty string to silence unhandled future errors
    completer.future.catchError((Object _) => '');

    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception('No refresh token available');
      }
      final newToken = await refreshAccessToken(refreshToken);
      completer.complete(newToken);
      return newToken;
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _refreshCompleter = null;
    }
  }
}

/// Stub implementation used when storage is disabled or mocked.
class StubAuthInterceptor extends AuthInterceptor {
  StubAuthInterceptor()
    : super(
        getAccessToken: () async => null,
        getRefreshToken: () async => null,
        refreshAccessToken: (_) async =>
            throw Exception('Stub: no token storage'),
        onRefreshFailed: () async {},
      );
}
