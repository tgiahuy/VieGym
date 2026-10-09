// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_response_workout_log_summary_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PageResponseWorkoutLogSummaryDtoCWProxy {
  PageResponseWorkoutLogSummaryDto content(List<WorkoutLogSummaryDto>? content);

  PageResponseWorkoutLogSummaryDto page(int? page);

  PageResponseWorkoutLogSummaryDto size(int? size);

  PageResponseWorkoutLogSummaryDto totalElements(int? totalElements);

  PageResponseWorkoutLogSummaryDto totalPages(int? totalPages);

  PageResponseWorkoutLogSummaryDto hasNext(bool? hasNext);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PageResponseWorkoutLogSummaryDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PageResponseWorkoutLogSummaryDto(...).copyWith(id: 12, name: "My name")
  /// ````
  PageResponseWorkoutLogSummaryDto call({
    List<WorkoutLogSummaryDto>? content,
    int? page,
    int? size,
    int? totalElements,
    int? totalPages,
    bool? hasNext,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPageResponseWorkoutLogSummaryDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPageResponseWorkoutLogSummaryDto.copyWith.fieldName(...)`
class _$PageResponseWorkoutLogSummaryDtoCWProxyImpl
    implements _$PageResponseWorkoutLogSummaryDtoCWProxy {
  const _$PageResponseWorkoutLogSummaryDtoCWProxyImpl(this._value);

  final PageResponseWorkoutLogSummaryDto _value;

  @override
  PageResponseWorkoutLogSummaryDto content(
    List<WorkoutLogSummaryDto>? content,
  ) => this(content: content);

  @override
  PageResponseWorkoutLogSummaryDto page(int? page) => this(page: page);

  @override
  PageResponseWorkoutLogSummaryDto size(int? size) => this(size: size);

  @override
  PageResponseWorkoutLogSummaryDto totalElements(int? totalElements) =>
      this(totalElements: totalElements);

  @override
  PageResponseWorkoutLogSummaryDto totalPages(int? totalPages) =>
      this(totalPages: totalPages);

  @override
  PageResponseWorkoutLogSummaryDto hasNext(bool? hasNext) =>
      this(hasNext: hasNext);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PageResponseWorkoutLogSummaryDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PageResponseWorkoutLogSummaryDto(...).copyWith(id: 12, name: "My name")
  /// ````
  PageResponseWorkoutLogSummaryDto call({
    Object? content = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? size = const $CopyWithPlaceholder(),
    Object? totalElements = const $CopyWithPlaceholder(),
    Object? totalPages = const $CopyWithPlaceholder(),
    Object? hasNext = const $CopyWithPlaceholder(),
  }) {
    return PageResponseWorkoutLogSummaryDto(
      content: content == const $CopyWithPlaceholder()
          ? _value.content
          // ignore: cast_nullable_to_non_nullable
          : content as List<WorkoutLogSummaryDto>?,
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

extension $PageResponseWorkoutLogSummaryDtoCopyWith
    on PageResponseWorkoutLogSummaryDto {
  /// Returns a callable class that can be used as follows: `instanceOfPageResponseWorkoutLogSummaryDto.copyWith(...)` or like so:`instanceOfPageResponseWorkoutLogSummaryDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PageResponseWorkoutLogSummaryDtoCWProxy get copyWith =>
      _$PageResponseWorkoutLogSummaryDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageResponseWorkoutLogSummaryDto _$PageResponseWorkoutLogSummaryDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PageResponseWorkoutLogSummaryDto', json, (
  $checkedConvert,
) {
  final val = PageResponseWorkoutLogSummaryDto(
    content: $checkedConvert(
      'content',
      (v) => (v as List<dynamic>?)
          ?.map((e) => WorkoutLogSummaryDto.fromJson(e as Map<String, dynamic>))
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

Map<String, dynamic> _$PageResponseWorkoutLogSummaryDtoToJson(
  PageResponseWorkoutLogSummaryDto instance,
) => <String, dynamic>{
  'content': ?instance.content?.map((e) => e.toJson()).toList(),
  'page': ?instance.page,
  'size': ?instance.size,
  'totalElements': ?instance.totalElements,
  'totalPages': ?instance.totalPages,
  'hasNext': ?instance.hasNext,
};
