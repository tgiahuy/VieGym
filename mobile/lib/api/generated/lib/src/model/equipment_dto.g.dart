// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EquipmentDtoCWProxy {
  EquipmentDto id(int? id);

  EquipmentDto code(String? code);

  EquipmentDto name(String? name);

  EquipmentDto description(String? description);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EquipmentDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EquipmentDto(...).copyWith(id: 12, name: "My name")
  /// ````
  EquipmentDto call({int? id, String? code, String? name, String? description});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEquipmentDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEquipmentDto.copyWith.fieldName(...)`
class _$EquipmentDtoCWProxyImpl implements _$EquipmentDtoCWProxy {
  const _$EquipmentDtoCWProxyImpl(this._value);

  final EquipmentDto _value;

  @override
  EquipmentDto id(int? id) => this(id: id);

  @override
  EquipmentDto code(String? code) => this(code: code);

  @override
  EquipmentDto name(String? name) => this(name: name);

  @override
  EquipmentDto description(String? description) =>
      this(description: description);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EquipmentDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EquipmentDto(...).copyWith(id: 12, name: "My name")
  /// ````
  EquipmentDto call({
    Object? id = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
  }) {
    return EquipmentDto(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
    );
  }
}

extension $EquipmentDtoCopyWith on EquipmentDto {
  /// Returns a callable class that can be used as follows: `instanceOfEquipmentDto.copyWith(...)` or like so:`instanceOfEquipmentDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EquipmentDtoCWProxy get copyWith => _$EquipmentDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EquipmentDto _$EquipmentDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('EquipmentDto', json, ($checkedConvert) {
      final val = EquipmentDto(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        code: $checkedConvert('code', (v) => v as String?),
        name: $checkedConvert('name', (v) => v as String?),
        description: $checkedConvert('description', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$EquipmentDtoToJson(EquipmentDto instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'code': ?instance.code,
      'name': ?instance.name,
      'description': ?instance.description,
    };
