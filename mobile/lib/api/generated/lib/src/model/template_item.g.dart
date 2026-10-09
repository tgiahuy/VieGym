// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_item.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TemplateItemCWProxy {
  TemplateItem id(int? id);

  TemplateItem foodId(int? foodId);

  TemplateItem foodName(String? foodName);

  TemplateItem mealType(String? mealType);

  TemplateItem sortOrder(int? sortOrder);

  TemplateItem servingMultiplier(num? servingMultiplier);

  TemplateItem servingAmount(num? servingAmount);

  TemplateItem servingUnit(String? servingUnit);

  TemplateItem available(bool? available);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TemplateItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TemplateItem(...).copyWith(id: 12, name: "My name")
  /// ````
  TemplateItem call({
    int? id,
    int? foodId,
    String? foodName,
    String? mealType,
    int? sortOrder,
    num? servingMultiplier,
    num? servingAmount,
    String? servingUnit,
    bool? available,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTemplateItem.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTemplateItem.copyWith.fieldName(...)`
class _$TemplateItemCWProxyImpl implements _$TemplateItemCWProxy {
  const _$TemplateItemCWProxyImpl(this._value);

  final TemplateItem _value;

  @override
  TemplateItem id(int? id) => this(id: id);

  @override
  TemplateItem foodId(int? foodId) => this(foodId: foodId);

  @override
  TemplateItem foodName(String? foodName) => this(foodName: foodName);

  @override
  TemplateItem mealType(String? mealType) => this(mealType: mealType);

  @override
  TemplateItem sortOrder(int? sortOrder) => this(sortOrder: sortOrder);

  @override
  TemplateItem servingMultiplier(num? servingMultiplier) =>
      this(servingMultiplier: servingMultiplier);

  @override
  TemplateItem servingAmount(num? servingAmount) =>
      this(servingAmount: servingAmount);

  @override
  TemplateItem servingUnit(String? servingUnit) =>
      this(servingUnit: servingUnit);

  @override
  TemplateItem available(bool? available) => this(available: available);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TemplateItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TemplateItem(...).copyWith(id: 12, name: "My name")
  /// ````
  TemplateItem call({
    Object? id = const $CopyWithPlaceholder(),
    Object? foodId = const $CopyWithPlaceholder(),
    Object? foodName = const $CopyWithPlaceholder(),
    Object? mealType = const $CopyWithPlaceholder(),
    Object? sortOrder = const $CopyWithPlaceholder(),
    Object? servingMultiplier = const $CopyWithPlaceholder(),
    Object? servingAmount = const $CopyWithPlaceholder(),
    Object? servingUnit = const $CopyWithPlaceholder(),
    Object? available = const $CopyWithPlaceholder(),
  }) {
    return TemplateItem(
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
      sortOrder: sortOrder == const $CopyWithPlaceholder()
          ? _value.sortOrder
          // ignore: cast_nullable_to_non_nullable
          : sortOrder as int?,
      servingMultiplier: servingMultiplier == const $CopyWithPlaceholder()
          ? _value.servingMultiplier
          // ignore: cast_nullable_to_non_nullable
          : servingMultiplier as num?,
      servingAmount: servingAmount == const $CopyWithPlaceholder()
          ? _value.servingAmount
          // ignore: cast_nullable_to_non_nullable
          : servingAmount as num?,
      servingUnit: servingUnit == const $CopyWithPlaceholder()
          ? _value.servingUnit
          // ignore: cast_nullable_to_non_nullable
          : servingUnit as String?,
      available: available == const $CopyWithPlaceholder()
          ? _value.available
          // ignore: cast_nullable_to_non_nullable
          : available as bool?,
    );
  }
}

extension $TemplateItemCopyWith on TemplateItem {
  /// Returns a callable class that can be used as follows: `instanceOfTemplateItem.copyWith(...)` or like so:`instanceOfTemplateItem.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TemplateItemCWProxy get copyWith => _$TemplateItemCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TemplateItem _$TemplateItemFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TemplateItem', json, ($checkedConvert) {
      final val = TemplateItem(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        foodId: $checkedConvert('foodId', (v) => (v as num?)?.toInt()),
        foodName: $checkedConvert('foodName', (v) => v as String?),
        mealType: $checkedConvert('mealType', (v) => v as String?),
        sortOrder: $checkedConvert('sortOrder', (v) => (v as num?)?.toInt()),
        servingMultiplier: $checkedConvert(
          'servingMultiplier',
          (v) => v as num?,
        ),
        servingAmount: $checkedConvert('servingAmount', (v) => v as num?),
        servingUnit: $checkedConvert('servingUnit', (v) => v as String?),
        available: $checkedConvert('available', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$TemplateItemToJson(TemplateItem instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'foodId': ?instance.foodId,
      'foodName': ?instance.foodName,
      'mealType': ?instance.mealType,
      'sortOrder': ?instance.sortOrder,
      'servingMultiplier': ?instance.servingMultiplier,
      'servingAmount': ?instance.servingAmount,
      'servingUnit': ?instance.servingUnit,
      'available': ?instance.available,
    };
