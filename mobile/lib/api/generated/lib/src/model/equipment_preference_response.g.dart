// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_preference_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EquipmentPreferenceResponseCWProxy {
  EquipmentPreferenceResponse selectedEquipmentIds(
    List<int>? selectedEquipmentIds,
  );

  EquipmentPreferenceResponse equipment(List<EquipmentItem>? equipment);

  EquipmentPreferenceResponse equipmentOnboardingCompletedAt(
    DateTime? equipmentOnboardingCompletedAt,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EquipmentPreferenceResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EquipmentPreferenceResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  EquipmentPreferenceResponse call({
    List<int>? selectedEquipmentIds,
    List<EquipmentItem>? equipment,
    DateTime? equipmentOnboardingCompletedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEquipmentPreferenceResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEquipmentPreferenceResponse.copyWith.fieldName(...)`
class _$EquipmentPreferenceResponseCWProxyImpl
    implements _$EquipmentPreferenceResponseCWProxy {
  const _$EquipmentPreferenceResponseCWProxyImpl(this._value);

  final EquipmentPreferenceResponse _value;

  @override
  EquipmentPreferenceResponse selectedEquipmentIds(
    List<int>? selectedEquipmentIds,
  ) => this(selectedEquipmentIds: selectedEquipmentIds);

  @override
  EquipmentPreferenceResponse equipment(List<EquipmentItem>? equipment) =>
      this(equipment: equipment);

  @override
  EquipmentPreferenceResponse equipmentOnboardingCompletedAt(
    DateTime? equipmentOnboardingCompletedAt,
  ) => this(equipmentOnboardingCompletedAt: equipmentOnboardingCompletedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EquipmentPreferenceResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EquipmentPreferenceResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  EquipmentPreferenceResponse call({
    Object? selectedEquipmentIds = const $CopyWithPlaceholder(),
    Object? equipment = const $CopyWithPlaceholder(),
    Object? equipmentOnboardingCompletedAt = const $CopyWithPlaceholder(),
  }) {
    return EquipmentPreferenceResponse(
      selectedEquipmentIds: selectedEquipmentIds == const $CopyWithPlaceholder()
          ? _value.selectedEquipmentIds
          // ignore: cast_nullable_to_non_nullable
          : selectedEquipmentIds as List<int>?,
      equipment: equipment == const $CopyWithPlaceholder()
          ? _value.equipment
          // ignore: cast_nullable_to_non_nullable
          : equipment as List<EquipmentItem>?,
      equipmentOnboardingCompletedAt:
          equipmentOnboardingCompletedAt == const $CopyWithPlaceholder()
          ? _value.equipmentOnboardingCompletedAt
          // ignore: cast_nullable_to_non_nullable
          : equipmentOnboardingCompletedAt as DateTime?,
    );
  }
}

extension $EquipmentPreferenceResponseCopyWith on EquipmentPreferenceResponse {
  /// Returns a callable class that can be used as follows: `instanceOfEquipmentPreferenceResponse.copyWith(...)` or like so:`instanceOfEquipmentPreferenceResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EquipmentPreferenceResponseCWProxy get copyWith =>
      _$EquipmentPreferenceResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EquipmentPreferenceResponse _$EquipmentPreferenceResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('EquipmentPreferenceResponse', json, ($checkedConvert) {
  final val = EquipmentPreferenceResponse(
    selectedEquipmentIds: $checkedConvert(
      'selectedEquipmentIds',
      (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
    ),
    equipment: $checkedConvert(
      'equipment',
      (v) => (v as List<dynamic>?)
          ?.map((e) => EquipmentItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    equipmentOnboardingCompletedAt: $checkedConvert(
      'equipmentOnboardingCompletedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
  );
  return val;
});

Map<String, dynamic> _$EquipmentPreferenceResponseToJson(
  EquipmentPreferenceResponse instance,
) => <String, dynamic>{
  'selectedEquipmentIds': ?instance.selectedEquipmentIds,
  'equipment': ?instance.equipment?.map((e) => e.toJson()).toList(),
  'equipmentOnboardingCompletedAt': ?instance.equipmentOnboardingCompletedAt
      ?.toIso8601String(),
};
