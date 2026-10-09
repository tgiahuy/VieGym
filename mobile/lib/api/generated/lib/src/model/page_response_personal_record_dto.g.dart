// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_response_personal_record_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PageResponsePersonalRecordDtoCWProxy {
  PageResponsePersonalRecordDto content(List<PersonalRecordDto>? content);

  PageResponsePersonalRecordDto page(int? page);

  PageResponsePersonalRecordDto size(int? size);

  PageResponsePersonalRecordDto totalElements(int? totalElements);

  PageResponsePersonalRecordDto totalPages(int? totalPages);

  PageResponsePersonalRecordDto hasNext(bool? hasNext);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PageResponsePersonalRecordDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PageResponsePersonalRecordDto(...).copyWith(id: 12, name: "My name")
  /// ````
  PageResponsePersonalRecordDto call({
    List<PersonalRecordDto>? content,
    int? page,
    int? size,
    int? totalElements,
    int? totalPages,
    bool? hasNext,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPageResponsePersonalRecordDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPageResponsePersonalRecordDto.copyWith.fieldName(...)`
class _$PageResponsePersonalRecordDtoCWProxyImpl
    implements _$PageResponsePersonalRecordDtoCWProxy {
  const _$PageResponsePersonalRecordDtoCWProxyImpl(this._value);

  final PageResponsePersonalRecordDto _value;

  @override
  PageResponsePersonalRecordDto content(List<PersonalRecordDto>? content) =>
      this(content: content);

  @override
  PageResponsePersonalRecordDto page(int? page) => this(page: page);

  @override
  PageResponsePersonalRecordDto size(int? size) => this(size: size);

  @override
  PageResponsePersonalRecordDto totalElements(int? totalElements) =>
      this(totalElements: totalElements);

  @override
  PageResponsePersonalRecordDto totalPages(int? totalPages) =>
      this(totalPages: totalPages);

  @override
  PageResponsePersonalRecordDto hasNext(bool? hasNext) =>
      this(hasNext: hasNext);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PageResponsePersonalRecordDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PageResponsePersonalRecordDto(...).copyWith(id: 12, name: "My name")
  /// ````
  PageResponsePersonalRecordDto call({
    Object? content = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? size = const $CopyWithPlaceholder(),
    Object? totalElements = const $CopyWithPlaceholder(),
    Object? totalPages = const $CopyWithPlaceholder(),
    Object? hasNext = const $CopyWithPlaceholder(),
  }) {
    return PageResponsePersonalRecordDto(
      content: content == const $CopyWithPlaceholder()
          ? _value.content
          // ignore: cast_nullable_to_non_nullable
          : content as List<PersonalRecordDto>?,
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

extension $PageResponsePersonalRecordDtoCopyWith
    on PageResponsePersonalRecordDto {
  /// Returns a callable class that can be used as follows: `instanceOfPageResponsePersonalRecordDto.copyWith(...)` or like so:`instanceOfPageResponsePersonalRecordDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PageResponsePersonalRecordDtoCWProxy get copyWith =>
      _$PageResponsePersonalRecordDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageResponsePersonalRecordDto _$PageResponsePersonalRecordDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PageResponsePersonalRecordDto', json, ($checkedConvert) {
  final val = PageResponsePersonalRecordDto(
    content: $checkedConvert(
      'content',
      (v) => (v as List<dynamic>?)
          ?.map((e) => PersonalRecordDto.fromJson(e as Map<String, dynamic>))
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

Map<String, dynamic> _$PageResponsePersonalRecordDtoToJson(
  PageResponsePersonalRecordDto instance,
) => <String, dynamic>{
  'content': ?instance.content?.map((e) => e.toJson()).toList(),
  'page': ?instance.page,
  'size': ?instance.size,
  'totalElements': ?instance.totalElements,
  'totalPages': ?instance.totalPages,
  'hasNext': ?instance.hasNext,
};
