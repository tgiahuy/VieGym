// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_meal_template_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateMealTemplateRequestCWProxy {
  CreateMealTemplateRequest name(String name);

  CreateMealTemplateRequest description(String? description);

  CreateMealTemplateRequest sourceMealPlanId(int? sourceMealPlanId);

  CreateMealTemplateRequest items(List<Item>? items);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateMealTemplateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateMealTemplateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateMealTemplateRequest call({
    String name,
    String? description,
    int? sourceMealPlanId,
    List<Item>? items,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateMealTemplateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateMealTemplateRequest.copyWith.fieldName(...)`
class _$CreateMealTemplateRequestCWProxyImpl
    implements _$CreateMealTemplateRequestCWProxy {
  const _$CreateMealTemplateRequestCWProxyImpl(this._value);

  final CreateMealTemplateRequest _value;

  @override
  CreateMealTemplateRequest name(String name) => this(name: name);

  @override
  CreateMealTemplateRequest description(String? description) =>
      this(description: description);

  @override
  CreateMealTemplateRequest sourceMealPlanId(int? sourceMealPlanId) =>
      this(sourceMealPlanId: sourceMealPlanId);

  @override
  CreateMealTemplateRequest items(List<Item>? items) => this(items: items);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateMealTemplateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateMealTemplateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateMealTemplateRequest call({
    Object? name = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? sourceMealPlanId = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return CreateMealTemplateRequest(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
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
          : items as List<Item>?,
    );
  }
}

extension $CreateMealTemplateRequestCopyWith on CreateMealTemplateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateMealTemplateRequest.copyWith(...)` or like so:`instanceOfCreateMealTemplateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateMealTemplateRequestCWProxy get copyWith =>
      _$CreateMealTemplateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateMealTemplateRequest _$CreateMealTemplateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateMealTemplateRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['name']);
  final val = CreateMealTemplateRequest(
    name: $checkedConvert('name', (v) => v as String),
    description: $checkedConvert('description', (v) => v as String?),
    sourceMealPlanId: $checkedConvert(
      'sourceMealPlanId',
      (v) => (v as num?)?.toInt(),
    ),
    items: $checkedConvert(
      'items',
      (v) => (v as List<dynamic>?)
          ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$CreateMealTemplateRequestToJson(
  CreateMealTemplateRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': ?instance.description,
  'sourceMealPlanId': ?instance.sourceMealPlanId,
  'items': ?instance.items?.map((e) => e.toJson()).toList(),
};
