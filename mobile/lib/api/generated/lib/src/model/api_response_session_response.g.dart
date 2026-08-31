// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_session_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponseSessionResponseCWProxy {
  ApiResponseSessionResponse success(bool? success);

  ApiResponseSessionResponse message(String? message);

  ApiResponseSessionResponse data(SessionResponse? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseSessionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseSessionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseSessionResponse call({
    bool? success,
    String? message,
    SessionResponse? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponseSessionResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponseSessionResponse.copyWith.fieldName(...)`
class _$ApiResponseSessionResponseCWProxyImpl
    implements _$ApiResponseSessionResponseCWProxy {
  const _$ApiResponseSessionResponseCWProxyImpl(this._value);

  final ApiResponseSessionResponse _value;

  @override
  ApiResponseSessionResponse success(bool? success) => this(success: success);

  @override
  ApiResponseSessionResponse message(String? message) => this(message: message);

  @override
  ApiResponseSessionResponse data(SessionResponse? data) => this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseSessionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseSessionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseSessionResponse call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponseSessionResponse(
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
          : data as SessionResponse?,
    );
  }
}

extension $ApiResponseSessionResponseCopyWith on ApiResponseSessionResponse {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponseSessionResponse.copyWith(...)` or like so:`instanceOfApiResponseSessionResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponseSessionResponseCWProxy get copyWith =>
      _$ApiResponseSessionResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseSessionResponse _$ApiResponseSessionResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApiResponseSessionResponse', json, ($checkedConvert) {
  final val = ApiResponseSessionResponse(
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    data: $checkedConvert(
      'data',
      (v) => v == null
          ? null
          : SessionResponse.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ApiResponseSessionResponseToJson(
  ApiResponseSessionResponse instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
