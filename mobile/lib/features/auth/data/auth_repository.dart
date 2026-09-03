import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return DioAuthRepository(ref.watch(dioProvider));
});

abstract class AuthRepository {
  Future<AuthSession> login({required String email, required String password});

  Future<AuthSession> loginWithGoogle(String idToken);

  Future<AuthSession> loginWithFacebook(String accessToken);

  Future<AuthChallenge> register({
    required String displayName,
    required String email,
    required String password,
  });

  Future<AuthSession> verifyOtp({
    required String challengeId,
    required String purpose,
    required String code,
  });

  Future<AuthChallenge> resendOtp({
    required String challengeId,
    required String purpose,
  });

  Future<AuthChallenge> forgotPassword(String email);

  Future<void> resetPassword({
    required String resetProof,
    required String newPassword,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<AuthSession> refresh(String refreshToken);

  Future<void> logout(String refreshToken);

  Future<AuthUserProfile> getCurrentUser();
}

class DioAuthRepository implements AuthRepository {
  const DioAuthRepository(this._dio);

  final Dio _dio;
  static const _deviceInfo = 'viegym-mobile';

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    return _sessionFrom(
      await _post('/api/v1/auth/login', {
        'email': email.trim(),
        'password': password,
        'deviceInfo': _deviceInfo,
      }),
    );
  }

  @override
  Future<AuthSession> loginWithGoogle(String idToken) async {
    return _sessionFrom(
      await _post('/api/v1/auth/google', {
        'idToken': idToken,
        'deviceInfo': _deviceInfo,
      }),
    );
  }

  @override
  Future<AuthSession> loginWithFacebook(String accessToken) async {
    return _sessionFrom(
      await _post('/api/v1/auth/facebook', {
        'accessToken': accessToken,
        'deviceInfo': _deviceInfo,
      }),
    );
  }

  @override
  Future<AuthChallenge> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    return _challengeFrom(
      await _post('/api/v1/auth/register', {
        'displayName': displayName.trim(),
        'email': email.trim(),
        'password': password,
      }),
    );
  }

  @override
  Future<AuthSession> verifyOtp({
    required String challengeId,
    required String purpose,
    required String code,
  }) async {
    return _sessionFrom(
      await _post('/api/v1/auth/otp/verify', {
        'challengeId': challengeId,
        'purpose': purpose,
        'code': code,
      }),
    );
  }

  @override
  Future<AuthChallenge> resendOtp({
    required String challengeId,
    required String purpose,
  }) async {
    return _challengeFrom(
      await _post('/api/v1/auth/otp/resend', {
        'challengeId': challengeId,
        'purpose': purpose,
      }),
    );
  }

  @override
  Future<AuthChallenge> forgotPassword(String email) async {
    return _challengeFrom(
      await _post('/api/v1/auth/password/forgot', {'email': email.trim()}),
    );
  }

  @override
  Future<void> resetPassword({
    required String resetProof,
    required String newPassword,
  }) async {
    await _post('/api/v1/auth/password/reset', {
      'resetProof': resetProof,
      'newPassword': newPassword,
    });
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _post('/api/v1/auth/password/change', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  @override
  Future<AuthSession> refresh(String refreshToken) async {
    return _sessionFrom(
      await _post('/api/v1/auth/refresh', {
        'refreshToken': refreshToken,
        'deviceInfo': _deviceInfo,
      }),
    );
  }

  @override
  Future<void> logout(String refreshToken) async {
    await _post('/api/v1/auth/logout', {'refreshToken': refreshToken});
  }

  @override
  Future<AuthUserProfile> getCurrentUser() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/api/v1/users/me');
      final data = _responseData(response.data);
      final onboarding = data['onboarding'] as Map<String, dynamic>?;
      return AuthUserProfile(
        id: data['id']?.toString() ?? '',
        email: data['email'] as String? ?? '',
        displayName: data['displayName'] as String? ?? '',
        avatarUrl:
            (data['avatar'] as Map<String, dynamic>?)?['accessUrl'] as String?,
        healthProfileCompleted:
            onboarding?['healthProfileCompleted'] as bool? ?? false,
        equipmentCompleted: onboarding?['equipmentCompleted'] as bool? ?? false,
      );
    } on DioException catch (error) {
      throw AuthApiException.fromDio(error);
    }
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: body);
      return _responseData(response.data);
    } on DioException catch (error) {
      throw AuthApiException.fromDio(error);
    }
  }

  static Map<String, dynamic> _responseData(Map<String, dynamic>? body) {
    final data = body?['data'];
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  static AuthSession _sessionFrom(Map<String, dynamic> data) {
    return AuthSession(
      accessToken: data['accessToken'] as String?,
      refreshToken: data['refreshToken'] as String?,
      resetProof: data['resetProof'] as String?,
    );
  }

  static AuthChallenge _challengeFrom(Map<String, dynamic> data) {
    return AuthChallenge(
      challengeId: data['challengeId'] as String? ?? '',
      maskedDestination: data['maskedDestination'] as String? ?? '',
    );
  }
}

class AuthSession {
  const AuthSession({this.accessToken, this.refreshToken, this.resetProof});

  final String? accessToken;
  final String? refreshToken;
  final String? resetProof;
}

class AuthChallenge {
  const AuthChallenge({
    required this.challengeId,
    required this.maskedDestination,
  });

  final String challengeId;
  final String maskedDestination;
}

class AuthUserProfile {
  const AuthUserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.healthProfileCompleted = false,
    this.equipmentCompleted = false,
  });

  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final bool healthProfileCompleted;
  final bool equipmentCompleted;
}

class AuthApiException implements Exception {
  const AuthApiException({required this.code, required this.message});

  factory AuthApiException.fromDio(DioException error) {
    final body = error.response?.data;
    final map = body is Map<String, dynamic> ? body : null;
    return AuthApiException(
      code: map?['code'] as String? ?? 'NETWORK_ERROR',
      message: map?['message'] as String? ?? 'Không thể kết nối đến máy chủ',
    );
  }

  final String code;
  final String message;
}
