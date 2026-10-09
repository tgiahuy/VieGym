// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MealPlanCWProxy {
  MealPlan id(int? id);

  MealPlan planDate(DateTime? planDate);

  MealPlan targetSource(String? targetSource);

  MealPlan target(Nutrition? target);

  MealPlan consumed(Nutrition? consumed);

  MealPlan remaining(Nutrition? remaining);

  MealPlan meals(List<Meal>? meals);

  MealPlan warnings(List<String>? warnings);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealPlan(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealPlan(...).copyWith(id: 12, name: "My name")
  /// ````
  MealPlan call({
    int? id,
    DateTime? planDate,
    String? targetSource,
    Nutrition? target,
    Nutrition? consumed,
    Nutrition? remaining,
    List<Meal>? meals,
    List<String>? warnings,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMealPlan.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMealPlan.copyWith.fieldName(...)`
class _$MealPlanCWProxyImpl implements _$MealPlanCWProxy {
  const _$MealPlanCWProxyImpl(this._value);

  final MealPlan _value;

  @override
  MealPlan id(int? id) => this(id: id);

  @override
  MealPlan planDate(DateTime? planDate) => this(planDate: planDate);

  @override
  MealPlan targetSource(String? targetSource) =>
      this(targetSource: targetSource);

  @override
  MealPlan target(Nutrition? target) => this(target: target);

  @override
  MealPlan consumed(Nutrition? consumed) => this(consumed: consumed);

  @override
  MealPlan remaining(Nutrition? remaining) => this(remaining: remaining);

  @override
  MealPlan meals(List<Meal>? meals) => this(meals: meals);

  @override
  MealPlan warnings(List<String>? warnings) => this(warnings: warnings);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealPlan(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealPlan(...).copyWith(id: 12, name: "My name")
  /// ````
  MealPlan call({
    Object? id = const $CopyWithPlaceholder(),
    Object? planDate = const $CopyWithPlaceholder(),
    Object? targetSource = const $CopyWithPlaceholder(),
    Object? target = const $CopyWithPlaceholder(),
    Object? consumed = const $CopyWithPlaceholder(),
    Object? remaining = const $CopyWithPlaceholder(),
    Object? meals = const $CopyWithPlaceholder(),
    Object? warnings = const $CopyWithPlaceholder(),
  }) {
    return MealPlan(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      planDate: planDate == const $CopyWithPlaceholder()
          ? _value.planDate
          // ignore: cast_nullable_to_non_nullable
          : planDate as DateTime?,
      targetSource: targetSource == const $CopyWithPlaceholder()
          ? _value.targetSource
          // ignore: cast_nullable_to_non_nullable
          : targetSource as String?,
      target: target == const $CopyWithPlaceholder()
          ? _value.target
          // ignore: cast_nullable_to_non_nullable
          : target as Nutrition?,
      consumed: consumed == const $CopyWithPlaceholder()
          ? _value.consumed
          // ignore: cast_nullable_to_non_nullable
          : consumed as Nutrition?,
      remaining: remaining == const $CopyWithPlaceholder()
          ? _value.remaining
          // ignore: cast_nullable_to_non_nullable
          : remaining as Nutrition?,
      meals: meals == const $CopyWithPlaceholder()
          ? _value.meals
          // ignore: cast_nullable_to_non_nullable
          : meals as List<Meal>?,
      warnings: warnings == const $CopyWithPlaceholder()
          ? _value.warnings
          // ignore: cast_nullable_to_non_nullable
          : warnings as List<String>?,
    );
  }
}

extension $MealPlanCopyWith on MealPlan {
  /// Returns a callable class that can be used as follows: `instanceOfMealPlan.copyWith(...)` or like so:`instanceOfMealPlan.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MealPlanCWProxy get copyWith => _$MealPlanCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealPlan _$MealPlanFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MealPlan', json, ($checkedConvert) {
      final val = MealPlan(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        planDate: $checkedConvert(
          'planDate',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        targetSource: $checkedConvert('targetSource', (v) => v as String?),
        target: $checkedConvert(
          'target',
          (v) =>
              v == null ? null : Nutrition.fromJson(v as Map<String, dynamic>),
        ),
        consumed: $checkedConvert(
          'consumed',
          (v) =>
              v == null ? null : Nutrition.fromJson(v as Map<String, dynamic>),
        ),
        remaining: $checkedConvert(
          'remaining',
          (v) =>
              v == null ? null : Nutrition.fromJson(v as Map<String, dynamic>),
        ),
        meals: $checkedConvert(
          'meals',
          (v) => (v as List<dynamic>?)
              ?.map((e) => Meal.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        warnings: $checkedConvert(
          'warnings',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$MealPlanToJson(MealPlan instance) => <String, dynamic>{
  'id': ?instance.id,
  'planDate': ?instance.planDate?.toIso8601String(),
  'targetSource': ?instance.targetSource,
  'target': ?instance.target?.toJson(),
  'consumed': ?instance.consumed?.toJson(),
  'remaining': ?instance.remaining?.toJson(),
  'meals': ?instance.meals?.map((e) => e.toJson()).toList(),
  'warnings': ?instance.warnings,
};
