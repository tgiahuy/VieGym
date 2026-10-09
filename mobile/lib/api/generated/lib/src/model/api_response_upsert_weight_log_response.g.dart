// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_upsert_weight_log_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponseUpsertWeightLogResponseCWProxy {
  ApiResponseUpsertWeightLogResponse success(bool? success);

  ApiResponseUpsertWeightLogResponse message(String? message);

  ApiResponseUpsertWeightLogResponse data(UpsertWeightLogResponse? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseUpsertWeightLogResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseUpsertWeightLogResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseUpsertWeightLogResponse call({
    bool? success,
    String? message,
    UpsertWeightLogResponse? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponseUpsertWeightLogResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponseUpsertWeightLogResponse.copyWith.fieldName(...)`
class _$ApiResponseUpsertWeightLogResponseCWProxyImpl
    implements _$ApiResponseUpsertWeightLogResponseCWProxy {
  const _$ApiResponseUpsertWeightLogResponseCWProxyImpl(this._value);

  final ApiResponseUpsertWeightLogResponse _value;

  @override
  ApiResponseUpsertWeightLogResponse success(bool? success) =>
      this(success: success);

  @override
  ApiResponseUpsertWeightLogResponse message(String? message) =>
      this(message: message);

  @override
  ApiResponseUpsertWeightLogResponse data(UpsertWeightLogResponse? data) =>
      this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseUpsertWeightLogResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseUpsertWeightLogResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseUpsertWeightLogResponse call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponseUpsertWeightLogResponse(
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
          : data as UpsertWeightLogResponse?,
    );
  }
}

extension $ApiResponseUpsertWeightLogResponseCopyWith
    on ApiResponseUpsertWeightLogResponse {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponseUpsertWeightLogResponse.copyWith(...)` or like so:`instanceOfApiResponseUpsertWeightLogResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponseUpsertWeightLogResponseCWProxy get copyWith =>
      _$ApiResponseUpsertWeightLogResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseUpsertWeightLogResponse _$ApiResponseUpsertWeightLogResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApiResponseUpsertWeightLogResponse', json, (
  $checkedConvert,
) {
  final val = ApiResponseUpsertWeightLogResponse(
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    data: $checkedConvert(
      'data',
      (v) => v == null
          ? null
          : UpsertWeightLogResponse.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ApiResponseUpsertWeightLogResponseToJson(
  ApiResponseUpsertWeightLogResponse instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
