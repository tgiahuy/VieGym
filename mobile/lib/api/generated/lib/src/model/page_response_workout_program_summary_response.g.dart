// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_response_workout_program_summary_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PageResponseWorkoutProgramSummaryResponseCWProxy {
  PageResponseWorkoutProgramSummaryResponse content(
    List<WorkoutProgramSummaryResponse>? content,
  );

  PageResponseWorkoutProgramSummaryResponse page(int? page);

  PageResponseWorkoutProgramSummaryResponse size(int? size);

  PageResponseWorkoutProgramSummaryResponse totalElements(int? totalElements);

  PageResponseWorkoutProgramSummaryResponse totalPages(int? totalPages);

  PageResponseWorkoutProgramSummaryResponse hasNext(bool? hasNext);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PageResponseWorkoutProgramSummaryResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PageResponseWorkoutProgramSummaryResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PageResponseWorkoutProgramSummaryResponse call({
    List<WorkoutProgramSummaryResponse>? content,
    int? page,
    int? size,
    int? totalElements,
    int? totalPages,
    bool? hasNext,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPageResponseWorkoutProgramSummaryResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPageResponseWorkoutProgramSummaryResponse.copyWith.fieldName(...)`
class _$PageResponseWorkoutProgramSummaryResponseCWProxyImpl
    implements _$PageResponseWorkoutProgramSummaryResponseCWProxy {
  const _$PageResponseWorkoutProgramSummaryResponseCWProxyImpl(this._value);

  final PageResponseWorkoutProgramSummaryResponse _value;

  @override
  PageResponseWorkoutProgramSummaryResponse content(
    List<WorkoutProgramSummaryResponse>? content,
  ) => this(content: content);

  @override
  PageResponseWorkoutProgramSummaryResponse page(int? page) => this(page: page);

  @override
  PageResponseWorkoutProgramSummaryResponse size(int? size) => this(size: size);

  @override
  PageResponseWorkoutProgramSummaryResponse totalElements(int? totalElements) =>
      this(totalElements: totalElements);

  @override
  PageResponseWorkoutProgramSummaryResponse totalPages(int? totalPages) =>
      this(totalPages: totalPages);

  @override
  PageResponseWorkoutProgramSummaryResponse hasNext(bool? hasNext) =>
      this(hasNext: hasNext);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PageResponseWorkoutProgramSummaryResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PageResponseWorkoutProgramSummaryResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PageResponseWorkoutProgramSummaryResponse call({
    Object? content = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? size = const $CopyWithPlaceholder(),
    Object? totalElements = const $CopyWithPlaceholder(),
    Object? totalPages = const $CopyWithPlaceholder(),
    Object? hasNext = const $CopyWithPlaceholder(),
  }) {
    return PageResponseWorkoutProgramSummaryResponse(
      content: content == const $CopyWithPlaceholder()
          ? _value.content
          // ignore: cast_nullable_to_non_nullable
          : content as List<WorkoutProgramSummaryResponse>?,
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

extension $PageResponseWorkoutProgramSummaryResponseCopyWith
    on PageResponseWorkoutProgramSummaryResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPageResponseWorkoutProgramSummaryResponse.copyWith(...)` or like so:`instanceOfPageResponseWorkoutProgramSummaryResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PageResponseWorkoutProgramSummaryResponseCWProxy get copyWith =>
      _$PageResponseWorkoutProgramSummaryResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageResponseWorkoutProgramSummaryResponse
_$PageResponseWorkoutProgramSummaryResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PageResponseWorkoutProgramSummaryResponse', json, (
  $checkedConvert,
) {
  final val = PageResponseWorkoutProgramSummaryResponse(
    content: $checkedConvert(
      'content',
      (v) => (v as List<dynamic>?)
          ?.map(
            (e) => WorkoutProgramSummaryResponse.fromJson(
              e as Map<String, dynamic>,
            ),
          )
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

Map<String, dynamic> _$PageResponseWorkoutProgramSummaryResponseToJson(
  PageResponseWorkoutProgramSummaryResponse instance,
) => <String, dynamic>{
  'content': ?instance.content?.map((e) => e.toJson()).toList(),
  'page': ?instance.page,
  'size': ?instance.size,
  'totalElements': ?instance.totalElements,
  'totalPages': ?instance.totalPages,
  'hasNext': ?instance.hasNext,
};
