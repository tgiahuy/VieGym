// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_apply_template_result.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponseApplyTemplateResultCWProxy {
  ApiResponseApplyTemplateResult success(bool? success);

  ApiResponseApplyTemplateResult message(String? message);

  ApiResponseApplyTemplateResult data(ApplyTemplateResult? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseApplyTemplateResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseApplyTemplateResult(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseApplyTemplateResult call({
    bool? success,
    String? message,
    ApplyTemplateResult? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponseApplyTemplateResult.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponseApplyTemplateResult.copyWith.fieldName(...)`
class _$ApiResponseApplyTemplateResultCWProxyImpl
    implements _$ApiResponseApplyTemplateResultCWProxy {
  const _$ApiResponseApplyTemplateResultCWProxyImpl(this._value);

  final ApiResponseApplyTemplateResult _value;

  @override
  ApiResponseApplyTemplateResult success(bool? success) =>
      this(success: success);

  @override
  ApiResponseApplyTemplateResult message(String? message) =>
      this(message: message);

  @override
  ApiResponseApplyTemplateResult data(ApplyTemplateResult? data) =>
      this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseApplyTemplateResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseApplyTemplateResult(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseApplyTemplateResult call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponseApplyTemplateResult(
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
          : data as ApplyTemplateResult?,
    );
  }
}

extension $ApiResponseApplyTemplateResultCopyWith
    on ApiResponseApplyTemplateResult {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponseApplyTemplateResult.copyWith(...)` or like so:`instanceOfApiResponseApplyTemplateResult.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponseApplyTemplateResultCWProxy get copyWith =>
      _$ApiResponseApplyTemplateResultCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseApplyTemplateResult _$ApiResponseApplyTemplateResultFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApiResponseApplyTemplateResult', json, ($checkedConvert) {
  final val = ApiResponseApplyTemplateResult(
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    data: $checkedConvert(
      'data',
      (v) => v == null
          ? null
          : ApplyTemplateResult.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ApiResponseApplyTemplateResultToJson(
  ApiResponseApplyTemplateResult instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
