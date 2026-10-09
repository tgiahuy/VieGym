// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_list_equipment_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiResponseListEquipmentDtoCWProxy {
  ApiResponseListEquipmentDto success(bool? success);

  ApiResponseListEquipmentDto message(String? message);

  ApiResponseListEquipmentDto data(List<EquipmentDto>? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseListEquipmentDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseListEquipmentDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseListEquipmentDto call({
    bool? success,
    String? message,
    List<EquipmentDto>? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiResponseListEquipmentDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiResponseListEquipmentDto.copyWith.fieldName(...)`
class _$ApiResponseListEquipmentDtoCWProxyImpl
    implements _$ApiResponseListEquipmentDtoCWProxy {
  const _$ApiResponseListEquipmentDtoCWProxyImpl(this._value);

  final ApiResponseListEquipmentDto _value;

  @override
  ApiResponseListEquipmentDto success(bool? success) => this(success: success);

  @override
  ApiResponseListEquipmentDto message(String? message) =>
      this(message: message);

  @override
  ApiResponseListEquipmentDto data(List<EquipmentDto>? data) =>
      this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiResponseListEquipmentDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiResponseListEquipmentDto(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiResponseListEquipmentDto call({
    Object? success = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ApiResponseListEquipmentDto(
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
          : data as List<EquipmentDto>?,
    );
  }
}

extension $ApiResponseListEquipmentDtoCopyWith on ApiResponseListEquipmentDto {
  /// Returns a callable class that can be used as follows: `instanceOfApiResponseListEquipmentDto.copyWith(...)` or like so:`instanceOfApiResponseListEquipmentDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiResponseListEquipmentDtoCWProxy get copyWith =>
      _$ApiResponseListEquipmentDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponseListEquipmentDto _$ApiResponseListEquipmentDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApiResponseListEquipmentDto', json, ($checkedConvert) {
  final val = ApiResponseListEquipmentDto(
    success: $checkedConvert('success', (v) => v as bool?),
    message: $checkedConvert('message', (v) => v as String?),
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>?)
          ?.map((e) => EquipmentDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$ApiResponseListEquipmentDtoToJson(
  ApiResponseListEquipmentDto instance,
) => <String, dynamic>{
  'success': ?instance.success,
  'message': ?instance.message,
  'data': ?instance.data?.map((e) => e.toJson()).toList(),
};
