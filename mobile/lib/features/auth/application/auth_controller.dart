import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/auth_state.dart';

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.authenticating);
    await Future<void>.delayed(const Duration(milliseconds: 200));

    if (email.trim().isEmpty || password.isEmpty) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Vui lòng điền đầy đủ email và mật khẩu.',
      );
      return false;
    }

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

    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      pendingEmail: email.trim(),
    );
    return true;
  }

  Future<bool> verifyOtp(String code) async {
    state = state.copyWith(status: AuthStatus.authenticating);
    await Future<void>.delayed(const Duration(milliseconds: 150));

    if (code == '123456' || code.length == 6) {
      final email = state.pendingEmail ?? 'user@viegym.vn';
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
      status: AuthStatus.unauthenticated,
      pendingEmail: email.trim(),
    );
    return true;
  }

  void updateDisplayName(String displayName) {
    if (state.user != null) {
      state = state.copyWith(
        user: AuthUser(
          id: state.user!.id,
          email: state.user!.email,
          displayName: displayName.trim(),
          avatarUrl: state.user!.avatarUrl,
        ),
      );
    }
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
