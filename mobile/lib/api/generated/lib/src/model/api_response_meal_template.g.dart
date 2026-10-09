// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_meal_template.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponseMealTemplateCWProxy {
  ApiResponseMealTemplate success(bool? success);

  ApiResponseMealTemplate message(String? message);

  ApiResponseMealTemplate data(MealTemplate? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseMealTemplate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseMealTemplate(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseMealTemplate call({
    bool? success,
    String? message,
    MealTemplate? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponseMealTemplate.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponseMealTemplate.copyWith.fieldName(...)`
class _$ApiResponseMealTemplateCWProxyImpl
    implements _$ApiResponseMealTemplateCWProxy {
  const _$ApiResponseMealTemplateCWProxyImpl(this._value);

  final ApiResponseMealTemplate _value;

  @override
  ApiResponseMealTemplate success(bool? success) => this(success: success);

  @override
  ApiResponseMealTemplate message(String? message) => this(message: message);

  @override
  ApiResponseMealTemplate data(MealTemplate? data) => this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseMealTemplate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseMealTemplate(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseMealTemplate call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponseMealTemplate(
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
          : data as MealTemplate?,
    );
  }
}

extension $ApiResponseMealTemplateCopyWith on ApiResponseMealTemplate {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponseMealTemplate.copyWith(...)` or like so:`instanceOfApiResponseMealTemplate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponseMealTemplateCWProxy get copyWith =>
      _$ApiResponseMealTemplateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseMealTemplate _$ApiResponseMealTemplateFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApiResponseMealTemplate', json, ($checkedConvert) {
  final val = ApiResponseMealTemplate(
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    data: $checkedConvert(
      'data',
      (v) =>
          v == null ? null : MealTemplate.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ApiResponseMealTemplateToJson(
  ApiResponseMealTemplate instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
