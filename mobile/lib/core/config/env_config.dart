import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Environment configuration read from `--dart-define` compile flags.
///
/// Usage (emulator):
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
///
/// Usage (physical device — replace with your machine's LAN IP):
///   flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8080
class EnvConfig {
  const EnvConfig._();

  /// Base URL for the Spring Boot backend REST API.
  static String get apiBaseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb) return 'http://localhost:8080';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  /// Base URL for the FastAPI AI service (internal, not called from Mobile directly).
  static String get aiServiceBaseUrl {
    const fromEnv = String.fromEnvironment('AI_SERVICE_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb) return 'http://localhost:8000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://localhost:8000';
  }

  /// Application environment label: `dev`, `staging`, `prod`.
  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  /// Whether to enable verbose Dio request/response logging.
  static bool get isDebugLogging => environment != 'prod';
}

/// Riverpod provider exposing [EnvConfig] into the DI graph.
/// Useful for widgets/services that need to read configuration reactively.
final envConfigProvider = Provider<EnvConfig>(
  (_) => const EnvConfig._(),
  name: 'envConfigProvider',
);
