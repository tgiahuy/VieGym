// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_list_meal_template.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponseListMealTemplateCWProxy {
  ApiResponseListMealTemplate success(bool? success);

  ApiResponseListMealTemplate message(String? message);

  ApiResponseListMealTemplate data(List<MealTemplate>? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseListMealTemplate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseListMealTemplate(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseListMealTemplate call({
    bool? success,
    String? message,
    List<MealTemplate>? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponseListMealTemplate.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponseListMealTemplate.copyWith.fieldName(...)`
class _$ApiResponseListMealTemplateCWProxyImpl
    implements _$ApiResponseListMealTemplateCWProxy {
  const _$ApiResponseListMealTemplateCWProxyImpl(this._value);

  final ApiResponseListMealTemplate _value;

  @override
  ApiResponseListMealTemplate success(bool? success) => this(success: success);

  @override
  ApiResponseListMealTemplate message(String? message) =>
      this(message: message);

  @override
  ApiResponseListMealTemplate data(List<MealTemplate>? data) =>
      this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseListMealTemplate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseListMealTemplate(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseListMealTemplate call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponseListMealTemplate(
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
          : data as List<MealTemplate>?,
    );
  }
}

extension $ApiResponseListMealTemplateCopyWith on ApiResponseListMealTemplate {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponseListMealTemplate.copyWith(...)` or like so:`instanceOfApiResponseListMealTemplate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponseListMealTemplateCWProxy get copyWith =>
      _$ApiResponseListMealTemplateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseListMealTemplate _$ApiResponseListMealTemplateFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApiResponseListMealTemplate', json, ($checkedConvert) {
  final val = ApiResponseListMealTemplate(
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>?)
          ?.map((e) => MealTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$ApiResponseListMealTemplateToJson(
  ApiResponseListMealTemplate instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.map((e) => e.toJson()).toList(),
};
