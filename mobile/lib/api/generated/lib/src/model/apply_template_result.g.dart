// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apply_template_result.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApplyTemplateResultCWProxy {
  ApplyTemplateResult applied(bool? applied);

  ApplyTemplateResult targetDate(DateTime? targetDate);

  ApplyTemplateResult copiedItems(int? copiedItems);

  ApplyTemplateResult blockedItems(List<TemplateItem>? blockedItems);

  ApplyTemplateResult mealPlan(MealPlan? mealPlan);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApplyTemplateResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApplyTemplateResult(...).copyWith(id: 12, name: "My name")
  /// ````
  ApplyTemplateResult call({
    bool? applied,
    DateTime? targetDate,
    int? copiedItems,
    List<TemplateItem>? blockedItems,
    MealPlan? mealPlan,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApplyTemplateResult.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApplyTemplateResult.copyWith.fieldName(...)`
class _$ApplyTemplateResultCWProxyImpl implements _$ApplyTemplateResultCWProxy {
  const _$ApplyTemplateResultCWProxyImpl(this._value);

  final ApplyTemplateResult _value;

  @override
  ApplyTemplateResult applied(bool? applied) => this(applied: applied);

  @override
  ApplyTemplateResult targetDate(DateTime? targetDate) =>
      this(targetDate: targetDate);

  @override
  ApplyTemplateResult copiedItems(int? copiedItems) =>
      this(copiedItems: copiedItems);

  @override
  ApplyTemplateResult blockedItems(List<TemplateItem>? blockedItems) =>
      this(blockedItems: blockedItems);

  @override
  ApplyTemplateResult mealPlan(MealPlan? mealPlan) => this(mealPlan: mealPlan);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApplyTemplateResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApplyTemplateResult(...).copyWith(id: 12, name: "My name")
  /// ````
  ApplyTemplateResult call({
    Object? applied = const $CopyWithPlaceholder(),
    Object? targetDate = const $CopyWithPlaceholder(),
    Object? copiedItems = const $CopyWithPlaceholder(),
    Object? blockedItems = const $CopyWithPlaceholder(),
    Object? mealPlan = const $CopyWithPlaceholder(),
  }) {
    return ApplyTemplateResult(
      applied: applied == const $CopyWithPlaceholder()
          ? _value.applied
          // ignore: cast_nullable_to_non_nullable
          : applied as bool?,
      targetDate: targetDate == const $CopyWithPlaceholder()
          ? _value.targetDate
          // ignore: cast_nullable_to_non_nullable
          : targetDate as DateTime?,
      copiedItems: copiedItems == const $CopyWithPlaceholder()
          ? _value.copiedItems
          // ignore: cast_nullable_to_non_nullable
          : copiedItems as int?,
      blockedItems: blockedItems == const $CopyWithPlaceholder()
          ? _value.blockedItems
          // ignore: cast_nullable_to_non_nullable
          : blockedItems as List<TemplateItem>?,
      mealPlan: mealPlan == const $CopyWithPlaceholder()
          ? _value.mealPlan
          // ignore: cast_nullable_to_non_nullable
          : mealPlan as MealPlan?,
    );
  }
}

extension $ApplyTemplateResultCopyWith on ApplyTemplateResult {
  /// Returns a callable class that can be used as follows: `instanceOfApplyTemplateResult.copyWith(...)` or like so:`instanceOfApplyTemplateResult.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApplyTemplateResultCWProxy get copyWith =>
      _$ApplyTemplateResultCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApplyTemplateResult _$ApplyTemplateResultFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ApplyTemplateResult', json, ($checkedConvert) {
      final val = ApplyTemplateResult(
        applied: $checkedConvert('applied', (v) => v as bool?),
        targetDate: $checkedConvert(
          'targetDate',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        copiedItems: $checkedConvert(
          'copiedItems',
          (v) => (v as num?)?.toInt(),
        ),
        blockedItems: $checkedConvert(
          'blockedItems',
          (v) => (v as List<dynamic>?)
              ?.map((e) => TemplateItem.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        mealPlan: $checkedConvert(
          'mealPlan',
          (v) =>
              v == null ? null : MealPlan.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ApplyTemplateResultToJson(
  ApplyTemplateResult instance,
) => <String, dynamic>{
  'applied': ?instance.applied,
  'targetDate': ?instance.targetDate?.toIso8601String(),
  'copiedItems': ?instance.copiedItems,
  'blockedItems': ?instance.blockedItems?.map((e) => e.toJson()).toList(),
  'mealPlan': ?instance.mealPlan?.toJson(),
};
