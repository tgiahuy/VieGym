//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/template_item.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meal_template.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MealTemplate {
  /// Returns a new [MealTemplate] instance.
  MealTemplate({
    this.id,

    this.name,

    this.description,

    this.sourceMealPlanId,

    this.items,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'description', required: false, includeIfNull: false)
  final String? description;

  @JsonKey(name: r'sourceMealPlanId', required: false, includeIfNull: false)
  final int? sourceMealPlanId;

  @JsonKey(name: r'items', required: false, includeIfNull: false)
  final List<TemplateItem>? items;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealTemplate &&
          other.id == id &&
          other.name == name &&
          other.description == description &&
          other.sourceMealPlanId == sourceMealPlanId &&
          other.items == items;

  @override
  int get hashCode =>
      id.hashCode +
      name.hashCode +
      description.hashCode +
      sourceMealPlanId.hashCode +
      items.hashCode;

  factory MealTemplate.fromJson(Map<String, dynamic> json) =>
      _$MealTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$MealTemplateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
