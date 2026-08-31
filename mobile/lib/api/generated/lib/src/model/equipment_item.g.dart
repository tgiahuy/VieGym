// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_item.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EquipmentItemCWProxy {
  EquipmentItem id(int? id);

  EquipmentItem code(String? code);

  EquipmentItem name(String? name);

  EquipmentItem selected(bool? selected);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EquipmentItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EquipmentItem(...).copyWith(id: 12, name: "My name")
  /// ````
  EquipmentItem call({int? id, String? code, String? name, bool? selected});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEquipmentItem.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEquipmentItem.copyWith.fieldName(...)`
class _$EquipmentItemCWProxyImpl implements _$EquipmentItemCWProxy {
  const _$EquipmentItemCWProxyImpl(this._value);

  final EquipmentItem _value;

  @override
  EquipmentItem id(int? id) => this(id: id);

  @override
  EquipmentItem code(String? code) => this(code: code);

  @override
  EquipmentItem name(String? name) => this(name: name);

  @override
  EquipmentItem selected(bool? selected) => this(selected: selected);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EquipmentItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EquipmentItem(...).copyWith(id: 12, name: "My name")
  /// ````
  EquipmentItem call({
    Object? id = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? selected = const $CopyWithPlaceholder(),
  }) {
    return EquipmentItem(
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
      selected: selected == const $CopyWithPlaceholder()
          ? _value.selected
          // ignore: cast_nullable_to_non_nullable
          : selected as bool?,
    );
  }
}

extension $EquipmentItemCopyWith on EquipmentItem {
  /// Returns a callable class that can be used as follows: `instanceOfEquipmentItem.copyWith(...)` or like so:`instanceOfEquipmentItem.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EquipmentItemCWProxy get copyWith => _$EquipmentItemCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EquipmentItem _$EquipmentItemFromJson(Map<String, dynamic> json) =>
    $checkedCreate('EquipmentItem', json, ($checkedConvert) {
      final val = EquipmentItem(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        code: $checkedConvert('code', (v) => v as String?),
        name: $checkedConvert('name', (v) => v as String?),
        selected: $checkedConvert('selected', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$EquipmentItemToJson(EquipmentItem instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'code': ?instance.code,
      'name': ?instance.name,
      'selected': ?instance.selected,
    };
