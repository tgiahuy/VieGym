import 'package:dio/dio.dart';

/// Maps [DioException] and backend error envelopes to human-readable messages.
///
/// Backend error envelope shape (from API Spec):
/// ```json
/// {
///   "success": false,
///   "code":    "VALIDATION_ERROR",
///   "message": "Dữ liệu không hợp lệ",
///   "details": { "field": "reason" }
/// }
/// ```
class ApiError {
  const ApiError({
    required this.message,
    this.code,
    this.details,
    this.statusCode,
  });

  final String message;
  final String? code;
  final Map<String, dynamic>? details;
  final int? statusCode;

  @override
  String toString() => 'ApiError[$code/$statusCode]: $message';
}

class ApiErrorHandler {
  ApiErrorHandler._();

  /// Parses [error] into an [ApiError].
  static ApiError parse(dynamic error) {
    if (error is DioException) {
      return _fromDio(error);
    }
    return ApiError(message: error.toString());
  }

  /// Returns a user-facing message string.
  static String getMessage(dynamic error) => parse(error).message;

  // ── Private helpers ──────────────────────────────────────────────────────

  static ApiError _fromDio(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiError(
          code: 'TIMEOUT',
          message: 'Kết nối quá thời gian. Vui lòng thử lại.',
        );

      case DioExceptionType.connectionError:
        return const ApiError(
          code: 'NO_CONNECTION',
          message: 'Không có kết nối mạng.',
        );

      case DioExceptionType.badResponse:
        return _fromResponse(err.response);

      case DioExceptionType.cancel:
        return const ApiError(
          code: 'CANCELLED',
          message: 'Yêu cầu đã bị huỷ.',
        );

      case DioExceptionType.unknown:
      default:
        return ApiError(
          code: 'UNKNOWN',
          message: err.message ?? 'Đã xảy ra lỗi không xác định.',
        );
    }
  }

  static ApiError _fromResponse(Response<dynamic>? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    // Try to parse backend error envelope
    if (data is Map<String, dynamic>) {
      final message = data['message'] as String?;
      final code = data['code'] as String?;
      final details = data['details'] as Map<String, dynamic>?;
      if (message != null) {
        return ApiError(
          message: message,
          code: code,
          details: details,
          statusCode: statusCode,
        );
      }
    }

    // Fallback to HTTP status code description
    return ApiError(
      code: 'HTTP_$statusCode',
      message: _httpMessage(statusCode),
      statusCode: statusCode,
    );
  }

  static String _httpMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Yêu cầu không hợp lệ.';
      case 401:
        return 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
      case 403:
        return 'Bạn không có quyền thực hiện thao tác này.';
      case 404:
        return 'Không tìm thấy tài nguyên.';
      case 409:
        return 'Xung đột dữ liệu. Vui lòng thử lại.';
      case 422:
        return 'Dữ liệu không hợp lệ.';
      case 429:
        return 'Quá nhiều yêu cầu. Vui lòng chờ và thử lại.';
      case 500:
        return 'Lỗi máy chủ nội bộ.';
      case 503:
        return 'Dịch vụ tạm thời không khả dụng.';
      default:
        return 'Lỗi máy chủ: $statusCode';
    }
  }
}
