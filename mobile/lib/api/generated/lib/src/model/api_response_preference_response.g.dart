// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_preference_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponsePreferenceResponseCWProxy {
  ApiResponsePreferenceResponse success(bool? success);

  ApiResponsePreferenceResponse message(String? message);

  ApiResponsePreferenceResponse data(PreferenceResponse? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponsePreferenceResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponsePreferenceResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponsePreferenceResponse call({
    bool? success,
    String? message,
    PreferenceResponse? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponsePreferenceResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponsePreferenceResponse.copyWith.fieldName(...)`
class _$ApiResponsePreferenceResponseCWProxyImpl
    implements _$ApiResponsePreferenceResponseCWProxy {
  const _$ApiResponsePreferenceResponseCWProxyImpl(this._value);

  final ApiResponsePreferenceResponse _value;

  @override
  ApiResponsePreferenceResponse success(bool? success) =>
      this(success: success);

  @override
  ApiResponsePreferenceResponse message(String? message) =>
      this(message: message);

  @override
  ApiResponsePreferenceResponse data(PreferenceResponse? data) =>
      this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponsePreferenceResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponsePreferenceResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponsePreferenceResponse call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponsePreferenceResponse(
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
          : data as PreferenceResponse?,
    );
  }
}

extension $ApiResponsePreferenceResponseCopyWith
    on ApiResponsePreferenceResponse {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponsePreferenceResponse.copyWith(...)` or like so:`instanceOfApiResponsePreferenceResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponsePreferenceResponseCWProxy get copyWith =>
      _$ApiResponsePreferenceResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponsePreferenceResponse _$ApiResponsePreferenceResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApiResponsePreferenceResponse', json, ($checkedConvert) {
  final val = ApiResponsePreferenceResponse(
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    data: $checkedConvert(
      'data',
      (v) => v == null
          ? null
          : PreferenceResponse.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ApiResponsePreferenceResponseToJson(
  ApiResponsePreferenceResponse instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
