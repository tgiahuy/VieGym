// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_response_food.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PageResponseFoodCWProxy {
  PageResponseFood content(List<Food>? content);

  PageResponseFood page(int? page);

  PageResponseFood size(int? size);

  PageResponseFood totalElements(int? totalElements);

  PageResponseFood totalPages(int? totalPages);

  PageResponseFood hasNext(bool? hasNext);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PageResponseFood(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PageResponseFood(...).copyWith(id: 12, name: "My name")
  /// ````
  PageResponseFood call({
    List<Food>? content,
    int? page,
    int? size,
    int? totalElements,
    int? totalPages,
    bool? hasNext,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPageResponseFood.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPageResponseFood.copyWith.fieldName(...)`
class _$PageResponseFoodCWProxyImpl implements _$PageResponseFoodCWProxy {
  const _$PageResponseFoodCWProxyImpl(this._value);

  final PageResponseFood _value;

  @override
  PageResponseFood content(List<Food>? content) => this(content: content);

  @override
  PageResponseFood page(int? page) => this(page: page);

  @override
  PageResponseFood size(int? size) => this(size: size);

  @override
  PageResponseFood totalElements(int? totalElements) =>
      this(totalElements: totalElements);

  @override
  PageResponseFood totalPages(int? totalPages) => this(totalPages: totalPages);

  @override
  PageResponseFood hasNext(bool? hasNext) => this(hasNext: hasNext);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PageResponseFood(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PageResponseFood(...).copyWith(id: 12, name: "My name")
  /// ````
  PageResponseFood call({
    Object? content = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? size = const $CopyWithPlaceholder(),
    Object? totalElements = const $CopyWithPlaceholder(),
    Object? totalPages = const $CopyWithPlaceholder(),
    Object? hasNext = const $CopyWithPlaceholder(),
  }) {
    return PageResponseFood(
      content: content == const $CopyWithPlaceholder()
          ? _value.content
          // ignore: cast_nullable_to_non_nullable
          : content as List<Food>?,
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

extension $PageResponseFoodCopyWith on PageResponseFood {
  /// Returns a callable class that can be used as follows: `instanceOfPageResponseFood.copyWith(...)` or like so:`instanceOfPageResponseFood.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PageResponseFoodCWProxy get copyWith => _$PageResponseFoodCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageResponseFood _$PageResponseFoodFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PageResponseFood', json, ($checkedConvert) {
      final val = PageResponseFood(
        content: $checkedConvert(
          'content',
          (v) => (v as List<dynamic>?)
              ?.map((e) => Food.fromJson(e as Map<String, dynamic>))
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

Map<String, dynamic> _$PageResponseFoodToJson(PageResponseFood instance) =>
    <String, dynamic>{
      'content': ?instance.content?.map((e) => e.toJson()).toList(),
      'page': ?instance.page,
      'size': ?instance.size,
      'totalElements': ?instance.totalElements,
      'totalPages': ?instance.totalPages,
      'hasNext': ?instance.hasNext,
    };
