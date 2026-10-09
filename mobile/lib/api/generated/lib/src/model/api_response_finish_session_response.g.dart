// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_finish_session_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponseFinishSessionResponseCWProxy {
  ApiResponseFinishSessionResponse success(bool? success);

  ApiResponseFinishSessionResponse message(String? message);

  ApiResponseFinishSessionResponse data(FinishSessionResponse? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseFinishSessionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseFinishSessionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseFinishSessionResponse call({
    bool? success,
    String? message,
    FinishSessionResponse? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponseFinishSessionResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponseFinishSessionResponse.copyWith.fieldName(...)`
class _$ApiResponseFinishSessionResponseCWProxyImpl
    implements _$ApiResponseFinishSessionResponseCWProxy {
  const _$ApiResponseFinishSessionResponseCWProxyImpl(this._value);

  final ApiResponseFinishSessionResponse _value;

  @override
  ApiResponseFinishSessionResponse success(bool? success) =>
      this(success: success);

  @override
  ApiResponseFinishSessionResponse message(String? message) =>
      this(message: message);

  @override
  ApiResponseFinishSessionResponse data(FinishSessionResponse? data) =>
      this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseFinishSessionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseFinishSessionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseFinishSessionResponse call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponseFinishSessionResponse(
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
          : data as FinishSessionResponse?,
    );
  }
}

extension $ApiResponseFinishSessionResponseCopyWith
    on ApiResponseFinishSessionResponse {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponseFinishSessionResponse.copyWith(...)` or like so:`instanceOfApiResponseFinishSessionResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponseFinishSessionResponseCWProxy get copyWith =>
      _$ApiResponseFinishSessionResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseFinishSessionResponse _$ApiResponseFinishSessionResponseFromJson(
  Map<String, dynamic> json,
) =>
    $checkedCreate('ApiResponseFinishSessionResponse', json, ($checkedConvert) {
      final val = ApiResponseFinishSessionResponse(
        success: $checkedConvert('success', (v) => v as bool?),
        message: $checkedConvert('message', (v) => v as String?),
        data: $checkedConvert(
          'data',
          (v) => v == null
              ? null
              : FinishSessionResponse.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ApiResponseFinishSessionResponseToJson(
  ApiResponseFinishSessionResponse instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
