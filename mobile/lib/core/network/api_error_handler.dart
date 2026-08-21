import 'package:dio/dio.dart';

class ApiErrorHandler {
  static String getMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Please try again later.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;
          if (data != null && data is Map<String, dynamic> && data['message'] != null) {
            return data['message'];
          }
          if (statusCode != null) {
            return 'Server error: $statusCode';
          }
          return 'Invalid response from server.';
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        case DioExceptionType.connectionError:
          return 'No internet connection.';
        case DioExceptionType.unknown:
        default:
          return 'An unknown error occurred.';
      }
    }
    return error.toString();
  }
}
