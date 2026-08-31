import 'dart:async';

import 'package:dio/dio.dart';

/// Dio interceptor that:
///   1. Attaches the `Authorization: Bearer <token>` header on every request
///      when a valid access token is available (wired in M2 via secure storage).
///   2. Intercepts `401 Unauthorized` responses and performs a **single-flight**
///      token refresh — concurrent requests that hit 401 simultaneously wait for
///      the same refresh call instead of each launching their own.
///   3. Retries the original request once with the new access token.
///   4. Clears credentials and propagates the error if the refresh also fails,
///      triggering re-login (navigation handled in M2 via session notifier).
///
/// The actual token storage (`FlutterSecureStorage`) and refresh API call are
/// injected via callbacks to keep this class unit-testable and storage-agnostic.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.getAccessToken,
    required this.getRefreshToken,
    required this.refreshAccessToken,
    required this.onRefreshFailed,
  });

  /// Returns the current access token, or `null` if not authenticated.
  final Future<String?> Function() getAccessToken;

  /// Returns the current refresh token, or `null` if not available.
  final Future<String?> Function() getRefreshToken;

  /// Exchanges [refreshToken] for a new access token.
  /// Returns the new access token on success, or throws on failure.
  final Future<String> Function(String refreshToken) refreshAccessToken;

  /// Called when the refresh attempt fails — the app should clear credentials
  /// and redirect to the login screen.
  final Future<void> Function() onRefreshFailed;

  /// Single-flight mutex: the in-progress refresh completer.
  Completer<String>? _refreshCompleter;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await getAccessToken();
    if (token != null) {
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

    // Only handle 401 from the backend (not from the refresh endpoint itself
    // to avoid infinite loops).
    final isUnauthorized = response?.statusCode == 401;
    final isRefreshPath =
        response?.requestOptions.path.contains('/auth/refresh') ?? false;

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

    _refreshCompleter = Completer<String>();
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }
      final newToken = await refreshAccessToken(refreshToken);
      _refreshCompleter!.complete(newToken);
      return newToken;
    } catch (e) {
      _refreshCompleter!.completeError(e);
      rethrow;
    } finally {
      _refreshCompleter = null;
    }
  }
}

/// Stub implementation used during M1 before M2 wires real storage.
/// All callbacks are no-ops that return null / throw immediately.
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
