// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_response_weight_log_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PageResponseWeightLogDtoCWProxy {
  PageResponseWeightLogDto content(List<WeightLogDto>? content);

  PageResponseWeightLogDto page(int? page);

  PageResponseWeightLogDto size(int? size);

  PageResponseWeightLogDto totalElements(int? totalElements);

  PageResponseWeightLogDto totalPages(int? totalPages);

  PageResponseWeightLogDto hasNext(bool? hasNext);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PageResponseWeightLogDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PageResponseWeightLogDto(...).copyWith(id: 12, name: "My name")
  /// ````
  PageResponseWeightLogDto call({
    List<WeightLogDto>? content,
    int? page,
    int? size,
    int? totalElements,
    int? totalPages,
    bool? hasNext,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPageResponseWeightLogDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPageResponseWeightLogDto.copyWith.fieldName(...)`
class _$PageResponseWeightLogDtoCWProxyImpl
    implements _$PageResponseWeightLogDtoCWProxy {
  const _$PageResponseWeightLogDtoCWProxyImpl(this._value);

  final PageResponseWeightLogDto _value;

  @override
  PageResponseWeightLogDto content(List<WeightLogDto>? content) =>
      this(content: content);

  @override
  PageResponseWeightLogDto page(int? page) => this(page: page);

  @override
  PageResponseWeightLogDto size(int? size) => this(size: size);

  @override
  PageResponseWeightLogDto totalElements(int? totalElements) =>
      this(totalElements: totalElements);

  @override
  PageResponseWeightLogDto totalPages(int? totalPages) =>
      this(totalPages: totalPages);

  @override
  PageResponseWeightLogDto hasNext(bool? hasNext) => this(hasNext: hasNext);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PageResponseWeightLogDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PageResponseWeightLogDto(...).copyWith(id: 12, name: "My name")
  /// ````
  PageResponseWeightLogDto call({
    Object? content = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? size = const $CopyWithPlaceholder(),
    Object? totalElements = const $CopyWithPlaceholder(),
    Object? totalPages = const $CopyWithPlaceholder(),
    Object? hasNext = const $CopyWithPlaceholder(),
  }) {
    return PageResponseWeightLogDto(
      content: content == const $CopyWithPlaceholder()
          ? _value.content
          // ignore: cast_nullable_to_non_nullable
          : content as List<WeightLogDto>?,
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

extension $PageResponseWeightLogDtoCopyWith on PageResponseWeightLogDto {
  /// Returns a callable class that can be used as follows: `instanceOfPageResponseWeightLogDto.copyWith(...)` or like so:`instanceOfPageResponseWeightLogDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PageResponseWeightLogDtoCWProxy get copyWith =>
      _$PageResponseWeightLogDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageResponseWeightLogDto _$PageResponseWeightLogDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PageResponseWeightLogDto', json, ($checkedConvert) {
  final val = PageResponseWeightLogDto(
    content: $checkedConvert(
      'content',
      (v) => (v as List<dynamic>?)
          ?.map((e) => WeightLogDto.fromJson(e as Map<String, dynamic>))
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

Map<String, dynamic> _$PageResponseWeightLogDtoToJson(
  PageResponseWeightLogDto instance,
) => <String, dynamic>{
  'content': ?instance.content?.map((e) => e.toJson()).toList(),
  'page': ?instance.page,
  'size': ?instance.size,
  'totalElements': ?instance.totalElements,
  'totalPages': ?instance.totalPages,
  'hasNext': ?instance.hasNext,
};
