// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_error_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiErrorResponseCWProxy {
  ApiErrorResponse success(bool success);

  ApiErrorResponse code(String code);

  ApiErrorResponse message(String message);

  ApiErrorResponse data(Object? data);

  ApiErrorResponse errors(List<FieldViolation> errors);

  ApiErrorResponse correlationId(String correlationId);

  ApiErrorResponse timestamp(DateTime timestamp);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiErrorResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiErrorResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiErrorResponse call({
    bool success,
    String code,
    String message,
    Object? data,
    List<FieldViolation> errors,
    String correlationId,
    DateTime timestamp,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiErrorResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiErrorResponse.copyWith.fieldName(...)`
class _$ApiErrorResponseCWProxyImpl implements _$ApiErrorResponseCWProxy {
  const _$ApiErrorResponseCWProxyImpl(this._value);

  final ApiErrorResponse _value;

  @override
  ApiErrorResponse success(bool success) => this(success: success);

  @override
  ApiErrorResponse code(String code) => this(code: code);

  @override
  ApiErrorResponse message(String message) => this(message: message);

  @override
  ApiErrorResponse data(Object? data) => this(data: data);

  @override
  ApiErrorResponse errors(List<FieldViolation> errors) => this(errors: errors);

  @override
  ApiErrorResponse correlationId(String correlationId) =>
      this(correlationId: correlationId);

  @override
  ApiErrorResponse timestamp(DateTime timestamp) => this(timestamp: timestamp);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiErrorResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiErrorResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiErrorResponse call({
    Object? success = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
    Object? errors = const $CopyWithPlaceholder(),
    Object? correlationId = const $CopyWithPlaceholder(),
    Object? timestamp = const $CopyWithPlaceholder(),
  }) {
    return ApiErrorResponse(
      success: success == const $CopyWithPlaceholder()
          ? _value.success
          // ignore: cast_nullable_to_non_nullable
          : success as bool,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String,
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as Object?,
      errors: errors == const $CopyWithPlaceholder()
          ? _value.errors
          // ignore: cast_nullable_to_non_nullable
          : errors as List<FieldViolation>,
      correlationId: correlationId == const $CopyWithPlaceholder()
          ? _value.correlationId
          // ignore: cast_nullable_to_non_nullable
          : correlationId as String,
      timestamp: timestamp == const $CopyWithPlaceholder()
          ? _value.timestamp
          // ignore: cast_nullable_to_non_nullable
          : timestamp as DateTime,
    );
  }
}

extension $ApiErrorResponseCopyWith on ApiErrorResponse {
  /// Returns a callable class that can be used as follows: `instanceOfApiErrorResponse.copyWith(...)` or like so:`instanceOfApiErrorResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiErrorResponseCWProxy get copyWith => _$ApiErrorResponseCWProxyImpl(this);
}
