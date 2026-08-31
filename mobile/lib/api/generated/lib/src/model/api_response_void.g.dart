// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_void.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponseVoidCWProxy {
  ApiResponseVoid success(bool? success);

  ApiResponseVoid message(String? message);

  ApiResponseVoid data(Object? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseVoid(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseVoid(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseVoid call({bool? success, String? message, Object? data});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponseVoid.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponseVoid.copyWith.fieldName(...)`
class _$ApiResponseVoidCWProxyImpl implements _$ApiResponseVoidCWProxy {
  const _$ApiResponseVoidCWProxyImpl(this._value);

  final ApiResponseVoid _value;

  @override
  ApiResponseVoid success(bool? success) => this(success: success);

  @override
  ApiResponseVoid message(String? message) => this(message: message);

  @override
  ApiResponseVoid data(Object? data) => this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseVoid(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseVoid(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseVoid call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponseVoid(
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
          : data as Object?,
    );
  }
}

extension $ApiResponseVoidCopyWith on ApiResponseVoid {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponseVoid.copyWith(...)` or like so:`instanceOfApiResponseVoid.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponseVoidCWProxy get copyWith => _$ApiResponseVoidCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseVoid _$ApiResponseVoidFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ApiResponseVoid', json, ($checkedConvert) {
      final val = ApiResponseVoid(
        success: $checkedConvert('success', (v) => v as bool?),
        message: $checkedConvert('message', (v) => v as String?),
        data: $checkedConvert('data', (v) => v),
      );
      return val;
    });

Map<String, dynamic> _$ApiResponseVoidToJson(ApiResponseVoid instance) =>
    <String, dynamic>{
      'success': ?instance.success,
      'message': ?instance.message,
      'data': ?instance.data,
    };
