// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_preference_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EquipmentPreferenceRequestCWProxy {
  EquipmentPreferenceRequest equipmentIds(List<int>? equipmentIds);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EquipmentPreferenceRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EquipmentPreferenceRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  EquipmentPreferenceRequest call({List<int>? equipmentIds});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEquipmentPreferenceRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEquipmentPreferenceRequest.copyWith.fieldName(...)`
class _$EquipmentPreferenceRequestCWProxyImpl
    implements _$EquipmentPreferenceRequestCWProxy {
  const _$EquipmentPreferenceRequestCWProxyImpl(this._value);

  final EquipmentPreferenceRequest _value;

  @override
  EquipmentPreferenceRequest equipmentIds(List<int>? equipmentIds) =>
      this(equipmentIds: equipmentIds);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EquipmentPreferenceRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EquipmentPreferenceRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  EquipmentPreferenceRequest call({
    Object? equipmentIds = const $CopyWithPlaceholder(),
  }) {
    return EquipmentPreferenceRequest(
      equipmentIds: equipmentIds == const $CopyWithPlaceholder()
          ? _value.equipmentIds
          // ignore: cast_nullable_to_non_nullable
          : equipmentIds as List<int>?,
    );
  }
}

extension $EquipmentPreferenceRequestCopyWith on EquipmentPreferenceRequest {
  /// Returns a callable class that can be used as follows: `instanceOfEquipmentPreferenceRequest.copyWith(...)` or like so:`instanceOfEquipmentPreferenceRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EquipmentPreferenceRequestCWProxy get copyWith =>
      _$EquipmentPreferenceRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EquipmentPreferenceRequest _$EquipmentPreferenceRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('EquipmentPreferenceRequest', json, ($checkedConvert) {
  final val = EquipmentPreferenceRequest(
    equipmentIds: $checkedConvert(
      'equipmentIds',
      (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$EquipmentPreferenceRequestToJson(
  EquipmentPreferenceRequest instance,
) => <String, dynamic>{'equipmentIds': ?instance.equipmentIds};
