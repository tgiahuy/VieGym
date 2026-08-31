enum OtpPurpose {
  register,
  passwordReset,
  loginVerify;

  String get displayName {
    switch (this) {
      case OtpPurpose.register:
        return 'Xác thực đăng ký';
      case OtpPurpose.passwordReset:
        return 'Xác thực đặt lại mật khẩu';
      case OtpPurpose.loginVerify:
        return 'Xác thực đăng nhập';
    }
  }

  String get subtitle {
    switch (this) {
      case OtpPurpose.register:
        return 'Nhập mã 6 chữ số để kích hoạt tài khoản VieGym';
      case OtpPurpose.passwordReset:
        return 'Nhập mã 6 chữ số để tiếp tục đặt lại mật khẩu mới';
      case OtpPurpose.loginVerify:
        return 'Nhập mã bảo mật 6 chữ số để đăng nhập an toàn';
    }
  }
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.phoneNumber,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String displayName;
  final String? phoneNumber;
  final String? avatarUrl;
}

enum AuthStatus {
  unauthenticated,
  authenticating,
  authenticated,
  pendingVerification,
  error,
}

class AuthState {
  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.user,
    this.errorMessage,
    this.pendingEmail,
    this.pendingPurpose = OtpPurpose.register,
    this.resendCooldownSeconds = 0,
  });

  final AuthStatus status;
  final AuthUser? user;
  final String? errorMessage;
  final String? pendingEmail;
  final OtpPurpose pendingPurpose;
  final int resendCooldownSeconds;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.authenticating;
  bool get isPendingVerification => status == AuthStatus.pendingVerification;

  /// Helper to mask email address, e.g. `n***@gmail.com`
  static String maskEmail(String email) {
    if (!email.contains('@')) return email;
    final parts = email.split('@');
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) {
      return '${name[0]}***@$domain';
    }
    return '${name[0]}***${name[name.length - 1]}@$domain';
  }

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? errorMessage,
    String? pendingEmail,
    OtpPurpose? pendingPurpose,
    int? resendCooldownSeconds,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      pendingEmail: pendingEmail ?? this.pendingEmail,
      pendingPurpose: pendingPurpose ?? this.pendingPurpose,
      resendCooldownSeconds:
          resendCooldownSeconds ?? this.resendCooldownSeconds,
    );
  }
}
