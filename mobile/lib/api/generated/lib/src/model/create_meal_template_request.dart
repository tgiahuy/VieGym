//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/item.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_meal_template_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateMealTemplateRequest {
  /// Returns a new [CreateMealTemplateRequest] instance.
  CreateMealTemplateRequest({
    required this.name,

    this.description,

    this.sourceMealPlanId,

    this.items,
  });

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'description', required: false, includeIfNull: false)
  final String? description;

  @JsonKey(name: r'sourceMealPlanId', required: false, includeIfNull: false)
  final int? sourceMealPlanId;

  @JsonKey(name: r'items', required: false, includeIfNull: false)
  final List<Item>? items;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateMealTemplateRequest &&
          other.name == name &&
          other.description == description &&
          other.sourceMealPlanId == sourceMealPlanId &&
          other.items == items;

  @override
  int get hashCode =>
      name.hashCode +
      description.hashCode +
      sourceMealPlanId.hashCode +
      items.hashCode;

  factory CreateMealTemplateRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateMealTemplateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateMealTemplateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
