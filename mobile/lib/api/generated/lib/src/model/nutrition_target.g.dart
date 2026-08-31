// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_target.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NutritionTargetCWProxy {
  NutritionTarget caloriesKcal(num? caloriesKcal);

  NutritionTarget proteinG(num? proteinG);

  NutritionTarget carbsG(num? carbsG);

  NutritionTarget fatG(num? fatG);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NutritionTarget(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NutritionTarget(...).copyWith(id: 12, name: "My name")
  /// ````
  NutritionTarget call({
    num? caloriesKcal,
    num? proteinG,
    num? carbsG,
    num? fatG,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNutritionTarget.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNutritionTarget.copyWith.fieldName(...)`
class _$NutritionTargetCWProxyImpl implements _$NutritionTargetCWProxy {
  const _$NutritionTargetCWProxyImpl(this._value);

  final NutritionTarget _value;

  @override
  NutritionTarget caloriesKcal(num? caloriesKcal) =>
      this(caloriesKcal: caloriesKcal);

  @override
  NutritionTarget proteinG(num? proteinG) => this(proteinG: proteinG);

  @override
  NutritionTarget carbsG(num? carbsG) => this(carbsG: carbsG);

  @override
  NutritionTarget fatG(num? fatG) => this(fatG: fatG);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NutritionTarget(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NutritionTarget(...).copyWith(id: 12, name: "My name")
  /// ````
  NutritionTarget call({
    Object? caloriesKcal = const $CopyWithPlaceholder(),
    Object? proteinG = const $CopyWithPlaceholder(),
    Object? carbsG = const $CopyWithPlaceholder(),
    Object? fatG = const $CopyWithPlaceholder(),
  }) {
    return NutritionTarget(
      caloriesKcal: caloriesKcal == const $CopyWithPlaceholder()
          ? _value.caloriesKcal
          // ignore: cast_nullable_to_non_nullable
          : caloriesKcal as num?,
      proteinG: proteinG == const $CopyWithPlaceholder()
          ? _value.proteinG
          // ignore: cast_nullable_to_non_nullable
          : proteinG as num?,
      carbsG: carbsG == const $CopyWithPlaceholder()
          ? _value.carbsG
          // ignore: cast_nullable_to_non_nullable
          : carbsG as num?,
      fatG: fatG == const $CopyWithPlaceholder()
          ? _value.fatG
          // ignore: cast_nullable_to_non_nullable
          : fatG as num?,
    );
  }
}

extension $NutritionTargetCopyWith on NutritionTarget {
  /// Returns a callable class that can be used as follows: `instanceOfNutritionTarget.copyWith(...)` or like so:`instanceOfNutritionTarget.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NutritionTargetCWProxy get copyWith => _$NutritionTargetCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NutritionTarget _$NutritionTargetFromJson(Map<String, dynamic> json) =>
    $checkedCreate('NutritionTarget', json, ($checkedConvert) {
      final val = NutritionTarget(
        caloriesKcal: $checkedConvert('caloriesKcal', (v) => v as num?),
        proteinG: $checkedConvert('proteinG', (v) => v as num?),
        carbsG: $checkedConvert('carbsG', (v) => v as num?),
        fatG: $checkedConvert('fatG', (v) => v as num?),
      );
      return val;
    });

Map<String, dynamic> _$NutritionTargetToJson(NutritionTarget instance) =>
    <String, dynamic>{
      'caloriesKcal': ?instance.caloriesKcal,
      'proteinG': ?instance.proteinG,
      'carbsG': ?instance.carbsG,
      'fatG': ?instance.fatG,
    };
