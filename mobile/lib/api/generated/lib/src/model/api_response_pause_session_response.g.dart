// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_pause_session_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponsePauseSessionResponseCWProxy {
  ApiResponsePauseSessionResponse success(bool? success);

  ApiResponsePauseSessionResponse message(String? message);

  ApiResponsePauseSessionResponse data(PauseSessionResponse? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponsePauseSessionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponsePauseSessionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponsePauseSessionResponse call({
    bool? success,
    String? message,
    PauseSessionResponse? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponsePauseSessionResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponsePauseSessionResponse.copyWith.fieldName(...)`
class _$ApiResponsePauseSessionResponseCWProxyImpl
    implements _$ApiResponsePauseSessionResponseCWProxy {
  const _$ApiResponsePauseSessionResponseCWProxyImpl(this._value);

  final ApiResponsePauseSessionResponse _value;

  @override
  ApiResponsePauseSessionResponse success(bool? success) =>
      this(success: success);

  @override
  ApiResponsePauseSessionResponse message(String? message) =>
      this(message: message);

  @override
  ApiResponsePauseSessionResponse data(PauseSessionResponse? data) =>
      this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponsePauseSessionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponsePauseSessionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponsePauseSessionResponse call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponsePauseSessionResponse(
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
          : data as PauseSessionResponse?,
    );
  }
}

extension $ApiResponsePauseSessionResponseCopyWith
    on ApiResponsePauseSessionResponse {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponsePauseSessionResponse.copyWith(...)` or like so:`instanceOfApiResponsePauseSessionResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponsePauseSessionResponseCWProxy get copyWith =>
      _$ApiResponsePauseSessionResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponsePauseSessionResponse _$ApiResponsePauseSessionResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApiResponsePauseSessionResponse', json, ($checkedConvert) {
  final val = ApiResponsePauseSessionResponse(
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    data: $checkedConvert(
      'data',
      (v) => v == null
          ? null
          : PauseSessionResponse.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ApiResponsePauseSessionResponseToJson(
  ApiResponsePauseSessionResponse instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
