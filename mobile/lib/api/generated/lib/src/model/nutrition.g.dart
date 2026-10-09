// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NutritionCWProxy {
  Nutrition caloriesKcal(num? caloriesKcal);

  Nutrition proteinG(num? proteinG);

  Nutrition carbsG(num? carbsG);

  Nutrition fatG(num? fatG);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Nutrition(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Nutrition(...).copyWith(id: 12, name: "My name")
  /// ````
  Nutrition call({num? caloriesKcal, num? proteinG, num? carbsG, num? fatG});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNutrition.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNutrition.copyWith.fieldName(...)`
class _$NutritionCWProxyImpl implements _$NutritionCWProxy {
  const _$NutritionCWProxyImpl(this._value);

  final Nutrition _value;

  @override
  Nutrition caloriesKcal(num? caloriesKcal) => this(caloriesKcal: caloriesKcal);

  @override
  Nutrition proteinG(num? proteinG) => this(proteinG: proteinG);

  @override
  Nutrition carbsG(num? carbsG) => this(carbsG: carbsG);

  @override
  Nutrition fatG(num? fatG) => this(fatG: fatG);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Nutrition(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Nutrition(...).copyWith(id: 12, name: "My name")
  /// ````
  Nutrition call({
    Object? caloriesKcal = const $CopyWithPlaceholder(),
    Object? proteinG = const $CopyWithPlaceholder(),
    Object? carbsG = const $CopyWithPlaceholder(),
    Object? fatG = const $CopyWithPlaceholder(),
  }) {
    return Nutrition(
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

extension $NutritionCopyWith on Nutrition {
  /// Returns a callable class that can be used as follows: `instanceOfNutrition.copyWith(...)` or like so:`instanceOfNutrition.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NutritionCWProxy get copyWith => _$NutritionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Nutrition _$NutritionFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Nutrition', json, ($checkedConvert) {
      final val = Nutrition(
        caloriesKcal: $checkedConvert('caloriesKcal', (v) => v as num?),
        proteinG: $checkedConvert('proteinG', (v) => v as num?),
        carbsG: $checkedConvert('carbsG', (v) => v as num?),
        fatG: $checkedConvert('fatG', (v) => v as num?),
      );
      return val;
    });

Map<String, dynamic> _$NutritionToJson(Nutrition instance) => <String, dynamic>{
  'caloriesKcal': ?instance.caloriesKcal,
  'proteinG': ?instance.proteinG,
  'carbsG': ?instance.carbsG,
  'fatG': ?instance.fatG,
};
