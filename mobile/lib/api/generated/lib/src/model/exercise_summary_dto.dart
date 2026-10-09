//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/exercise_muscle_group_dto.dart';
import 'package:viegym_api/src/model/exercise_equipment_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exercise_summary_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ExerciseSummaryDto {
  /// Returns a new [ExerciseSummaryDto] instance.
  ExerciseSummaryDto({
    this.id,

    this.name,

    this.slug,

    this.difficulty,

    this.description,

    this.muscleGroups,

    this.equipment,

    this.media,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'slug', required: false, includeIfNull: false)
  final String? slug;

  @JsonKey(name: r'difficulty', required: false, includeIfNull: false)
  final String? difficulty;

  @JsonKey(name: r'description', required: false, includeIfNull: false)
  final String? description;

  @JsonKey(name: r'muscleGroups', required: false, includeIfNull: false)
  final List<ExerciseMuscleGroupDto>? muscleGroups;

  @JsonKey(name: r'equipment', required: false, includeIfNull: false)
  final List<ExerciseEquipmentDto>? equipment;

  @JsonKey(name: r'media', required: false, includeIfNull: false)
  final List<Object>? media;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseSummaryDto &&
          other.id == id &&
          other.name == name &&
          other.slug == slug &&
          other.difficulty == difficulty &&
          other.description == description &&
          other.muscleGroups == muscleGroups &&
          other.equipment == equipment &&
          other.media == media;

  @override
  int get hashCode =>
      id.hashCode +
      name.hashCode +
      slug.hashCode +
      difficulty.hashCode +
      description.hashCode +
      muscleGroups.hashCode +
      equipment.hashCode +
      media.hashCode;

  factory ExerciseSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseSummaryDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
