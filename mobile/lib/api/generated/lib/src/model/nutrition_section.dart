//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/nutrition_macro_summary.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'nutrition_section.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NutritionSection {
  /// Returns a new [NutritionSection] instance.
  NutritionSection({
    this.target,

    this.consumed,

    this.remaining,

    this.hasMealPlan,
  });

  @JsonKey(name: r'target', required: false, includeIfNull: false)
  final NutritionMacroSummary? target;

  @JsonKey(name: r'consumed', required: false, includeIfNull: false)
  final NutritionMacroSummary? consumed;

  @JsonKey(name: r'remaining', required: false, includeIfNull: false)
  final NutritionMacroSummary? remaining;

  @JsonKey(name: r'hasMealPlan', required: false, includeIfNull: false)
  final bool? hasMealPlan;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionSection &&
          other.target == target &&
          other.consumed == consumed &&
          other.remaining == remaining &&
          other.hasMealPlan == hasMealPlan;

  @override
  int get hashCode =>
      target.hashCode +
      consumed.hashCode +
      remaining.hashCode +
      hasMealPlan.hashCode;

  factory NutritionSection.fromJson(Map<String, dynamic> json) =>
      _$NutritionSectionFromJson(json);

  Map<String, dynamic> toJson() => _$NutritionSectionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
