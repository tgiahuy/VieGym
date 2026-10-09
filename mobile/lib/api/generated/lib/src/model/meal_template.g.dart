// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_template.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MealTemplateCWProxy {
  MealTemplate id(int? id);

  MealTemplate name(String? name);

  MealTemplate description(String? description);

  MealTemplate sourceMealPlanId(int? sourceMealPlanId);

  MealTemplate items(List<TemplateItem>? items);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealTemplate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealTemplate(...).copyWith(id: 12, name: "My name")
  /// ````
  MealTemplate call({
    int? id,
    String? name,
    String? description,
    int? sourceMealPlanId,
    List<TemplateItem>? items,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMealTemplate.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMealTemplate.copyWith.fieldName(...)`
class _$MealTemplateCWProxyImpl implements _$MealTemplateCWProxy {
  const _$MealTemplateCWProxyImpl(this._value);

  final MealTemplate _value;

  @override
  MealTemplate id(int? id) => this(id: id);

  @override
  MealTemplate name(String? name) => this(name: name);

  @override
  MealTemplate description(String? description) =>
      this(description: description);

  @override
  MealTemplate sourceMealPlanId(int? sourceMealPlanId) =>
      this(sourceMealPlanId: sourceMealPlanId);

  @override
  MealTemplate items(List<TemplateItem>? items) => this(items: items);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealTemplate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealTemplate(...).copyWith(id: 12, name: "My name")
  /// ````
  MealTemplate call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? sourceMealPlanId = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return MealTemplate(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      sourceMealPlanId: sourceMealPlanId == const $CopyWithPlaceholder()
          ? _value.sourceMealPlanId
          // ignore: cast_nullable_to_non_nullable
          : sourceMealPlanId as int?,
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<TemplateItem>?,
    );
  }
}

extension $MealTemplateCopyWith on MealTemplate {
  /// Returns a callable class that can be used as follows: `instanceOfMealTemplate.copyWith(...)` or like so:`instanceOfMealTemplate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MealTemplateCWProxy get copyWith => _$MealTemplateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealTemplate _$MealTemplateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MealTemplate', json, ($checkedConvert) {
      final val = MealTemplate(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        name: $checkedConvert('name', (v) => v as String?),
        description: $checkedConvert('description', (v) => v as String?),
        sourceMealPlanId: $checkedConvert(
          'sourceMealPlanId',
          (v) => (v as num?)?.toInt(),
        ),
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>?)
              ?.map((e) => TemplateItem.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$MealTemplateToJson(MealTemplate instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'name': ?instance.name,
      'description': ?instance.description,
      'sourceMealPlanId': ?instance.sourceMealPlanId,
      'items': ?instance.items?.map((e) => e.toJson()).toList(),
    };
