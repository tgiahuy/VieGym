// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_dashboard_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponseDashboardResponseCWProxy {
  ApiResponseDashboardResponse success(bool? success);

  ApiResponseDashboardResponse message(String? message);

  ApiResponseDashboardResponse data(DashboardResponse? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseDashboardResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseDashboardResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseDashboardResponse call({
    bool? success,
    String? message,
    DashboardResponse? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponseDashboardResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponseDashboardResponse.copyWith.fieldName(...)`
class _$ApiResponseDashboardResponseCWProxyImpl
    implements _$ApiResponseDashboardResponseCWProxy {
  const _$ApiResponseDashboardResponseCWProxyImpl(this._value);

  final ApiResponseDashboardResponse _value;

  @override
  ApiResponseDashboardResponse success(bool? success) => this(success: success);

  @override
  ApiResponseDashboardResponse message(String? message) =>
      this(message: message);

  @override
  ApiResponseDashboardResponse data(DashboardResponse? data) =>
      this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseDashboardResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseDashboardResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseDashboardResponse call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponseDashboardResponse(
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
          : data as DashboardResponse?,
    );
  }
}

extension $ApiResponseDashboardResponseCopyWith
    on ApiResponseDashboardResponse {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponseDashboardResponse.copyWith(...)` or like so:`instanceOfApiResponseDashboardResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponseDashboardResponseCWProxy get copyWith =>
      _$ApiResponseDashboardResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseDashboardResponse _$ApiResponseDashboardResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApiResponseDashboardResponse', json, ($checkedConvert) {
  final val = ApiResponseDashboardResponse(
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    data: $checkedConvert(
      'data',
      (v) => v == null
          ? null
          : DashboardResponse.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ApiResponseDashboardResponseToJson(
  ApiResponseDashboardResponse instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
