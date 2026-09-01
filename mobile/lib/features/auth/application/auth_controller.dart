import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/token_storage.dart';
import '../domain/auth_state.dart';

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.authenticating);
    await Future<void>.delayed(const Duration(milliseconds: 200));

    if (email.trim().isEmpty || password.isEmpty) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Vui lòng điền đầy đủ email và mật khẩu.',
      );
      return false;
    }

    // Xử lý case tài khoản pending nếu email chứa 'pending' (demo/testing hook)
    if (email.toLowerCase().contains('pending')) {
      state = state.copyWith(
        status: AuthStatus.pendingVerification,
        pendingEmail: email.trim(),
        pendingPurpose: OtpPurpose.register,
        errorMessage: 'Tài khoản chưa kích hoạt. Vui lòng xác thực OTP.',
      );
      return false;
    }

    // Lưu token theo chuẩn ADR-004: access token (memory), refresh token (secure storage)
    await ref
        .read(tokenStorageProvider)
        .saveTokens(
          accessToken: 'viegym_jwt_access_${email.trim().replaceAll('@', '_')}',
          refreshToken:
              'viegym_secure_refresh_${email.trim().replaceAll('@', '_')}',
        );

    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: AuthUser(
        id: 'user_123',
        email: email.trim(),
        displayName: email.split('@').first,
      ),
    );
    return true;
  }

  /// Đăng nhập bằng Google ID Token
  Future<bool> loginWithGoogle({String? idToken}) async {
    state = state.copyWith(status: AuthStatus.authenticating);
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final effectiveToken = idToken ?? 'mock_google_id_token';
    if (effectiveToken.isEmpty) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Xác thực Google thất bại.',
      );
      return false;
    }

    const email = 'google.athlete@viegym.vn';
    await ref
        .read(tokenStorageProvider)
        .saveTokens(
          accessToken: 'viegym_jwt_access_google_${email.replaceAll('@', '_')}',
          refreshToken:
              'viegym_secure_refresh_google_${email.replaceAll('@', '_')}',
        );

    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: const AuthUser(
        id: 'google_user_1',
        email: email,
        displayName: 'Google Athlete',
      ),
    );
    return true;
  }

  /// Đăng nhập bằng Facebook Access Token
  Future<bool> loginWithFacebook({String? accessToken}) async {
    state = state.copyWith(status: AuthStatus.authenticating);
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final effectiveToken = accessToken ?? 'mock_facebook_access_token';
    if (effectiveToken.isEmpty) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Xác thực Facebook thất bại.',
      );
      return false;
    }

    const email = 'facebook.athlete@viegym.vn';
    await ref
        .read(tokenStorageProvider)
        .saveTokens(
          accessToken: 'viegym_jwt_access_fb_${email.replaceAll('@', '_')}',
          refreshToken:
              'viegym_secure_refresh_fb_${email.replaceAll('@', '_')}',
        );

    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: const AuthUser(
        id: 'fb_user_1',
        email: email,
        displayName: 'Facebook Athlete',
      ),
    );
    return true;
  }

  Future<bool> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.authenticating);
    await Future<void>.delayed(const Duration(milliseconds: 200));

    if (email.trim().isEmpty || password.isEmpty) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Vui lòng điền đầy đủ thông tin.',
      );
      return false;
    }

    if (password != confirmPassword) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Mật khẩu xác nhận không khớp.',
      );
      return false;
    }

    // Backend tạo account pending -> Chờ xác thực OTP (MH06)
    state = state.copyWith(
      status: AuthStatus.pendingVerification,
      pendingEmail: email.trim(),
      pendingPurpose: OtpPurpose.register,
    );
    return true;
  }

  Future<bool> verifyOtp(String code, {OtpPurpose? purpose}) async {
    state = state.copyWith(status: AuthStatus.authenticating);
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final targetPurpose = purpose ?? state.pendingPurpose;

    if (code == '123456' || code.length == 6) {
      final email = state.pendingEmail ?? 'user@viegym.vn';

      if (targetPurpose == OtpPurpose.passwordReset) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          pendingEmail: email,
        );
        return true;
      }

      // Lưu token vào TokenStorage theo ADR-004
      await ref
          .read(tokenStorageProvider)
          .saveTokens(
            accessToken: 'viegym_jwt_access_${email.replaceAll('@', '_')}',
            refreshToken: 'viegym_secure_refresh_${email.replaceAll('@', '_')}',
          );

      // Xác thực đăng ký thành công -> Cấp session authenticated
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: AuthUser(
          id: 'user_123',
          email: email,
          displayName: email.split('@').first,
        ),
      );
      return true;
    }

    state = state.copyWith(
      status: AuthStatus.error,
      errorMessage: 'Mã OTP không chính xác hoặc đã hết hạn.',
    );
    return false;
  }

  Future<bool> resendOtp({String? email, OtpPurpose? purpose}) async {
    state = state.copyWith(status: AuthStatus.authenticating);
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final targetEmail = email ?? state.pendingEmail ?? 'user@viegym.vn';
    final targetPurpose = purpose ?? state.pendingPurpose;

    state = state.copyWith(
      status: AuthStatus.pendingVerification,
      pendingEmail: targetEmail,
      pendingPurpose: targetPurpose,
      resendCooldownSeconds: 60,
    );
    return true;
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
    state = state.copyWith(status: AuthStatus.authenticating);
    await Future<void>.delayed(const Duration(milliseconds: 150));

    if (email.trim().isEmpty) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Vui lòng nhập địa chỉ email.',
      );
      return false;
    }

    state = state.copyWith(
      status: AuthStatus.pendingVerification,
      pendingEmail: email.trim(),
      pendingPurpose: OtpPurpose.passwordReset,
    );
    return true;
  }

  void updateDisplayName(String displayName) {
    final current = state.user;
    state = state.copyWith(
      user: AuthUser(
        id: current?.id ?? 'user_123',
        email: current?.email ?? 'viegym.user@gmail.com',
        displayName: displayName.trim(),
        phoneNumber: current?.phoneNumber,
        avatarUrl: current?.avatarUrl,
      ),
    );
  }

  void updateProfile({required String displayName, String? phoneNumber}) {
    final current = state.user;
    state = state.copyWith(
      user: AuthUser(
        id: current?.id ?? 'user_123',
        email: current?.email ?? 'viegym.user@gmail.com',
        displayName: displayName.trim(),
        phoneNumber: phoneNumber?.trim(),
        avatarUrl: current?.avatarUrl,
      ),
    );
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.authenticating);
    await Future<void>.delayed(const Duration(milliseconds: 200));

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Vui lòng điền đầy đủ mật khẩu mới.',
      );
      return false;
    }

    if (newPassword != confirmPassword) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Mật khẩu xác nhận không khớp.',
      );
      return false;
    }

    if (newPassword.length < 6) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Mật khẩu mới phải có ít nhất 6 ký tự.',
      );
      return false;
    }

    // Reset password success -> chuyển về unauthenticated để đăng nhập lại
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      pendingEmail: null,
    );
    return true;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.authenticating);
    await Future<void>.delayed(const Duration(milliseconds: 200));

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Vui lòng điền đầy đủ các trường mật khẩu.',
      );
      return false;
    }

    if (newPassword != confirmPassword) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Mật khẩu xác nhận không khớp.',
      );
      return false;
    }

    if (newPassword.length < 6) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Mật khẩu mới phải có ít nhất 6 ký tự.',
      );
      return false;
    }

    state = state.copyWith(status: AuthStatus.authenticated);
    return true;
  }

  Future<void> logout() async {
    // Xóa sạch credential trên storage theo ADR-004
    await ref.read(tokenStorageProvider).clearTokens();
    state = const AuthState();
  }

  /// Bootstrap khôi phục phiên làm việc từ secure storage
  Future<bool> restoreSession() async {
    // Nếu phiên đã được khởi tạo/xác thực sẵn trong bộ nhớ (ví dụ do test override hoặc in-memory state)
    if (state.status == AuthStatus.authenticated && state.user != null) {
      return true;
    }

    final hasToken = await ref.read(tokenStorageProvider).hasRefreshToken();
    if (!hasToken) {
      state = const AuthState();
      return false;
    }

    final refreshToken = await ref.read(tokenStorageProvider).getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      state = const AuthState();
      return false;
    }

    // Khôi phục access token vào memory
    final restoredEmail = refreshToken
        .replaceFirst('viegym_secure_refresh_', '')
        .replaceAll('_', '@');
    await ref
        .read(tokenStorageProvider)
        .updateAccessToken(
          'viegym_jwt_access_${restoredEmail.replaceAll('@', '_')}',
        );

    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: AuthUser(
        id: 'user_123',
        email: restoredEmail.contains('@')
            ? restoredEmail
            : 'viegym.user@gmail.com',
        displayName:
            (restoredEmail.contains('@')
                    ? restoredEmail
                    : 'viegym.user@gmail.com')
                .split('@')
                .first,
      ),
    );
    return true;
  }
}

final authProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
