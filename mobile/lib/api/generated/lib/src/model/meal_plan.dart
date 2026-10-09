//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/meal.dart';
import 'package:viegym_api/src/model/nutrition.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meal_plan.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MealPlan {
  /// Returns a new [MealPlan] instance.
  MealPlan({
    this.id,

    this.planDate,

    this.targetSource,

    this.target,

    this.consumed,

    this.remaining,

    this.meals,

    this.warnings,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'planDate', required: false, includeIfNull: false)
  final DateTime? planDate;

  @JsonKey(name: r'targetSource', required: false, includeIfNull: false)
  final String? targetSource;

  @JsonKey(name: r'target', required: false, includeIfNull: false)
  final Nutrition? target;

  @JsonKey(name: r'consumed', required: false, includeIfNull: false)
  final Nutrition? consumed;

  @JsonKey(name: r'remaining', required: false, includeIfNull: false)
  final Nutrition? remaining;

  @JsonKey(name: r'meals', required: false, includeIfNull: false)
  final List<Meal>? meals;

  @JsonKey(name: r'warnings', required: false, includeIfNull: false)
  final List<String>? warnings;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealPlan &&
          other.id == id &&
          other.planDate == planDate &&
          other.targetSource == targetSource &&
          other.target == target &&
          other.consumed == consumed &&
          other.remaining == remaining &&
          other.meals == meals &&
          other.warnings == warnings;

  @override
  int get hashCode =>
      id.hashCode +
      planDate.hashCode +
      targetSource.hashCode +
      target.hashCode +
      consumed.hashCode +
      remaining.hashCode +
      meals.hashCode +
      warnings.hashCode;

  factory MealPlan.fromJson(Map<String, dynamic> json) =>
      _$MealPlanFromJson(json);

  Map<String, dynamic> toJson() => _$MealPlanToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
