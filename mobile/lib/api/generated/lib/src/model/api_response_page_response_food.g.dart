// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_page_response_food.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponsePageResponseFoodCWProxy {
  ApiResponsePageResponseFood success(bool? success);

  ApiResponsePageResponseFood message(String? message);

  ApiResponsePageResponseFood data(PageResponseFood? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponsePageResponseFood(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponsePageResponseFood(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponsePageResponseFood call({
    bool? success,
    String? message,
    PageResponseFood? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponsePageResponseFood.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponsePageResponseFood.copyWith.fieldName(...)`
class _$ApiResponsePageResponseFoodCWProxyImpl
    implements _$ApiResponsePageResponseFoodCWProxy {
  const _$ApiResponsePageResponseFoodCWProxyImpl(this._value);

  final ApiResponsePageResponseFood _value;

  @override
  ApiResponsePageResponseFood success(bool? success) => this(success: success);

  @override
  ApiResponsePageResponseFood message(String? message) =>
      this(message: message);

  @override
  ApiResponsePageResponseFood data(PageResponseFood? data) => this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponsePageResponseFood(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponsePageResponseFood(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponsePageResponseFood call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponsePageResponseFood(
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
          : data as PageResponseFood?,
    );
  }
}

extension $ApiResponsePageResponseFoodCopyWith on ApiResponsePageResponseFood {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponsePageResponseFood.copyWith(...)` or like so:`instanceOfApiResponsePageResponseFood.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponsePageResponseFoodCWProxy get copyWith =>
      _$ApiResponsePageResponseFoodCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponsePageResponseFood _$ApiResponsePageResponseFoodFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApiResponsePageResponseFood', json, ($checkedConvert) {
  final val = ApiResponsePageResponseFood(
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    data: $checkedConvert(
      'data',
      (v) => v == null
          ? null
          : PageResponseFood.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ApiResponsePageResponseFoodToJson(
  ApiResponsePageResponseFood instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.toJson(),
};
