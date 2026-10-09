// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FoodCWProxy {
  Food id(int? id);

  Food name(String? name);

  Food slug(String? slug);

  Food category(String? category);

  Food serving(Serving? serving);

  Food nutritionPerServing(Nutrition? nutritionPerServing);

  Food dataSource(String? dataSource);

  Food sourceNote(String? sourceNote);

  Food estimated(bool? estimated);

  Food selectable(bool? selectable);

  Food media(List<Object>? media);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Food(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Food(...).copyWith(id: 12, name: "My name")
  /// ````
  Food call({
    int? id,
    String? name,
    String? slug,
    String? category,
    Serving? serving,
    Nutrition? nutritionPerServing,
    String? dataSource,
    String? sourceNote,
    bool? estimated,
    bool? selectable,
    List<Object>? media,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFood.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFood.copyWith.fieldName(...)`
class _$FoodCWProxyImpl implements _$FoodCWProxy {
  const _$FoodCWProxyImpl(this._value);

  final Food _value;

  @override
  Food id(int? id) => this(id: id);

  @override
  Food name(String? name) => this(name: name);

  @override
  Food slug(String? slug) => this(slug: slug);

  @override
  Food category(String? category) => this(category: category);

  @override
  Food serving(Serving? serving) => this(serving: serving);

  @override
  Food nutritionPerServing(Nutrition? nutritionPerServing) =>
      this(nutritionPerServing: nutritionPerServing);

  @override
  Food dataSource(String? dataSource) => this(dataSource: dataSource);

  @override
  Food sourceNote(String? sourceNote) => this(sourceNote: sourceNote);

  @override
  Food estimated(bool? estimated) => this(estimated: estimated);

  @override
  Food selectable(bool? selectable) => this(selectable: selectable);

  @override
  Food media(List<Object>? media) => this(media: media);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Food(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Food(...).copyWith(id: 12, name: "My name")
  /// ````
  Food call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? slug = const $CopyWithPlaceholder(),
    Object? category = const $CopyWithPlaceholder(),
    Object? serving = const $CopyWithPlaceholder(),
    Object? nutritionPerServing = const $CopyWithPlaceholder(),
    Object? dataSource = const $CopyWithPlaceholder(),
    Object? sourceNote = const $CopyWithPlaceholder(),
    Object? estimated = const $CopyWithPlaceholder(),
    Object? selectable = const $CopyWithPlaceholder(),
    Object? media = const $CopyWithPlaceholder(),
  }) {
    return Food(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      slug: slug == const $CopyWithPlaceholder()
          ? _value.slug
          // ignore: cast_nullable_to_non_nullable
          : slug as String?,
      category: category == const $CopyWithPlaceholder()
          ? _value.category
          // ignore: cast_nullable_to_non_nullable
          : category as String?,
      serving: serving == const $CopyWithPlaceholder()
          ? _value.serving
          // ignore: cast_nullable_to_non_nullable
          : serving as Serving?,
      nutritionPerServing: nutritionPerServing == const $CopyWithPlaceholder()
          ? _value.nutritionPerServing
          // ignore: cast_nullable_to_non_nullable
          : nutritionPerServing as Nutrition?,
      dataSource: dataSource == const $CopyWithPlaceholder()
          ? _value.dataSource
          // ignore: cast_nullable_to_non_nullable
          : dataSource as String?,
      sourceNote: sourceNote == const $CopyWithPlaceholder()
          ? _value.sourceNote
          // ignore: cast_nullable_to_non_nullable
          : sourceNote as String?,
      estimated: estimated == const $CopyWithPlaceholder()
          ? _value.estimated
          // ignore: cast_nullable_to_non_nullable
          : estimated as bool?,
      selectable: selectable == const $CopyWithPlaceholder()
          ? _value.selectable
          // ignore: cast_nullable_to_non_nullable
          : selectable as bool?,
      media: media == const $CopyWithPlaceholder()
          ? _value.media
          // ignore: cast_nullable_to_non_nullable
          : media as List<Object>?,
    );
  }
}

extension $FoodCopyWith on Food {
  /// Returns a callable class that can be used as follows: `instanceOfFood.copyWith(...)` or like so:`instanceOfFood.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FoodCWProxy get copyWith => _$FoodCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Food _$FoodFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Food', json, ($checkedConvert) {
      final val = Food(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        name: $checkedConvert('name', (v) => v as String?),
        slug: $checkedConvert('slug', (v) => v as String?),
        category: $checkedConvert('category', (v) => v as String?),
        serving: $checkedConvert(
          'serving',
          (v) => v == null ? null : Serving.fromJson(v as Map<String, dynamic>),
        ),
        nutritionPerServing: $checkedConvert(
          'nutritionPerServing',
          (v) =>
              v == null ? null : Nutrition.fromJson(v as Map<String, dynamic>),
        ),
        dataSource: $checkedConvert('dataSource', (v) => v as String?),
        sourceNote: $checkedConvert('sourceNote', (v) => v as String?),
        estimated: $checkedConvert('estimated', (v) => v as bool?),
        selectable: $checkedConvert('selectable', (v) => v as bool?),
        media: $checkedConvert(
          'media',
          (v) => (v as List<dynamic>?)?.map((e) => e as Object).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$FoodToJson(Food instance) => <String, dynamic>{
  'id': ?instance.id,
  'name': ?instance.name,
  'slug': ?instance.slug,
  'category': ?instance.category,
  'serving': ?instance.serving?.toJson(),
  'nutritionPerServing': ?instance.nutritionPerServing?.toJson(),
  'dataSource': ?instance.dataSource,
  'sourceNote': ?instance.sourceNote,
  'estimated': ?instance.estimated,
  'selectable': ?instance.selectable,
  'media': ?instance.media,
};
