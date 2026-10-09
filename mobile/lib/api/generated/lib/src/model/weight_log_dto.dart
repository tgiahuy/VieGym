//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weight_log_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WeightLogDto {
  /// Returns a new [WeightLogDto] instance.
  WeightLogDto({
    this.id,

    this.loggedDate,

    this.weightKg,

    this.note,

    this.createdAt,

    this.updatedAt,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'loggedDate', required: false, includeIfNull: false)
  final DateTime? loggedDate;

  @JsonKey(name: r'weightKg', required: false, includeIfNull: false)
  final num? weightKg;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @JsonKey(name: r'createdAt', required: false, includeIfNull: false)
  final DateTime? createdAt;

  @JsonKey(name: r'updatedAt', required: false, includeIfNull: false)
  final DateTime? updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightLogDto &&
          other.id == id &&
          other.loggedDate == loggedDate &&
          other.weightKg == weightKg &&
          other.note == note &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      id.hashCode +
      loggedDate.hashCode +
      weightKg.hashCode +
      note.hashCode +
      createdAt.hashCode +
      updatedAt.hashCode;

  factory WeightLogDto.fromJson(Map<String, dynamic> json) =>
      _$WeightLogDtoFromJson(json);

  Map<String, dynamic> toJson() => _$WeightLogDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
