//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/body_section.dart';
import 'package:viegym_api/src/model/workout_section.dart';
import 'package:viegym_api/src/model/nutrition_section.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dashboard_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DashboardResponse {
  /// Returns a new [DashboardResponse] instance.
  DashboardResponse({
    this.date,

    this.nutrition,

    this.workout,

    this.body,

    this.recommendations,

    this.missingData,

    this.generatedAt,
  });

  @JsonKey(name: r'date', required: false, includeIfNull: false)
  final DateTime? date;

  @JsonKey(name: r'nutrition', required: false, includeIfNull: false)
  final NutritionSection? nutrition;

  @JsonKey(name: r'workout', required: false, includeIfNull: false)
  final WorkoutSection? workout;

  @JsonKey(name: r'body', required: false, includeIfNull: false)
  final BodySection? body;

  @JsonKey(name: r'recommendations', required: false, includeIfNull: false)
  final List<Object>? recommendations;

  @JsonKey(name: r'missingData', required: false, includeIfNull: false)
  final List<String>? missingData;

  @JsonKey(name: r'generatedAt', required: false, includeIfNull: false)
  final DateTime? generatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardResponse &&
          other.date == date &&
          other.nutrition == nutrition &&
          other.workout == workout &&
          other.body == body &&
          other.recommendations == recommendations &&
          other.missingData == missingData &&
          other.generatedAt == generatedAt;

  @override
  int get hashCode =>
      date.hashCode +
      nutrition.hashCode +
      workout.hashCode +
      body.hashCode +
      recommendations.hashCode +
      missingData.hashCode +
      generatedAt.hashCode;

  factory DashboardResponse.fromJson(Map<String, dynamic> json) =>
      _$DashboardResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
