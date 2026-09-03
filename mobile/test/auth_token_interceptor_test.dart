import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viegym/core/network/auth_interceptor.dart';
import 'package:viegym/core/network/token_storage.dart';
import 'package:viegym/features/auth/application/auth_controller.dart';
import 'package:viegym/features/auth/data/auth_repository.dart';
import 'package:viegym/features/auth/domain/auth_state.dart';

import 'helpers/fake_auth_repository.dart';

void main() {
  group('TokenStorage (ADR-004) Unit Tests', () {
    late DefaultTokenStorage storage;

    setUp(() {
      storage = DefaultTokenStorage();
    });

    test(
      'Access token is stored in memory and refresh token in secure storage',
      () async {
        expect(await storage.getAccessToken(), isNull);
        expect(await storage.getRefreshToken(), isNull);
        expect(await storage.hasRefreshToken(), isFalse);

        await storage.saveTokens(
          accessToken: 'access_jwt_123',
          refreshToken: 'refresh_secure_456',
        );

        expect(await storage.getAccessToken(), 'access_jwt_123');
        expect(await storage.getRefreshToken(), 'refresh_secure_456');
        expect(await storage.hasRefreshToken(), isTrue);
      },
    );

    test('updateAccessToken only mutates in-memory access token', () async {
      await storage.saveTokens(
        accessToken: 'old_access',
        refreshToken: 'saved_refresh',
      );

      await storage.updateAccessToken('new_access');

      expect(await storage.getAccessToken(), 'new_access');
      expect(await storage.getRefreshToken(), 'saved_refresh');
    });

    test(
      'rotateTokens updates both access token and secure refresh token',
      () async {
        await storage.saveTokens(
          accessToken: 'initial_access',
          refreshToken: 'initial_refresh',
        );

        await storage.rotateTokens(
          newAccessToken: 'rotated_access',
          newRefreshToken: 'rotated_refresh',
        );

        expect(await storage.getAccessToken(), 'rotated_access');
        expect(await storage.getRefreshToken(), 'rotated_refresh');
      },
    );

    test(
      'clearTokens completely wipes in-memory and secure credentials',
      () async {
        await storage.saveTokens(
          accessToken: 'valid_access',
          refreshToken: 'valid_refresh',
        );

        await storage.clearTokens();

        expect(await storage.getAccessToken(), isNull);
        expect(await storage.getRefreshToken(), isNull);
        expect(await storage.hasRefreshToken(), isFalse);
      },
    );
  });

  group('AuthInterceptor Single-Flight & Concurrency Tests', () {
    test(
      'Attaches Authorization Bearer header when access token is present',
      () async {
        final storage = DefaultTokenStorage();
        await storage.saveTokens(
          accessToken: 'my_bearer_token',
          refreshToken: 'my_refresh_token',
        );

        final interceptor = AuthInterceptor(
          getAccessToken: storage.getAccessToken,
          getRefreshToken: storage.getRefreshToken,
          refreshAccessToken: (_) async => 'new_token',
          onRefreshFailed: () async {},
        );

        final options = RequestOptions(path: '/api/v1/profile');
        final handler = _TestRequestInterceptorHandler();

        await interceptor.onRequest(options, handler);

        expect(options.headers['Authorization'], 'Bearer my_bearer_token');
      },
    );

    test(
      'Does not attach bearer token to public exercise catalog GET',
      () async {
        final storage = DefaultTokenStorage();
        await storage.saveTokens(
          accessToken: 'invalid_or_expired_token',
          refreshToken: 'refresh_token',
        );

        final interceptor = AuthInterceptor(
          getAccessToken: storage.getAccessToken,
          getRefreshToken: storage.getRefreshToken,
          refreshAccessToken: (_) async => 'new_token',
          onRefreshFailed: () async {},
        );
        final options = RequestOptions(path: '/api/v1/exercises');
        final handler = _TestRequestInterceptorHandler();

        await interceptor.onRequest(options, handler);

        expect(options.headers.containsKey('Authorization'), isFalse);
      },
    );

    test('Does not attach stale bearer token to public login POST', () async {
      final storage = DefaultTokenStorage();
      await storage.saveTokens(
        accessToken: 'stale_token',
        refreshToken: 'refresh_token',
      );
      final interceptor = AuthInterceptor(
        getAccessToken: storage.getAccessToken,
        getRefreshToken: storage.getRefreshToken,
        refreshAccessToken: (_) async => 'new_token',
        onRefreshFailed: () async {},
      );
      final options = RequestOptions(
        path: '/api/v1/auth/login',
        method: 'POST',
      );

      await interceptor.onRequest(options, _TestRequestInterceptorHandler());

      expect(options.headers.containsKey('Authorization'), isFalse);
    });

    test(
      'Single-Flight: 5 concurrent 401 requests trigger ONLY 1 refresh API call',
      () async {
        final storage = DefaultTokenStorage();
        await storage.saveTokens(
          accessToken: 'expired_access_token',
          refreshToken: 'valid_refresh_token',
        );

        int refreshCallCount = 0;

        final interceptor = AuthInterceptor(
          getAccessToken: storage.getAccessToken,
          getRefreshToken: storage.getRefreshToken,
          refreshAccessToken: (refreshToken) async {
            refreshCallCount++;
            await Future<void>.delayed(const Duration(milliseconds: 50));
            return 'refreshed_access_token_789';
          },
          onRefreshFailed: () async {},
        );

        // Simulate 5 simultaneous requests receiving 401 Unauthorized
        final futures = List.generate(5, (index) async {
          final err = DioException(
            requestOptions: RequestOptions(path: '/api/v1/data/$index'),
            response: Response(
              requestOptions: RequestOptions(path: '/api/v1/data/$index'),
              statusCode: 401,
            ),
          );
          final handler = _TestErrorInterceptorHandler();
          await interceptor.onError(err, handler);
          return handler;
        });

        await Future.wait(futures);

        // Verify single-flight mutex: Exactly 1 network refresh call was made
        expect(refreshCallCount, 1);
      },
    );

    test(
      'Refresh failure triggers onRefreshFailed and clears credentials',
      () async {
        final storage = DefaultTokenStorage();
        await storage.saveTokens(
          accessToken: 'expired_access_token',
          refreshToken: 'revoked_refresh_token',
        );

        bool onRefreshFailedCalled = false;

        final interceptor = AuthInterceptor.withStorage(
          tokenStorage: storage,
          refreshApi: (_) async =>
              throw Exception('Refresh token expired/revoked'),
          onSessionExpired: () async {
            onRefreshFailedCalled = true;
          },
        );

        final err = DioException(
          requestOptions: RequestOptions(path: '/api/v1/profile'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/v1/profile'),
            statusCode: 401,
          ),
        );
        final handler = _TestErrorInterceptorHandler();

        await interceptor.onError(err, handler);

        expect(onRefreshFailedCalled, isTrue);
        expect(await storage.getAccessToken(), isNull);
        expect(await storage.getRefreshToken(), isNull);
      },
    );

    test(
      '401 on /auth/refresh endpoint does not trigger recursive refresh loop',
      () async {
        int refreshCallCount = 0;
        final storage = DefaultTokenStorage();

        final interceptor = AuthInterceptor(
          getAccessToken: storage.getAccessToken,
          getRefreshToken: storage.getRefreshToken,
          refreshAccessToken: (_) async {
            refreshCallCount++;
            return 'new_token';
          },
          onRefreshFailed: () async {},
        );

        final err = DioException(
          requestOptions: RequestOptions(path: '/api/v1/auth/refresh'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/v1/auth/refresh'),
            statusCode: 401,
          ),
        );
        final handler = _TestErrorInterceptorHandler();

        await interceptor.onError(err, handler);

        expect(refreshCallCount, 0);
      },
    );
  });

  group('AuthController & TokenStorage Integration Tests', () {
    test('login saves tokens and logout clears tokens from storage', () async {
      final storage = DefaultTokenStorage();
      final repository = FakeAuthRepository();
      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(storage),
          authRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(authProvider.notifier);

      expect(await storage.hasRefreshToken(), isFalse);

      final loginSuccess = await controller.login(
        email: 'athlete@viegym.vn',
        password: 'Password123',
      );

      expect(loginSuccess, isTrue);
      expect(await storage.hasRefreshToken(), isTrue);
      expect(await storage.getAccessToken(), isNotNull);

      // Logout clears credentials
      await controller.logout();

      expect(container.read(authProvider).status, AuthStatus.unauthenticated);
      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
      expect(await storage.hasRefreshToken(), isFalse);
    });

    test(
      'restoreSession restores authenticated user when refresh token exists in secure storage',
      () async {
        final storage = DefaultTokenStorage();
        final repository = FakeAuthRepository()
          ..currentEmail = 'testuser@viegym.vn';
        await storage.saveTokens(
          accessToken: 'cached_access',
          refreshToken: 'real-refresh-token',
        );

        final container = ProviderContainer(
          overrides: [
            tokenStorageProvider.overrideWithValue(storage),
            authRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(container.dispose);

        final controller = container.read(authProvider.notifier);

        final restored = await controller.restoreSession();

        expect(restored, isTrue);
        final state = container.read(authProvider);
        expect(state.status, AuthStatus.authenticated);
        expect(state.user?.email, 'testuser@viegym.vn');
        expect(await storage.getAccessToken(), isNotNull);
      },
    );
  });
}

class _TestRequestInterceptorHandler extends RequestInterceptorHandler {
  RequestOptions? resolvedOptions;

  @override
  void next(RequestOptions requestOptions) {
    resolvedOptions = requestOptions;
  }
}

class _TestErrorInterceptorHandler extends ErrorInterceptorHandler {
  DioException? resolvedError;
  Response<dynamic>? resolvedResponse;

  @override
  void next(DioException err) {
    resolvedError = err;
  }

  @override
  void resolve(Response<dynamic> response) {
    resolvedResponse = response;
  }
}
