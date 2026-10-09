//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/exercise_summary_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'page_response_exercise_summary_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PageResponseExerciseSummaryDto {
  /// Returns a new [PageResponseExerciseSummaryDto] instance.
  PageResponseExerciseSummaryDto({
    this.content,

    this.page,

    this.size,

    this.totalElements,

    this.totalPages,

    this.hasNext,
  });

  @JsonKey(name: r'content', required: false, includeIfNull: false)
  final List<ExerciseSummaryDto>? content;

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
      other is PageResponseExerciseSummaryDto &&
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

  factory PageResponseExerciseSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$PageResponseExerciseSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PageResponseExerciseSummaryDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
