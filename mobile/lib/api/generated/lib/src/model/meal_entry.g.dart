// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_entry.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MealEntryCWProxy {
  MealEntry id(int? id);

  MealEntry foodId(int? foodId);

  MealEntry foodName(String? foodName);

  MealEntry mealType(String? mealType);

  MealEntry mealSortOrder(int? mealSortOrder);

  MealEntry servingMultiplier(num? servingMultiplier);

  MealEntry inputAmount(num? inputAmount);

  MealEntry inputUnit(String? inputUnit);

  MealEntry servingAmount(num? servingAmount);

  MealEntry servingUnit(String? servingUnit);

  MealEntry nutrition(Nutrition? nutrition);

  MealEntry estimated(bool? estimated);

  MealEntry note(String? note);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealEntry(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealEntry(...).copyWith(id: 12, name: "My name")
  /// ````
  MealEntry call({
    int? id,
    int? foodId,
    String? foodName,
    String? mealType,
    int? mealSortOrder,
    num? servingMultiplier,
    num? inputAmount,
    String? inputUnit,
    num? servingAmount,
    String? servingUnit,
    Nutrition? nutrition,
    bool? estimated,
    String? note,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMealEntry.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMealEntry.copyWith.fieldName(...)`
class _$MealEntryCWProxyImpl implements _$MealEntryCWProxy {
  const _$MealEntryCWProxyImpl(this._value);

  final MealEntry _value;

  @override
  MealEntry id(int? id) => this(id: id);

  @override
  MealEntry foodId(int? foodId) => this(foodId: foodId);

  @override
  MealEntry foodName(String? foodName) => this(foodName: foodName);

  @override
  MealEntry mealType(String? mealType) => this(mealType: mealType);

  @override
  MealEntry mealSortOrder(int? mealSortOrder) =>
      this(mealSortOrder: mealSortOrder);

  @override
  MealEntry servingMultiplier(num? servingMultiplier) =>
      this(servingMultiplier: servingMultiplier);

  @override
  MealEntry inputAmount(num? inputAmount) => this(inputAmount: inputAmount);

  @override
  MealEntry inputUnit(String? inputUnit) => this(inputUnit: inputUnit);

  @override
  MealEntry servingAmount(num? servingAmount) =>
      this(servingAmount: servingAmount);

  @override
  MealEntry servingUnit(String? servingUnit) => this(servingUnit: servingUnit);

  @override
  MealEntry nutrition(Nutrition? nutrition) => this(nutrition: nutrition);

  @override
  MealEntry estimated(bool? estimated) => this(estimated: estimated);

  @override
  MealEntry note(String? note) => this(note: note);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealEntry(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealEntry(...).copyWith(id: 12, name: "My name")
  /// ````
  MealEntry call({
    Object? id = const $CopyWithPlaceholder(),
    Object? foodId = const $CopyWithPlaceholder(),
    Object? foodName = const $CopyWithPlaceholder(),
    Object? mealType = const $CopyWithPlaceholder(),
    Object? mealSortOrder = const $CopyWithPlaceholder(),
    Object? servingMultiplier = const $CopyWithPlaceholder(),
    Object? inputAmount = const $CopyWithPlaceholder(),
    Object? inputUnit = const $CopyWithPlaceholder(),
    Object? servingAmount = const $CopyWithPlaceholder(),
    Object? servingUnit = const $CopyWithPlaceholder(),
    Object? nutrition = const $CopyWithPlaceholder(),
    Object? estimated = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
  }) {
    return MealEntry(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      foodId: foodId == const $CopyWithPlaceholder()
          ? _value.foodId
          // ignore: cast_nullable_to_non_nullable
          : foodId as int?,
      foodName: foodName == const $CopyWithPlaceholder()
          ? _value.foodName
          // ignore: cast_nullable_to_non_nullable
          : foodName as String?,
      mealType: mealType == const $CopyWithPlaceholder()
          ? _value.mealType
          // ignore: cast_nullable_to_non_nullable
          : mealType as String?,
      mealSortOrder: mealSortOrder == const $CopyWithPlaceholder()
          ? _value.mealSortOrder
          // ignore: cast_nullable_to_non_nullable
          : mealSortOrder as int?,
      servingMultiplier: servingMultiplier == const $CopyWithPlaceholder()
          ? _value.servingMultiplier
          // ignore: cast_nullable_to_non_nullable
          : servingMultiplier as num?,
      inputAmount: inputAmount == const $CopyWithPlaceholder()
          ? _value.inputAmount
          // ignore: cast_nullable_to_non_nullable
          : inputAmount as num?,
      inputUnit: inputUnit == const $CopyWithPlaceholder()
          ? _value.inputUnit
          // ignore: cast_nullable_to_non_nullable
          : inputUnit as String?,
      servingAmount: servingAmount == const $CopyWithPlaceholder()
          ? _value.servingAmount
          // ignore: cast_nullable_to_non_nullable
          : servingAmount as num?,
      servingUnit: servingUnit == const $CopyWithPlaceholder()
          ? _value.servingUnit
          // ignore: cast_nullable_to_non_nullable
          : servingUnit as String?,
      nutrition: nutrition == const $CopyWithPlaceholder()
          ? _value.nutrition
          // ignore: cast_nullable_to_non_nullable
          : nutrition as Nutrition?,
      estimated: estimated == const $CopyWithPlaceholder()
          ? _value.estimated
          // ignore: cast_nullable_to_non_nullable
          : estimated as bool?,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
    );
  }
}

extension $MealEntryCopyWith on MealEntry {
  /// Returns a callable class that can be used as follows: `instanceOfMealEntry.copyWith(...)` or like so:`instanceOfMealEntry.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MealEntryCWProxy get copyWith => _$MealEntryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealEntry _$MealEntryFromJson(Map<String, dynamic> json) => $checkedCreate(
  'MealEntry',
  json,
  ($checkedConvert) {
    final val = MealEntry(
      id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
      foodId: $checkedConvert('foodId', (v) => (v as num?)?.toInt()),
      foodName: $checkedConvert('foodName', (v) => v as String?),
      mealType: $checkedConvert('mealType', (v) => v as String?),
      mealSortOrder: $checkedConvert(
        'mealSortOrder',
        (v) => (v as num?)?.toInt(),
      ),
      servingMultiplier: $checkedConvert('servingMultiplier', (v) => v as num?),
      inputAmount: $checkedConvert('inputAmount', (v) => v as num?),
      inputUnit: $checkedConvert('inputUnit', (v) => v as String?),
      servingAmount: $checkedConvert('servingAmount', (v) => v as num?),
      servingUnit: $checkedConvert('servingUnit', (v) => v as String?),
      nutrition: $checkedConvert(
        'nutrition',
        (v) => v == null ? null : Nutrition.fromJson(v as Map<String, dynamic>),
      ),
      estimated: $checkedConvert('estimated', (v) => v as bool?),
      note: $checkedConvert('note', (v) => v as String?),
    );
    return val;
  },
);

Map<String, dynamic> _$MealEntryToJson(MealEntry instance) => <String, dynamic>{
  'id': ?instance.id,
  'foodId': ?instance.foodId,
  'foodName': ?instance.foodName,
  'mealType': ?instance.mealType,
  'mealSortOrder': ?instance.mealSortOrder,
  'servingMultiplier': ?instance.servingMultiplier,
  'inputAmount': ?instance.inputAmount,
  'inputUnit': ?instance.inputUnit,
  'servingAmount': ?instance.servingAmount,
  'servingUnit': ?instance.servingUnit,
  'nutrition': ?instance.nutrition?.toJson(),
  'estimated': ?instance.estimated,
  'note': ?instance.note,
};
