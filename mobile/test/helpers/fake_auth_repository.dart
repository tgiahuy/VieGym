import 'package:viegym/features/auth/data/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  String currentEmail = 'test@viegym.vn';
  String currentDisplayName = 'Test Athlete';
  bool rejectLogin = false;
  int logoutCalls = 0;

  AuthSession get _session => const AuthSession(
    accessToken: 'test.jwt.access',
    refreshToken: 'test-refresh-token',
  );

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    if (rejectLogin || email.startsWith('unknown')) {
      throw const AuthApiException(
        code: 'INVALID_CREDENTIALS',
        message: 'Invalid credentials',
      );
    }
    currentEmail = email;
    currentDisplayName = email.split('@').first;
    return _session;
  }

  @override
  Future<AuthSession> loginWithGoogle(String idToken) async {
    currentEmail = 'google@viegym.vn';
    currentDisplayName = 'Google Athlete';
    return _session;
  }

  @override
  Future<AuthSession> loginWithFacebook(String accessToken) async {
    currentEmail = 'facebook@viegym.vn';
    currentDisplayName = 'Facebook Athlete';
    return _session;
  }

  @override
  Future<AuthChallenge> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    currentEmail = email;
    currentDisplayName = displayName;
    return const AuthChallenge(
      challengeId: 'otp_1',
      maskedDestination: 't***@viegym.vn',
    );
  }

  @override
  Future<AuthSession> verifyOtp({
    required String challengeId,
    required String purpose,
    required String code,
  }) async {
    if (purpose == 'PASSWORD_RESET') {
      return const AuthSession(resetProof: 'reset-proof');
    }
    return _session;
  }

  @override
  Future<AuthChallenge> resendOtp({
    required String challengeId,
    required String purpose,
  }) async {
    return const AuthChallenge(
      challengeId: 'otp_2',
      maskedDestination: 't***@viegym.vn',
    );
  }

  @override
  Future<AuthChallenge> forgotPassword(String email) async {
    currentEmail = email;
    return const AuthChallenge(
      challengeId: 'otp_reset',
      maskedDestination: 'r***@viegym.vn',
    );
  }

  @override
  Future<void> resetPassword({
    required String resetProof,
    required String newPassword,
  }) async {}

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {}

  @override
  Future<AuthSession> refresh(String refreshToken) async => _session;

  @override
  Future<void> logout(String refreshToken) async {
    logoutCalls++;
  }

  @override
  Future<AuthUserProfile> getCurrentUser() async {
    return AuthUserProfile(
      id: 'user_1',
      email: currentEmail,
      displayName: currentDisplayName,
    );
  }
}
