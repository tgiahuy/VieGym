// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_response_meal_plan.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PageResponseMealPlanCWProxy {
  PageResponseMealPlan content(List<MealPlan>? content);

  PageResponseMealPlan page(int? page);

  PageResponseMealPlan size(int? size);

  PageResponseMealPlan totalElements(int? totalElements);

  PageResponseMealPlan totalPages(int? totalPages);

  PageResponseMealPlan hasNext(bool? hasNext);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PageResponseMealPlan(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PageResponseMealPlan(...).copyWith(id: 12, name: "My name")
  /// ````
  PageResponseMealPlan call({
    List<MealPlan>? content,
    int? page,
    int? size,
    int? totalElements,
    int? totalPages,
    bool? hasNext,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPageResponseMealPlan.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPageResponseMealPlan.copyWith.fieldName(...)`
class _$PageResponseMealPlanCWProxyImpl
    implements _$PageResponseMealPlanCWProxy {
  const _$PageResponseMealPlanCWProxyImpl(this._value);

  final PageResponseMealPlan _value;

  @override
  PageResponseMealPlan content(List<MealPlan>? content) =>
      this(content: content);

  @override
  PageResponseMealPlan page(int? page) => this(page: page);

  @override
  PageResponseMealPlan size(int? size) => this(size: size);

  @override
  PageResponseMealPlan totalElements(int? totalElements) =>
      this(totalElements: totalElements);

  @override
  PageResponseMealPlan totalPages(int? totalPages) =>
      this(totalPages: totalPages);

  @override
  PageResponseMealPlan hasNext(bool? hasNext) => this(hasNext: hasNext);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PageResponseMealPlan(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PageResponseMealPlan(...).copyWith(id: 12, name: "My name")
  /// ````
  PageResponseMealPlan call({
    Object? content = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? size = const $CopyWithPlaceholder(),
    Object? totalElements = const $CopyWithPlaceholder(),
    Object? totalPages = const $CopyWithPlaceholder(),
    Object? hasNext = const $CopyWithPlaceholder(),
  }) {
    return PageResponseMealPlan(
      content: content == const $CopyWithPlaceholder()
          ? _value.content
          // ignore: cast_nullable_to_non_nullable
          : content as List<MealPlan>?,
      page: page == const $CopyWithPlaceholder()
          ? _value.page
          // ignore: cast_nullable_to_non_nullable
          : page as int?,
      size: size == const $CopyWithPlaceholder()
          ? _value.size
          // ignore: cast_nullable_to_non_nullable
          : size as int?,
      totalElements: totalElements == const $CopyWithPlaceholder()
          ? _value.totalElements
          // ignore: cast_nullable_to_non_nullable
          : totalElements as int?,
      totalPages: totalPages == const $CopyWithPlaceholder()
          ? _value.totalPages
          // ignore: cast_nullable_to_non_nullable
          : totalPages as int?,
      hasNext: hasNext == const $CopyWithPlaceholder()
          ? _value.hasNext
          // ignore: cast_nullable_to_non_nullable
          : hasNext as bool?,
    );
  }
}

extension $PageResponseMealPlanCopyWith on PageResponseMealPlan {
  /// Returns a callable class that can be used as follows: `instanceOfPageResponseMealPlan.copyWith(...)` or like so:`instanceOfPageResponseMealPlan.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PageResponseMealPlanCWProxy get copyWith =>
      _$PageResponseMealPlanCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageResponseMealPlan _$PageResponseMealPlanFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PageResponseMealPlan', json, ($checkedConvert) {
  final val = PageResponseMealPlan(
    content: $checkedConvert(
      'content',
      (v) => (v as List<dynamic>?)
          ?.map((e) => MealPlan.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    page: $checkedConvert('page', (v) => (v as num?)?.toInt()),
    size: $checkedConvert('size', (v) => (v as num?)?.toInt()),
    totalElements: $checkedConvert(
      'totalElements',
      (v) => (v as num?)?.toInt(),
    ),
    totalPages: $checkedConvert('totalPages', (v) => (v as num?)?.toInt()),
    hasNext: $checkedConvert('hasNext', (v) => v as bool?),
  );
  return val;
});

Map<String, dynamic> _$PageResponseMealPlanToJson(
  PageResponseMealPlan instance,
) => <String, dynamic>{
  'content': ?instance.content?.map((e) => e.toJson()).toList(),
  'page': ?instance.page,
  'size': ?instance.size,
  'totalElements': ?instance.totalElements,
  'totalPages': ?instance.totalPages,
  'hasNext': ?instance.hasNext,
};
