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

enum AuthStatus { unauthenticated, authenticating, authenticated, error }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.user,
    this.errorMessage,
    this.pendingEmail,
  });

  final AuthStatus status;
  final AuthUser? user;
  final String? errorMessage;
  final String? pendingEmail;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.authenticating;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? errorMessage,
    String? pendingEmail,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      pendingEmail: pendingEmail ?? this.pendingEmail,
    );
  }
}
