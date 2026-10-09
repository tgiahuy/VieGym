// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_meal_plan.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponseMealPlanCWProxy {
  ApiResponseMealPlan success(bool? success);

  ApiResponseMealPlan message(String? message);

  ApiResponseMealPlan data(MealPlan? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseMealPlan(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseMealPlan(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseMealPlan call({bool? success, String? message, MealPlan? data});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponseMealPlan.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponseMealPlan.copyWith.fieldName(...)`
class _$ApiResponseMealPlanCWProxyImpl implements _$ApiResponseMealPlanCWProxy {
  const _$ApiResponseMealPlanCWProxyImpl(this._value);

  final ApiResponseMealPlan _value;

  @override
  ApiResponseMealPlan success(bool? success) => this(success: success);

  @override
  ApiResponseMealPlan message(String? message) => this(message: message);

  @override
  ApiResponseMealPlan data(MealPlan? data) => this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseMealPlan(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseMealPlan(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseMealPlan call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponseMealPlan(
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
          : data as MealPlan?,
    );
  }
}

extension $ApiResponseMealPlanCopyWith on ApiResponseMealPlan {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponseMealPlan.copyWith(...)` or like so:`instanceOfApiResponseMealPlan.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponseMealPlanCWProxy get copyWith =>
      _$ApiResponseMealPlanCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseMealPlan _$ApiResponseMealPlanFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ApiResponseMealPlan', json, ($checkedConvert) {
      final val = ApiResponseMealPlan(
        success: $checkedConvert('success', (v) => v as bool?),
        message: $checkedConvert('message', (v) => v as String?),
        data: $checkedConvert(
          'data',
          (v) =>
              v == null ? null : MealPlan.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ApiResponseMealPlanToJson(
  ApiResponseMealPlan instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
