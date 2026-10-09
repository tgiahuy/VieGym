// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_food.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponseFoodCWProxy {
  ApiResponseFood success(bool? success);

  ApiResponseFood message(String? message);

  ApiResponseFood data(Food? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseFood(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseFood(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseFood call({bool? success, String? message, Food? data});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponseFood.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponseFood.copyWith.fieldName(...)`
class _$ApiResponseFoodCWProxyImpl implements _$ApiResponseFoodCWProxy {
  const _$ApiResponseFoodCWProxyImpl(this._value);

  final ApiResponseFood _value;

  @override
  ApiResponseFood success(bool? success) => this(success: success);

  @override
  ApiResponseFood message(String? message) => this(message: message);

  @override
  ApiResponseFood data(Food? data) => this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseFood(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseFood(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseFood call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponseFood(
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
          : data as Food?,
    );
  }
}

extension $ApiResponseFoodCopyWith on ApiResponseFood {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponseFood.copyWith(...)` or like so:`instanceOfApiResponseFood.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponseFoodCWProxy get copyWith => _$ApiResponseFoodCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseFood _$ApiResponseFoodFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ApiResponseFood', json, ($checkedConvert) {
      final val = ApiResponseFood(
        success: $checkedConvert('success', (v) => v as bool?),
        message: $checkedConvert('message', (v) => v as String?),
        data: $checkedConvert(
          'data',
          (v) => v == null ? null : Food.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ApiResponseFoodToJson(ApiResponseFood instance) =>
    <String, dynamic>{
      'success': ?instance.success,
      'message': ?instance.message,
      'data': ?instance.data?.toJson(),
    };
