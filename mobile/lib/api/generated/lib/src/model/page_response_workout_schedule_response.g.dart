// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_response_workout_schedule_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PageResponseWorkoutScheduleResponseCWProxy {
  PageResponseWorkoutScheduleResponse content(
    List<WorkoutScheduleResponse>? content,
  );

  PageResponseWorkoutScheduleResponse page(int? page);

  PageResponseWorkoutScheduleResponse size(int? size);

  PageResponseWorkoutScheduleResponse totalElements(int? totalElements);

  PageResponseWorkoutScheduleResponse totalPages(int? totalPages);

  PageResponseWorkoutScheduleResponse hasNext(bool? hasNext);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PageResponseWorkoutScheduleResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PageResponseWorkoutScheduleResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PageResponseWorkoutScheduleResponse call({
    List<WorkoutScheduleResponse>? content,
    int? page,
    int? size,
    int? totalElements,
    int? totalPages,
    bool? hasNext,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPageResponseWorkoutScheduleResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPageResponseWorkoutScheduleResponse.copyWith.fieldName(...)`
class _$PageResponseWorkoutScheduleResponseCWProxyImpl
    implements _$PageResponseWorkoutScheduleResponseCWProxy {
  const _$PageResponseWorkoutScheduleResponseCWProxyImpl(this._value);

  final PageResponseWorkoutScheduleResponse _value;

  @override
  PageResponseWorkoutScheduleResponse content(
    List<WorkoutScheduleResponse>? content,
  ) => this(content: content);

  @override
  PageResponseWorkoutScheduleResponse page(int? page) => this(page: page);

  @override
  PageResponseWorkoutScheduleResponse size(int? size) => this(size: size);

  @override
  PageResponseWorkoutScheduleResponse totalElements(int? totalElements) =>
      this(totalElements: totalElements);

  @override
  PageResponseWorkoutScheduleResponse totalPages(int? totalPages) =>
      this(totalPages: totalPages);

  @override
  PageResponseWorkoutScheduleResponse hasNext(bool? hasNext) =>
      this(hasNext: hasNext);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PageResponseWorkoutScheduleResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PageResponseWorkoutScheduleResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PageResponseWorkoutScheduleResponse call({
    Object? content = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? size = const $CopyWithPlaceholder(),
    Object? totalElements = const $CopyWithPlaceholder(),
    Object? totalPages = const $CopyWithPlaceholder(),
    Object? hasNext = const $CopyWithPlaceholder(),
  }) {
    return PageResponseWorkoutScheduleResponse(
      content: content == const $CopyWithPlaceholder()
          ? _value.content
          // ignore: cast_nullable_to_non_nullable
          : content as List<WorkoutScheduleResponse>?,
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

extension $PageResponseWorkoutScheduleResponseCopyWith
    on PageResponseWorkoutScheduleResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPageResponseWorkoutScheduleResponse.copyWith(...)` or like so:`instanceOfPageResponseWorkoutScheduleResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PageResponseWorkoutScheduleResponseCWProxy get copyWith =>
      _$PageResponseWorkoutScheduleResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageResponseWorkoutScheduleResponse
_$PageResponseWorkoutScheduleResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PageResponseWorkoutScheduleResponse', json, (
      $checkedConvert,
    ) {
      final val = PageResponseWorkoutScheduleResponse(
        content: $checkedConvert(
          'content',
          (v) => (v as List<dynamic>?)
              ?.map(
                (e) =>
                    WorkoutScheduleResponse.fromJson(e as Map<String, dynamic>),
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

Map<String, dynamic> _$PageResponseWorkoutScheduleResponseToJson(
  PageResponseWorkoutScheduleResponse instance,
) => <String, dynamic>{
  'content': ?instance.content?.map((e) => e.toJson()).toList(),
  'page': ?instance.page,
  'size': ?instance.size,
  'totalElements': ?instance.totalElements,
  'totalPages': ?instance.totalPages,
  'hasNext': ?instance.hasNext,
};
