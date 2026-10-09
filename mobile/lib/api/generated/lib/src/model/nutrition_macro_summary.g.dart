// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_macro_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NutritionMacroSummaryCWProxy {
  NutritionMacroSummary caloriesKcal(num? caloriesKcal);

  NutritionMacroSummary proteinG(num? proteinG);

  NutritionMacroSummary carbsG(num? carbsG);

  NutritionMacroSummary fatG(num? fatG);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NutritionMacroSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NutritionMacroSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  NutritionMacroSummary call({
    num? caloriesKcal,
    num? proteinG,
    num? carbsG,
    num? fatG,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNutritionMacroSummary.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNutritionMacroSummary.copyWith.fieldName(...)`
class _$NutritionMacroSummaryCWProxyImpl
    implements _$NutritionMacroSummaryCWProxy {
  const _$NutritionMacroSummaryCWProxyImpl(this._value);

  final NutritionMacroSummary _value;

  @override
  NutritionMacroSummary caloriesKcal(num? caloriesKcal) =>
      this(caloriesKcal: caloriesKcal);

  @override
  NutritionMacroSummary proteinG(num? proteinG) => this(proteinG: proteinG);

  @override
  NutritionMacroSummary carbsG(num? carbsG) => this(carbsG: carbsG);

  @override
  NutritionMacroSummary fatG(num? fatG) => this(fatG: fatG);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NutritionMacroSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NutritionMacroSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  NutritionMacroSummary call({
    Object? caloriesKcal = const $CopyWithPlaceholder(),
    Object? proteinG = const $CopyWithPlaceholder(),
    Object? carbsG = const $CopyWithPlaceholder(),
    Object? fatG = const $CopyWithPlaceholder(),
  }) {
    return NutritionMacroSummary(
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

extension $NutritionMacroSummaryCopyWith on NutritionMacroSummary {
  /// Returns a callable class that can be used as follows: `instanceOfNutritionMacroSummary.copyWith(...)` or like so:`instanceOfNutritionMacroSummary.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NutritionMacroSummaryCWProxy get copyWith =>
      _$NutritionMacroSummaryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NutritionMacroSummary _$NutritionMacroSummaryFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('NutritionMacroSummary', json, ($checkedConvert) {
  final val = NutritionMacroSummary(
    caloriesKcal: $checkedConvert('caloriesKcal', (v) => v as num?),
    proteinG: $checkedConvert('proteinG', (v) => v as num?),
    carbsG: $checkedConvert('carbsG', (v) => v as num?),
    fatG: $checkedConvert('fatG', (v) => v as num?),
  );
  return val;
});

Map<String, dynamic> _$NutritionMacroSummaryToJson(
  NutritionMacroSummary instance,
) => <String, dynamic>{
  'caloriesKcal': ?instance.caloriesKcal,
  'proteinG': ?instance.proteinG,
  'carbsG': ?instance.carbsG,
  'fatG': ?instance.fatG,
};
