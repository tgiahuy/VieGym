import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Secure Token Storage interface following ADR-004:
/// - Access Token: In-memory only (never written to disk/SharedPreferences/logs)
/// - Refresh Token: Stored securely in platform Keystore / Keychain or secure adapter
abstract class TokenStorage {
  /// Retrieves the current in-memory access token, or `null` if expired/absent.
  Future<String?> getAccessToken();

  /// Retrieves the persisted refresh token, or `null` if absent.
  Future<String?> getRefreshToken();

  /// Saves both tokens (access token into memory, refresh token into secure storage).
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Updates only the in-memory access token (e.g. after a single-flight refresh).
  Future<void> updateAccessToken(String newAccessToken);

  /// Rotates the refresh token along with the access token.
  Future<void> rotateTokens({
    required String newAccessToken,
    required String newRefreshToken,
  });

  /// Clears all credentials completely (used on logout, token revocation, or failure).
  Future<void> clearTokens();

  /// Returns true if a refresh token is present in secure storage.
  Future<bool> hasRefreshToken();
}

/// In-memory & secure storage implementation for mobile app.
class DefaultTokenStorage implements TokenStorage {
  DefaultTokenStorage({Map<String, String>? initialSecureStore})
      : _secureStore = initialSecureStore ?? <String, String>{};

  // 1. Access Token is strictly in-memory per ADR-004
  String? _inMemoryAccessToken;

  // 2. Secure storage for Refresh Token (mock/backed by keystore/keychain)
  final Map<String, String> _secureStore;
  static const String _refreshTokenKey = 'viegym_secure_refresh_token';

  @override
  Future<String?> getAccessToken() async => _inMemoryAccessToken;

  @override
  Future<String?> getRefreshToken() async => _secureStore[_refreshTokenKey];

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _inMemoryAccessToken = accessToken;
    _secureStore[_refreshTokenKey] = refreshToken;
  }

  @override
  Future<void> updateAccessToken(String newAccessToken) async {
    _inMemoryAccessToken = newAccessToken;
  }

  @override
  Future<void> rotateTokens({
    required String newAccessToken,
    required String newRefreshToken,
  }) async {
    _inMemoryAccessToken = newAccessToken;
    _secureStore[_refreshTokenKey] = newRefreshToken;
  }

  @override
  Future<void> clearTokens() async {
    _inMemoryAccessToken = null;
    _secureStore.remove(_refreshTokenKey);
  }

  @override
  Future<bool> hasRefreshToken() async {
    final token = _secureStore[_refreshTokenKey];
    return token != null && token.isNotEmpty;
  }
}

/// Provider for TokenStorage dependency injection
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return DefaultTokenStorage();
}, name: 'tokenStorageProvider');
