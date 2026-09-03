import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/token_storage.dart';
import '../data/auth_repository.dart';
import '../domain/auth_state.dart';

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  AuthRepository get _repository => ref.read(authRepositoryProvider);
  TokenStorage get _storage => ref.read(tokenStorageProvider);

  Future<bool> login({required String email, required String password}) async {
    if (email.trim().isEmpty || password.isEmpty) {
      return _validationError('Vui lòng điền đầy đủ email và mật khẩu.');
    }
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final session = await _repository.login(email: email, password: password);
      await _completeAuthentication(session);
      return true;
    } on AuthApiException catch (error) {
      return _apiError(error);
    } catch (_) {
      return _validationError('Không thể kết nối đến máy chủ.');
    }
  }

  Future<bool> loginWithGoogle({String? idToken}) async {
    if (idToken == null || idToken.trim().isEmpty) {
      return _validationError(
        'Đăng nhập Google chưa được cấu hình trên thiết bị này.',
      );
    }
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final session = await _repository.loginWithGoogle(idToken.trim());
      await _completeAuthentication(session);
      return true;
    } on AuthApiException catch (error) {
      return _apiError(error);
    } catch (_) {
      return _validationError('Không thể xác thực tài khoản Google.');
    }
  }

  Future<bool> loginWithFacebook({String? accessToken}) async {
    if (accessToken == null || accessToken.trim().isEmpty) {
      return _validationError(
        'Đăng nhập Facebook chưa được cấu hình trên thiết bị này.',
      );
    }
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final session = await _repository.loginWithFacebook(accessToken.trim());
      await _completeAuthentication(session);
      return true;
    } on AuthApiException catch (error) {
      return _apiError(error);
    } catch (_) {
      return _validationError('Không thể xác thực tài khoản Facebook.');
    }
  }

  Future<bool> register({
    String? displayName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      return _validationError('Vui lòng điền đầy đủ thông tin.');
    }
    if (password != confirmPassword) {
      return _validationError('Mật khẩu xác nhận không khớp.');
    }
    if (!_isStrongPassword(password)) {
      return _validationError(
        'Mật khẩu phải có ít nhất 8 ký tự, gồm chữ và số.',
      );
    }
    final effectiveName = displayName?.trim().isNotEmpty == true
        ? displayName!.trim()
        : email.trim().split('@').first;
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final challenge = await _repository.register(
        displayName: effectiveName,
        email: email,
        password: password,
      );
      state = state.copyWith(
        status: AuthStatus.pendingVerification,
        pendingEmail: email.trim(),
        pendingPurpose: OtpPurpose.register,
        pendingChallengeId: challenge.challengeId,
        resendCooldownSeconds: 60,
      );
      return true;
    } on AuthApiException catch (error) {
      return _apiError(error);
    } catch (_) {
      return _validationError('Không thể kết nối đến máy chủ.');
    }
  }

  Future<bool> verifyOtp(String code, {OtpPurpose? purpose}) async {
    final challengeId = state.pendingChallengeId;
    if (challengeId == null || challengeId.isEmpty) {
      return _validationError('Phiên xác thực OTP không hợp lệ.');
    }
    if (code.length != 6) {
      return _validationError('Mã OTP phải gồm 6 chữ số.');
    }
    final targetPurpose = purpose ?? state.pendingPurpose;
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final session = await _repository.verifyOtp(
        challengeId: challengeId,
        purpose: _purposeCode(targetPurpose),
        code: code,
      );
      if (targetPurpose == OtpPurpose.passwordReset) {
        if (session.resetProof == null || session.resetProof!.isEmpty) {
          return _validationError(
            'Máy chủ không trả về bằng chứng đặt lại mật khẩu.',
          );
        }
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          resetProof: session.resetProof,
        );
      } else {
        await _completeAuthentication(session);
      }
      return true;
    } on AuthApiException catch (error) {
      return _apiError(error);
    } catch (_) {
      return _validationError('Không thể xác thực OTP.');
    }
  }

  Future<bool> resendOtp({String? email, OtpPurpose? purpose}) async {
    final challengeId = state.pendingChallengeId;
    if (challengeId == null || challengeId.isEmpty) {
      return _validationError('Phiên xác thực OTP không hợp lệ.');
    }
    final targetPurpose = purpose ?? state.pendingPurpose;
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final challenge = await _repository.resendOtp(
        challengeId: challengeId,
        purpose: _purposeCode(targetPurpose),
      );
      state = state.copyWith(
        status: AuthStatus.pendingVerification,
        pendingEmail: email?.trim() ?? state.pendingEmail,
        pendingPurpose: targetPurpose,
        pendingChallengeId: challenge.challengeId,
        resendCooldownSeconds: 60,
      );
      return true;
    } on AuthApiException catch (error) {
      return _apiError(error);
    } catch (_) {
      return _validationError('Không thể gửi lại mã OTP.');
    }
  }

  void setPendingVerification({
    required String email,
    required OtpPurpose purpose,
  }) {
    state = state.copyWith(
      status: AuthStatus.pendingVerification,
      pendingEmail: email.trim(),
      pendingPurpose: purpose,
    );
  }

  Future<bool> forgotPassword(String email) async {
    if (email.trim().isEmpty) {
      return _validationError('Vui lòng nhập địa chỉ email.');
    }
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final challenge = await _repository.forgotPassword(email.trim());
      state = state.copyWith(
        status: AuthStatus.pendingVerification,
        pendingEmail: email.trim(),
        pendingPurpose: OtpPurpose.passwordReset,
        pendingChallengeId: challenge.challengeId,
        resendCooldownSeconds: 60,
      );
      return true;
    } on AuthApiException catch (error) {
      return _apiError(error);
    } catch (_) {
      return _validationError('Không thể gửi yêu cầu đặt lại mật khẩu.');
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword != confirmPassword) {
      return _validationError('Mật khẩu xác nhận không khớp.');
    }
    if (!_isStrongPassword(newPassword)) {
      return _validationError(
        'Mật khẩu phải có ít nhất 8 ký tự, gồm chữ và số.',
      );
    }
    final proof = state.resetProof;
    if (proof == null || proof.isEmpty) {
      return _validationError('Phiên đặt lại mật khẩu đã hết hạn.');
    }
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      await _repository.resetPassword(
        resetProof: proof,
        newPassword: newPassword,
      );
      await _storage.clearTokens();
      state = const AuthState();
      return true;
    } on AuthApiException catch (error) {
      return _apiError(error);
    } catch (_) {
      return _validationError('Không thể đặt lại mật khẩu.');
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      return _validationError('Vui lòng điền đầy đủ các trường mật khẩu.');
    }
    if (newPassword != confirmPassword) {
      return _validationError('Mật khẩu xác nhận không khớp.');
    }
    if (!_isStrongPassword(newPassword)) {
      return _validationError(
        'Mật khẩu phải có ít nhất 8 ký tự, gồm chữ và số.',
      );
    }
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      await _storage.clearTokens();
      state = const AuthState();
      return true;
    } on AuthApiException catch (error) {
      return _apiError(error);
    } catch (_) {
      return _validationError('Không thể đổi mật khẩu.');
    }
  }

  void updateDisplayName(String displayName) {
    final current = state.user;
    if (current == null) return;
    state = state.copyWith(
      user: AuthUser(
        id: current.id,
        email: current.email,
        displayName: displayName.trim(),
        phoneNumber: current.phoneNumber,
        avatarUrl: current.avatarUrl,
      ),
    );
  }

  void updateProfile({required String displayName, String? phoneNumber}) {
    final current = state.user;
    if (current == null) return;
    state = state.copyWith(
      user: AuthUser(
        id: current.id,
        email: current.email,
        displayName: displayName.trim(),
        phoneNumber: phoneNumber?.trim(),
        avatarUrl: current.avatarUrl,
      ),
    );
  }

  Future<void> logout({bool revokeRemote = true}) async {
    final refreshToken = await _storage.getRefreshToken();
    if (revokeRemote && refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _repository.logout(refreshToken);
      } catch (_) {
        // Local logout must always succeed when the server is unavailable.
      }
    }
    await _storage.clearTokens();
    state = const AuthState();
  }

  Future<bool> restoreSession() async {
    if (state.status == AuthStatus.authenticated && state.user != null) {
      return true;
    }

    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        state = const AuthState();
        return false;
      }
      state = state.copyWith(status: AuthStatus.authenticating);
      final session = await _repository.refresh(refreshToken);
      await _completeAuthentication(session);
      return true;
    } catch (_) {
      try {
        await _storage.clearTokens();
      } catch (_) {
        // Platform storage can be unavailable in tests or unsupported targets.
      }
      state = const AuthState();
      return false;
    }
  }

  Future<void> _completeAuthentication(AuthSession session) async {
    final accessToken = session.accessToken;
    final refreshToken = session.refreshToken;
    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      throw const AuthApiException(
        code: 'INVALID_SESSION',
        message: 'Máy chủ trả về phiên đăng nhập không hợp lệ',
      );
    }
    await _storage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    try {
      final profile = await _repository.getCurrentUser();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: AuthUser(
          id: profile.id,
          email: profile.email,
          displayName: profile.displayName,
          avatarUrl: profile.avatarUrl,
          healthProfileCompleted: profile.healthProfileCompleted,
          equipmentCompleted: profile.equipmentCompleted,
        ),
      );
    } catch (_) {
      await _storage.clearTokens();
      rethrow;
    }
  }

  bool _validationError(String message) {
    state = state.copyWith(status: AuthStatus.error, errorMessage: message);
    return false;
  }

  bool _apiError(AuthApiException error) {
    state = state.copyWith(
      status: AuthStatus.error,
      errorMessage: _localizedMessage(error),
    );
    return false;
  }

  static bool _isStrongPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Za-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  static String _purposeCode(OtpPurpose purpose) {
    return purpose == OtpPurpose.passwordReset ? 'PASSWORD_RESET' : 'REGISTER';
  }

  static String _localizedMessage(AuthApiException error) {
    return switch (error.code) {
      'INVALID_CREDENTIALS' => 'Email hoặc mật khẩu không chính xác.',
      'ACCOUNT_PENDING' => 'Tài khoản chưa được xác thực.',
      'ACCOUNT_LOCKED' => 'Tài khoản đã bị khóa.',
      'ACCOUNT_DISABLED' => 'Tài khoản đã bị vô hiệu hóa.',
      'EMAIL_ALREADY_EXISTS' => 'Email này đã được đăng ký.',
      'OTP_INVALID' => 'Mã OTP không chính xác.',
      'OTP_EXPIRED' => 'Mã OTP đã hết hạn.',
      'OTP_ATTEMPTS_EXCEEDED' => 'Bạn đã nhập sai OTP quá số lần cho phép.',
      'TOKEN_EXPIRED' ||
      'TOKEN_REVOKED' => 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
      'NETWORK_ERROR' => 'Không thể kết nối đến máy chủ.',
      _ => error.message,
    };
  }
}

final authProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
