// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_section.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NutritionSectionCWProxy {
  NutritionSection target(NutritionMacroSummary? target);

  NutritionSection consumed(NutritionMacroSummary? consumed);

  NutritionSection remaining(NutritionMacroSummary? remaining);

  NutritionSection hasMealPlan(bool? hasMealPlan);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NutritionSection(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NutritionSection(...).copyWith(id: 12, name: "My name")
  /// ````
  NutritionSection call({
    NutritionMacroSummary? target,
    NutritionMacroSummary? consumed,
    NutritionMacroSummary? remaining,
    bool? hasMealPlan,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNutritionSection.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNutritionSection.copyWith.fieldName(...)`
class _$NutritionSectionCWProxyImpl implements _$NutritionSectionCWProxy {
  const _$NutritionSectionCWProxyImpl(this._value);

  final NutritionSection _value;

  @override
  NutritionSection target(NutritionMacroSummary? target) =>
      this(target: target);

  @override
  NutritionSection consumed(NutritionMacroSummary? consumed) =>
      this(consumed: consumed);

  @override
  NutritionSection remaining(NutritionMacroSummary? remaining) =>
      this(remaining: remaining);

  @override
  NutritionSection hasMealPlan(bool? hasMealPlan) =>
      this(hasMealPlan: hasMealPlan);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NutritionSection(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NutritionSection(...).copyWith(id: 12, name: "My name")
  /// ````
  NutritionSection call({
    Object? target = const $CopyWithPlaceholder(),
    Object? consumed = const $CopyWithPlaceholder(),
    Object? remaining = const $CopyWithPlaceholder(),
    Object? hasMealPlan = const $CopyWithPlaceholder(),
  }) {
    return NutritionSection(
      target: target == const $CopyWithPlaceholder()
          ? _value.target
          // ignore: cast_nullable_to_non_nullable
          : target as NutritionMacroSummary?,
      consumed: consumed == const $CopyWithPlaceholder()
          ? _value.consumed
          // ignore: cast_nullable_to_non_nullable
          : consumed as NutritionMacroSummary?,
      remaining: remaining == const $CopyWithPlaceholder()
          ? _value.remaining
          // ignore: cast_nullable_to_non_nullable
          : remaining as NutritionMacroSummary?,
      hasMealPlan: hasMealPlan == const $CopyWithPlaceholder()
          ? _value.hasMealPlan
          // ignore: cast_nullable_to_non_nullable
          : hasMealPlan as bool?,
    );
  }
}

extension $NutritionSectionCopyWith on NutritionSection {
  /// Returns a callable class that can be used as follows: `instanceOfNutritionSection.copyWith(...)` or like so:`instanceOfNutritionSection.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NutritionSectionCWProxy get copyWith => _$NutritionSectionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NutritionSection _$NutritionSectionFromJson(Map<String, dynamic> json) =>
    $checkedCreate('NutritionSection', json, ($checkedConvert) {
      final val = NutritionSection(
        target: $checkedConvert(
          'target',
          (v) => v == null
              ? null
              : NutritionMacroSummary.fromJson(v as Map<String, dynamic>),
        ),
        consumed: $checkedConvert(
          'consumed',
          (v) => v == null
              ? null
              : NutritionMacroSummary.fromJson(v as Map<String, dynamic>),
        ),
        remaining: $checkedConvert(
          'remaining',
          (v) => v == null
              ? null
              : NutritionMacroSummary.fromJson(v as Map<String, dynamic>),
        ),
        hasMealPlan: $checkedConvert('hasMealPlan', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$NutritionSectionToJson(NutritionSection instance) =>
    <String, dynamic>{
      'target': ?instance.target?.toJson(),
      'consumed': ?instance.consumed?.toJson(),
      'remaining': ?instance.remaining?.toJson(),
      'hasMealPlan': ?instance.hasMealPlan,
    };
