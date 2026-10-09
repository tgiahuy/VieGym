//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'apply_meal_template_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ApplyMealTemplateRequest {
  /// Returns a new [ApplyMealTemplateRequest] instance.
  ApplyMealTemplateRequest({required this.targetDate, this.mode});

  @JsonKey(name: r'targetDate', required: true, includeIfNull: false)
  final DateTime targetDate;

  @JsonKey(name: r'mode', required: false, includeIfNull: false)
  final String? mode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApplyMealTemplateRequest &&
          other.targetDate == targetDate &&
          other.mode == mode;

  @override
  int get hashCode => targetDate.hashCode + mode.hashCode;

  factory ApplyMealTemplateRequest.fromJson(Map<String, dynamic> json) =>
      _$ApplyMealTemplateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ApplyMealTemplateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
