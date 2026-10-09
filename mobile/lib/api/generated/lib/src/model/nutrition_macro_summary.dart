//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'nutrition_macro_summary.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NutritionMacroSummary {
  /// Returns a new [NutritionMacroSummary] instance.
  NutritionMacroSummary({
    this.caloriesKcal,

    this.proteinG,

    this.carbsG,

    this.fatG,
  });

  @JsonKey(name: r'caloriesKcal', required: false, includeIfNull: false)
  final num? caloriesKcal;

  @JsonKey(name: r'proteinG', required: false, includeIfNull: false)
  final num? proteinG;

  @JsonKey(name: r'carbsG', required: false, includeIfNull: false)
  final num? carbsG;

  @JsonKey(name: r'fatG', required: false, includeIfNull: false)
  final num? fatG;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionMacroSummary &&
          other.caloriesKcal == caloriesKcal &&
          other.proteinG == proteinG &&
          other.carbsG == carbsG &&
          other.fatG == fatG;

  @override
  int get hashCode =>
      caloriesKcal.hashCode +
      proteinG.hashCode +
      carbsG.hashCode +
      fatG.hashCode;

  factory NutritionMacroSummary.fromJson(Map<String, dynamic> json) =>
      _$NutritionMacroSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$NutritionMacroSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
