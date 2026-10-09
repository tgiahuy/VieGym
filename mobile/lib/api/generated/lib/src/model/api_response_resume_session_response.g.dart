// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_resume_session_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponseResumeSessionResponseCWProxy {
  ApiResponseResumeSessionResponse success(bool? success);

  ApiResponseResumeSessionResponse message(String? message);

  ApiResponseResumeSessionResponse data(ResumeSessionResponse? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseResumeSessionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseResumeSessionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseResumeSessionResponse call({
    bool? success,
    String? message,
    ResumeSessionResponse? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponseResumeSessionResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponseResumeSessionResponse.copyWith.fieldName(...)`
class _$ApiResponseResumeSessionResponseCWProxyImpl
    implements _$ApiResponseResumeSessionResponseCWProxy {
  const _$ApiResponseResumeSessionResponseCWProxyImpl(this._value);

  final ApiResponseResumeSessionResponse _value;

  @override
  ApiResponseResumeSessionResponse success(bool? success) =>
      this(success: success);

  @override
  ApiResponseResumeSessionResponse message(String? message) =>
      this(message: message);

  @override
  ApiResponseResumeSessionResponse data(ResumeSessionResponse? data) =>
      this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseResumeSessionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseResumeSessionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseResumeSessionResponse call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponseResumeSessionResponse(
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
          : data as ResumeSessionResponse?,
    );
  }
}

extension $ApiResponseResumeSessionResponseCopyWith
    on ApiResponseResumeSessionResponse {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponseResumeSessionResponse.copyWith(...)` or like so:`instanceOfApiResponseResumeSessionResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponseResumeSessionResponseCWProxy get copyWith =>
      _$ApiResponseResumeSessionResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseResumeSessionResponse _$ApiResponseResumeSessionResponseFromJson(
  Map<String, dynamic> json,
) =>
    $checkedCreate('ApiResponseResumeSessionResponse', json, ($checkedConvert) {
      final val = ApiResponseResumeSessionResponse(
        success: $checkedConvert('success', (v) => v as bool?),
        message: $checkedConvert('message', (v) => v as String?),
        data: $checkedConvert(
          'data',
          (v) => v == null
              ? null
              : ResumeSessionResponse.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ApiResponseResumeSessionResponseToJson(
  ApiResponseResumeSessionResponse instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
