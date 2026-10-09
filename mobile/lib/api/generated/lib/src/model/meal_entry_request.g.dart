// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_entry_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MealEntryRequestCWProxy {
  MealEntryRequest mealType(String mealType);

  MealEntryRequest mealSortOrder(int? mealSortOrder);

  MealEntryRequest foodId(int? foodId);

  MealEntryRequest servingMultiplier(num? servingMultiplier);

  MealEntryRequest inputAmount(num? inputAmount);

  MealEntryRequest inputUnit(String? inputUnit);

  MealEntryRequest note(String? note);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealEntryRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealEntryRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  MealEntryRequest call({
    String mealType,
    int? mealSortOrder,
    int? foodId,
    num? servingMultiplier,
    num? inputAmount,
    String? inputUnit,
    String? note,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMealEntryRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMealEntryRequest.copyWith.fieldName(...)`
class _$MealEntryRequestCWProxyImpl implements _$MealEntryRequestCWProxy {
  const _$MealEntryRequestCWProxyImpl(this._value);

  final MealEntryRequest _value;

  @override
  MealEntryRequest mealType(String mealType) => this(mealType: mealType);

  @override
  MealEntryRequest mealSortOrder(int? mealSortOrder) =>
      this(mealSortOrder: mealSortOrder);

  @override
  MealEntryRequest foodId(int? foodId) => this(foodId: foodId);

  @override
  MealEntryRequest servingMultiplier(num? servingMultiplier) =>
      this(servingMultiplier: servingMultiplier);

  @override
  MealEntryRequest inputAmount(num? inputAmount) =>
      this(inputAmount: inputAmount);

  @override
  MealEntryRequest inputUnit(String? inputUnit) => this(inputUnit: inputUnit);

  @override
  MealEntryRequest note(String? note) => this(note: note);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealEntryRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealEntryRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  MealEntryRequest call({
    Object? mealType = const $CopyWithPlaceholder(),
    Object? mealSortOrder = const $CopyWithPlaceholder(),
    Object? foodId = const $CopyWithPlaceholder(),
    Object? servingMultiplier = const $CopyWithPlaceholder(),
    Object? inputAmount = const $CopyWithPlaceholder(),
    Object? inputUnit = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
  }) {
    return MealEntryRequest(
      mealType: mealType == const $CopyWithPlaceholder()
          ? _value.mealType
          // ignore: cast_nullable_to_non_nullable
          : mealType as String,
      mealSortOrder: mealSortOrder == const $CopyWithPlaceholder()
          ? _value.mealSortOrder
          // ignore: cast_nullable_to_non_nullable
          : mealSortOrder as int?,
      foodId: foodId == const $CopyWithPlaceholder()
          ? _value.foodId
          // ignore: cast_nullable_to_non_nullable
          : foodId as int?,
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
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
    );
  }
}

extension $MealEntryRequestCopyWith on MealEntryRequest {
  /// Returns a callable class that can be used as follows: `instanceOfMealEntryRequest.copyWith(...)` or like so:`instanceOfMealEntryRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MealEntryRequestCWProxy get copyWith => _$MealEntryRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealEntryRequest _$MealEntryRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MealEntryRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['mealType']);
      final val = MealEntryRequest(
        mealType: $checkedConvert('mealType', (v) => v as String),
        mealSortOrder: $checkedConvert(
          'mealSortOrder',
          (v) => (v as num?)?.toInt(),
        ),
        foodId: $checkedConvert('foodId', (v) => (v as num?)?.toInt()),
        servingMultiplier: $checkedConvert(
          'servingMultiplier',
          (v) => v as num?,
        ),
        inputAmount: $checkedConvert('inputAmount', (v) => v as num?),
        inputUnit: $checkedConvert('inputUnit', (v) => v as String?),
        note: $checkedConvert('note', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$MealEntryRequestToJson(MealEntryRequest instance) =>
    <String, dynamic>{
      'mealType': instance.mealType,
      'mealSortOrder': ?instance.mealSortOrder,
      'foodId': ?instance.foodId,
      'servingMultiplier': ?instance.servingMultiplier,
      'inputAmount': ?instance.inputAmount,
      'inputUnit': ?instance.inputUnit,
      'note': ?instance.note,
    };
