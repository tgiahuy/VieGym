// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_response_exercise_summary_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PageResponseExerciseSummaryDtoCWProxy {
  PageResponseExerciseSummaryDto content(List<ExerciseSummaryDto>? content);

  PageResponseExerciseSummaryDto page(int? page);

  PageResponseExerciseSummaryDto size(int? size);

  PageResponseExerciseSummaryDto totalElements(int? totalElements);

  PageResponseExerciseSummaryDto totalPages(int? totalPages);

  PageResponseExerciseSummaryDto hasNext(bool? hasNext);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PageResponseExerciseSummaryDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PageResponseExerciseSummaryDto(...).copyWith(id: 12, name: "My name")
  /// ````
  PageResponseExerciseSummaryDto call({
    List<ExerciseSummaryDto>? content,
    int? page,
    int? size,
    int? totalElements,
    int? totalPages,
    bool? hasNext,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPageResponseExerciseSummaryDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPageResponseExerciseSummaryDto.copyWith.fieldName(...)`
class _$PageResponseExerciseSummaryDtoCWProxyImpl
    implements _$PageResponseExerciseSummaryDtoCWProxy {
  const _$PageResponseExerciseSummaryDtoCWProxyImpl(this._value);

  final PageResponseExerciseSummaryDto _value;

  @override
  PageResponseExerciseSummaryDto content(List<ExerciseSummaryDto>? content) =>
      this(content: content);

  @override
  PageResponseExerciseSummaryDto page(int? page) => this(page: page);

  @override
  PageResponseExerciseSummaryDto size(int? size) => this(size: size);

  @override
  PageResponseExerciseSummaryDto totalElements(int? totalElements) =>
      this(totalElements: totalElements);

  @override
  PageResponseExerciseSummaryDto totalPages(int? totalPages) =>
      this(totalPages: totalPages);

  @override
  PageResponseExerciseSummaryDto hasNext(bool? hasNext) =>
      this(hasNext: hasNext);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PageResponseExerciseSummaryDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PageResponseExerciseSummaryDto(...).copyWith(id: 12, name: "My name")
  /// ````
  PageResponseExerciseSummaryDto call({
    Object? content = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? size = const $CopyWithPlaceholder(),
    Object? totalElements = const $CopyWithPlaceholder(),
    Object? totalPages = const $CopyWithPlaceholder(),
    Object? hasNext = const $CopyWithPlaceholder(),
  }) {
    return PageResponseExerciseSummaryDto(
      content: content == const $CopyWithPlaceholder()
          ? _value.content
          // ignore: cast_nullable_to_non_nullable
          : content as List<ExerciseSummaryDto>?,
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

extension $PageResponseExerciseSummaryDtoCopyWith
    on PageResponseExerciseSummaryDto {
  /// Returns a callable class that can be used as follows: `instanceOfPageResponseExerciseSummaryDto.copyWith(...)` or like so:`instanceOfPageResponseExerciseSummaryDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PageResponseExerciseSummaryDtoCWProxy get copyWith =>
      _$PageResponseExerciseSummaryDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageResponseExerciseSummaryDto _$PageResponseExerciseSummaryDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PageResponseExerciseSummaryDto', json, ($checkedConvert) {
  final val = PageResponseExerciseSummaryDto(
    content: $checkedConvert(
      'content',
      (v) => (v as List<dynamic>?)
          ?.map((e) => ExerciseSummaryDto.fromJson(e as Map<String, dynamic>))
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

Map<String, dynamic> _$PageResponseExerciseSummaryDtoToJson(
  PageResponseExerciseSummaryDto instance,
) => <String, dynamic>{
  'content': ?instance.content?.map((e) => e.toJson()).toList(),
  'page': ?instance.page,
  'size': ?instance.size,
  'totalElements': ?instance.totalElements,
  'totalPages': ?instance.totalPages,
  'hasNext': ?instance.hasNext,
};
