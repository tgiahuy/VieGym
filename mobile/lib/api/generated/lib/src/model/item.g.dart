// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ItemCWProxy {
  Item foodId(int? foodId);

  Item mealType(String mealType);

  Item sortOrder(int? sortOrder);

  Item servingMultiplier(num? servingMultiplier);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Item(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Item(...).copyWith(id: 12, name: "My name")
  /// ````
  Item call({
    int? foodId,
    String mealType,
    int? sortOrder,
    num? servingMultiplier,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfItem.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfItem.copyWith.fieldName(...)`
class _$ItemCWProxyImpl implements _$ItemCWProxy {
  const _$ItemCWProxyImpl(this._value);

  final Item _value;

  @override
  Item foodId(int? foodId) => this(foodId: foodId);

  @override
  Item mealType(String mealType) => this(mealType: mealType);

  @override
  Item sortOrder(int? sortOrder) => this(sortOrder: sortOrder);

  @override
  Item servingMultiplier(num? servingMultiplier) =>
      this(servingMultiplier: servingMultiplier);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Item(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Item(...).copyWith(id: 12, name: "My name")
  /// ````
  Item call({
    Object? foodId = const $CopyWithPlaceholder(),
    Object? mealType = const $CopyWithPlaceholder(),
    Object? sortOrder = const $CopyWithPlaceholder(),
    Object? servingMultiplier = const $CopyWithPlaceholder(),
  }) {
    return Item(
      foodId: foodId == const $CopyWithPlaceholder()
          ? _value.foodId
          // ignore: cast_nullable_to_non_nullable
          : foodId as int?,
      mealType: mealType == const $CopyWithPlaceholder()
          ? _value.mealType
          // ignore: cast_nullable_to_non_nullable
          : mealType as String,
      sortOrder: sortOrder == const $CopyWithPlaceholder()
          ? _value.sortOrder
          // ignore: cast_nullable_to_non_nullable
          : sortOrder as int?,
      servingMultiplier: servingMultiplier == const $CopyWithPlaceholder()
          ? _value.servingMultiplier
          // ignore: cast_nullable_to_non_nullable
          : servingMultiplier as num?,
    );
  }
}

extension $ItemCopyWith on Item {
  /// Returns a callable class that can be used as follows: `instanceOfItem.copyWith(...)` or like so:`instanceOfItem.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ItemCWProxy get copyWith => _$ItemCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) => $checkedCreate('Item', json, (
  $checkedConvert,
) {
  $checkKeys(json, requiredKeys: const ['mealType']);
  final val = Item(
    foodId: $checkedConvert('foodId', (v) => (v as num?)?.toInt()),
    mealType: $checkedConvert('mealType', (v) => v as String),
    sortOrder: $checkedConvert('sortOrder', (v) => (v as num?)?.toInt()),
    servingMultiplier: $checkedConvert('servingMultiplier', (v) => v as num?),
  );
  return val;
});

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
  'foodId': ?instance.foodId,
  'mealType': instance.mealType,
  'sortOrder': ?instance.sortOrder,
  'servingMultiplier': ?instance.servingMultiplier,
};
