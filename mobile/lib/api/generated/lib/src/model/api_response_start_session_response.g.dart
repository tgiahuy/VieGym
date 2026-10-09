// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_start_session_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponseStartSessionResponseCWProxy {
  ApiResponseStartSessionResponse success(bool? success);

  ApiResponseStartSessionResponse message(String? message);

  ApiResponseStartSessionResponse data(StartSessionResponse? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseStartSessionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseStartSessionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseStartSessionResponse call({
    bool? success,
    String? message,
    StartSessionResponse? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponseStartSessionResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponseStartSessionResponse.copyWith.fieldName(...)`
class _$ApiResponseStartSessionResponseCWProxyImpl
    implements _$ApiResponseStartSessionResponseCWProxy {
  const _$ApiResponseStartSessionResponseCWProxyImpl(this._value);

  final ApiResponseStartSessionResponse _value;

  @override
  ApiResponseStartSessionResponse success(bool? success) =>
      this(success: success);

  @override
  ApiResponseStartSessionResponse message(String? message) =>
      this(message: message);

  @override
  ApiResponseStartSessionResponse data(StartSessionResponse? data) =>
      this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseStartSessionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseStartSessionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseStartSessionResponse call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponseStartSessionResponse(
      success: success == const $CopyWithPlaceholder()
          ? _value.success
          // ignore: cast_nullable_to_non_nullable
          : success as bool?,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String?,
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as StartSessionResponse?,
    );
  }
}

extension $ApiResponseStartSessionResponseCopyWith
    on ApiResponseStartSessionResponse {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponseStartSessionResponse.copyWith(...)` or like so:`instanceOfApiResponseStartSessionResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponseStartSessionResponseCWProxy get copyWith =>
      _$ApiResponseStartSessionResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseStartSessionResponse _$ApiResponseStartSessionResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApiResponseStartSessionResponse', json, ($checkedConvert) {
  final val = ApiResponseStartSessionResponse(
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    data: $checkedConvert(
      'data',
      (v) => v == null
          ? null
          : StartSessionResponse.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ApiResponseStartSessionResponseToJson(
  ApiResponseStartSessionResponse instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
