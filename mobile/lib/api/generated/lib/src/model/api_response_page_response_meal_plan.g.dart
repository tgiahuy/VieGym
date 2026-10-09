// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_page_response_meal_plan.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponsePageResponseMealPlanCWProxy {
  ApiResponsePageResponseMealPlan success(bool? success);

  ApiResponsePageResponseMealPlan message(String? message);

  ApiResponsePageResponseMealPlan data(PageResponseMealPlan? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponsePageResponseMealPlan(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponsePageResponseMealPlan(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponsePageResponseMealPlan call({
    bool? success,
    String? message,
    PageResponseMealPlan? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponsePageResponseMealPlan.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponsePageResponseMealPlan.copyWith.fieldName(...)`
class _$ApiResponsePageResponseMealPlanCWProxyImpl
    implements _$ApiResponsePageResponseMealPlanCWProxy {
  const _$ApiResponsePageResponseMealPlanCWProxyImpl(this._value);

  final ApiResponsePageResponseMealPlan _value;

  @override
  ApiResponsePageResponseMealPlan success(bool? success) =>
      this(success: success);

  @override
  ApiResponsePageResponseMealPlan message(String? message) =>
      this(message: message);

  @override
  ApiResponsePageResponseMealPlan data(PageResponseMealPlan? data) =>
      this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponsePageResponseMealPlan(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponsePageResponseMealPlan(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponsePageResponseMealPlan call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponsePageResponseMealPlan(
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
          : data as PageResponseMealPlan?,
    );
  }
}

extension $ApiResponsePageResponseMealPlanCopyWith
    on ApiResponsePageResponseMealPlan {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponsePageResponseMealPlan.copyWith(...)` or like so:`instanceOfApiResponsePageResponseMealPlan.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponsePageResponseMealPlanCWProxy get copyWith =>
      _$ApiResponsePageResponseMealPlanCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponsePageResponseMealPlan _$ApiResponsePageResponseMealPlanFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApiResponsePageResponseMealPlan', json, ($checkedConvert) {
  final val = ApiResponsePageResponseMealPlan(
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    data: $checkedConvert(
      'data',
      (v) => v == null
          ? null
          : PageResponseMealPlan.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ApiResponsePageResponseMealPlanToJson(
  ApiResponsePageResponseMealPlan instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
