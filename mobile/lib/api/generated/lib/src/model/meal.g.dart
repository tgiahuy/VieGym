// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MealCWProxy {
  Meal id(int? id);

  Meal mealType(String? mealType);

  Meal name(String? name);

  Meal sortOrder(int? sortOrder);

  Meal subtotal(Nutrition? subtotal);

  Meal entries(List<MealEntry>? entries);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Meal(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Meal(...).copyWith(id: 12, name: "My name")
  /// ````
  Meal call({
    int? id,
    String? mealType,
    String? name,
    int? sortOrder,
    Nutrition? subtotal,
    List<MealEntry>? entries,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeal.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeal.copyWith.fieldName(...)`
class _$MealCWProxyImpl implements _$MealCWProxy {
  const _$MealCWProxyImpl(this._value);

  final Meal _value;

  @override
  Meal id(int? id) => this(id: id);

  @override
  Meal mealType(String? mealType) => this(mealType: mealType);

  @override
  Meal name(String? name) => this(name: name);

  @override
  Meal sortOrder(int? sortOrder) => this(sortOrder: sortOrder);

  @override
  Meal subtotal(Nutrition? subtotal) => this(subtotal: subtotal);

  @override
  Meal entries(List<MealEntry>? entries) => this(entries: entries);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Meal(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Meal(...).copyWith(id: 12, name: "My name")
  /// ````
  Meal call({
    Object? id = const $CopyWithPlaceholder(),
    Object? mealType = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? sortOrder = const $CopyWithPlaceholder(),
    Object? subtotal = const $CopyWithPlaceholder(),
    Object? entries = const $CopyWithPlaceholder(),
  }) {
    return Meal(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      mealType: mealType == const $CopyWithPlaceholder()
          ? _value.mealType
          // ignore: cast_nullable_to_non_nullable
          : mealType as String?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      sortOrder: sortOrder == const $CopyWithPlaceholder()
          ? _value.sortOrder
          // ignore: cast_nullable_to_non_nullable
          : sortOrder as int?,
      subtotal: subtotal == const $CopyWithPlaceholder()
          ? _value.subtotal
          // ignore: cast_nullable_to_non_nullable
          : subtotal as Nutrition?,
      entries: entries == const $CopyWithPlaceholder()
          ? _value.entries
          // ignore: cast_nullable_to_non_nullable
          : entries as List<MealEntry>?,
    );
  }
}

extension $MealCopyWith on Meal {
  /// Returns a callable class that can be used as follows: `instanceOfMeal.copyWith(...)` or like so:`instanceOfMeal.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MealCWProxy get copyWith => _$MealCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Meal _$MealFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Meal', json, ($checkedConvert) {
      final val = Meal(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        mealType: $checkedConvert('mealType', (v) => v as String?),
        name: $checkedConvert('name', (v) => v as String?),
        sortOrder: $checkedConvert('sortOrder', (v) => (v as num?)?.toInt()),
        subtotal: $checkedConvert(
          'subtotal',
          (v) =>
              v == null ? null : Nutrition.fromJson(v as Map<String, dynamic>),
        ),
        entries: $checkedConvert(
          'entries',
          (v) => (v as List<dynamic>?)
              ?.map((e) => MealEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$MealToJson(Meal instance) => <String, dynamic>{
  'id': ?instance.id,
  'mealType': ?instance.mealType,
  'name': ?instance.name,
  'sortOrder': ?instance.sortOrder,
  'subtotal': ?instance.subtotal?.toJson(),
  'entries': ?instance.entries?.map((e) => e.toJson()).toList(),
};
