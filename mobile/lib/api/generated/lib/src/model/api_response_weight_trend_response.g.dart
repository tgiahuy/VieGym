// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_weight_trend_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponseWeightTrendResponseCWProxy {
  ApiResponseWeightTrendResponse success(bool? success);

  ApiResponseWeightTrendResponse message(String? message);

  ApiResponseWeightTrendResponse data(WeightTrendResponse? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseWeightTrendResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseWeightTrendResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseWeightTrendResponse call({
    bool? success,
    String? message,
    WeightTrendResponse? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponseWeightTrendResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponseWeightTrendResponse.copyWith.fieldName(...)`
class _$ApiResponseWeightTrendResponseCWProxyImpl
    implements _$ApiResponseWeightTrendResponseCWProxy {
  const _$ApiResponseWeightTrendResponseCWProxyImpl(this._value);

  final ApiResponseWeightTrendResponse _value;

  @override
  ApiResponseWeightTrendResponse success(bool? success) =>
      this(success: success);

  @override
  ApiResponseWeightTrendResponse message(String? message) =>
      this(message: message);

  @override
  ApiResponseWeightTrendResponse data(WeightTrendResponse? data) =>
      this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseWeightTrendResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseWeightTrendResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseWeightTrendResponse call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponseWeightTrendResponse(
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
          : data as WeightTrendResponse?,
    );
  }
}

extension $ApiResponseWeightTrendResponseCopyWith
    on ApiResponseWeightTrendResponse {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponseWeightTrendResponse.copyWith(...)` or like so:`instanceOfApiResponseWeightTrendResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponseWeightTrendResponseCWProxy get copyWith =>
      _$ApiResponseWeightTrendResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseWeightTrendResponse _$ApiResponseWeightTrendResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApiResponseWeightTrendResponse', json, ($checkedConvert) {
  final val = ApiResponseWeightTrendResponse(
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    data: $checkedConvert(
      'data',
      (v) => v == null
          ? null
          : WeightTrendResponse.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ApiResponseWeightTrendResponseToJson(
  ApiResponseWeightTrendResponse instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
