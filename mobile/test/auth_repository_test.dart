import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viegym/features/auth/data/auth_repository.dart';

void main() {
  test(
    'DioAuthRepository parses real backend session and profile envelopes',
    () async {
      final adapter = _AuthApiAdapter();
      final dio = Dio()..httpClientAdapter = adapter;
      final repository = DioAuthRepository(dio);

      final session = await repository.login(
        email: 'athlete@viegym.vn',
        password: 'Password123',
      );
      final profile = await repository.getCurrentUser();

      expect(session.accessToken, 'signed.jwt');
      expect(session.refreshToken, 'opaque-refresh');
      expect(profile.id, '42');
      expect(profile.email, 'athlete@viegym.vn');
      expect(profile.healthProfileCompleted, isTrue);
      expect(profile.equipmentCompleted, isTrue);
      expect(adapter.lastLoginBody?['deviceInfo'], 'viegym-mobile');
    },
  );

  test('DioAuthRepository preserves backend auth error codes', () async {
    final dio = Dio()..httpClientAdapter = _AuthApiAdapter(rejectLogin: true);
    final repository = DioAuthRepository(dio);

    expect(
      () => repository.login(
        email: 'unknown@viegym.vn',
        password: 'WrongPassword123',
      ),
      throwsA(
        isA<AuthApiException>().having(
          (error) => error.code,
          'code',
          'INVALID_CREDENTIALS',
        ),
      ),
    );
  });
}

class _AuthApiAdapter implements HttpClientAdapter {
  _AuthApiAdapter({this.rejectLogin = false});

  final bool rejectLogin;
  Map<String, dynamic>? lastLoginBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/api/v1/auth/login') {
      lastLoginBody = options.data as Map<String, dynamic>?;
      if (rejectLogin) {
        return _jsonResponse(401, {
          'success': false,
          'code': 'INVALID_CREDENTIALS',
          'message': 'Invalid credentials',
          'errors': <dynamic>[],
        });
      }
      return _jsonResponse(200, {
        'success': true,
        'message': 'Operation successful',
        'data': {
          'accessToken': 'signed.jwt',
          'refreshToken': 'opaque-refresh',
          'tokenType': 'Bearer',
          'expiresIn': 900,
          'resetProof': null,
        },
      });
    }

    if (options.path == '/api/v1/users/me') {
      return _jsonResponse(200, {
        'success': true,
        'data': {
          'id': 42,
          'email': 'athlete@viegym.vn',
          'displayName': 'Athlete',
          'avatar': null,
          'onboarding': {
            'healthProfileCompleted': true,
            'equipmentCompleted': true,
          },
        },
      });
    }

    return _jsonResponse(404, {'message': 'Not found'});
  }

  ResponseBody _jsonResponse(int statusCode, Map<String, dynamic> body) {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
