//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/exercise_muscle_group_dto.dart';
import 'package:viegym_api/src/model/exercise_equipment_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exercise_detail_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ExerciseDetailDto {
  /// Returns a new [ExerciseDetailDto] instance.
  ExerciseDetailDto({
    this.id,

    this.name,

    this.slug,

    this.difficulty,

    this.description,

    this.instructionSteps,

    this.commonMistakes,

    this.safetyNotes,

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

  @JsonKey(name: r'instructionSteps', required: false, includeIfNull: false)
  final List<String>? instructionSteps;

  @JsonKey(name: r'commonMistakes', required: false, includeIfNull: false)
  final List<String>? commonMistakes;

  @JsonKey(name: r'safetyNotes', required: false, includeIfNull: false)
  final List<String>? safetyNotes;

  @JsonKey(name: r'muscleGroups', required: false, includeIfNull: false)
  final List<ExerciseMuscleGroupDto>? muscleGroups;

  @JsonKey(name: r'equipment', required: false, includeIfNull: false)
  final List<ExerciseEquipmentDto>? equipment;

  @JsonKey(name: r'media', required: false, includeIfNull: false)
  final List<Object>? media;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseDetailDto &&
          other.id == id &&
          other.name == name &&
          other.slug == slug &&
          other.difficulty == difficulty &&
          other.description == description &&
          other.instructionSteps == instructionSteps &&
          other.commonMistakes == commonMistakes &&
          other.safetyNotes == safetyNotes &&
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
      instructionSteps.hashCode +
      commonMistakes.hashCode +
      safetyNotes.hashCode +
      muscleGroups.hashCode +
      equipment.hashCode +
      media.hashCode;

  factory ExerciseDetailDto.fromJson(Map<String, dynamic> json) =>
      _$ExerciseDetailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseDetailDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
