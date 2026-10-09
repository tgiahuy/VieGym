//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/workout_log_summary_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'page_response_workout_log_summary_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PageResponseWorkoutLogSummaryDto {
  /// Returns a new [PageResponseWorkoutLogSummaryDto] instance.
  PageResponseWorkoutLogSummaryDto({
    this.content,

    this.page,

    this.size,

    this.totalElements,

    this.totalPages,

    this.hasNext,
  });

  @JsonKey(name: r'content', required: false, includeIfNull: false)
  final List<WorkoutLogSummaryDto>? content;

  @JsonKey(name: r'page', required: false, includeIfNull: false)
  final int? page;

  @JsonKey(name: r'size', required: false, includeIfNull: false)
  final int? size;

  @JsonKey(name: r'totalElements', required: false, includeIfNull: false)
  final int? totalElements;

  @JsonKey(name: r'totalPages', required: false, includeIfNull: false)
  final int? totalPages;

  @JsonKey(name: r'hasNext', required: false, includeIfNull: false)
  final bool? hasNext;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageResponseWorkoutLogSummaryDto &&
          other.content == content &&
          other.page == page &&
          other.size == size &&
          other.totalElements == totalElements &&
          other.totalPages == totalPages &&
          other.hasNext == hasNext;

  @override
  int get hashCode =>
      content.hashCode +
      page.hashCode +
      size.hashCode +
      totalElements.hashCode +
      totalPages.hashCode +
      hasNext.hashCode;

  factory PageResponseWorkoutLogSummaryDto.fromJson(
    Map<String, dynamic> json,
  ) => _$PageResponseWorkoutLogSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PageResponseWorkoutLogSummaryDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
