//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/template_item.dart';
import 'package:viegym_api/src/model/meal_plan.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'apply_template_result.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ApplyTemplateResult {
  /// Returns a new [ApplyTemplateResult] instance.
  ApplyTemplateResult({
    this.applied,

    this.targetDate,

    this.copiedItems,

    this.blockedItems,

    this.mealPlan,
  });

  @JsonKey(name: r'applied', required: false, includeIfNull: false)
  final bool? applied;

  @JsonKey(name: r'targetDate', required: false, includeIfNull: false)
  final DateTime? targetDate;

  @JsonKey(name: r'copiedItems', required: false, includeIfNull: false)
  final int? copiedItems;

  @JsonKey(name: r'blockedItems', required: false, includeIfNull: false)
  final List<TemplateItem>? blockedItems;

  @JsonKey(name: r'mealPlan', required: false, includeIfNull: false)
  final MealPlan? mealPlan;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApplyTemplateResult &&
          other.applied == applied &&
          other.targetDate == targetDate &&
          other.copiedItems == copiedItems &&
          other.blockedItems == blockedItems &&
          other.mealPlan == mealPlan;

  @override
  int get hashCode =>
      applied.hashCode +
      targetDate.hashCode +
      copiedItems.hashCode +
      blockedItems.hashCode +
      mealPlan.hashCode;

  factory ApplyTemplateResult.fromJson(Map<String, dynamic> json) =>
      _$ApplyTemplateResultFromJson(json);

  Map<String, dynamic> toJson() => _$ApplyTemplateResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
