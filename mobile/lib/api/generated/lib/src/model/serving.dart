//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'serving.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Serving {
  /// Returns a new [Serving] instance.
  Serving({this.amount, this.unit, this.gramsPerServing});

  @JsonKey(name: r'amount', required: false, includeIfNull: false)
  final num? amount;

  @JsonKey(name: r'unit', required: false, includeIfNull: false)
  final String? unit;

  @JsonKey(name: r'gramsPerServing', required: false, includeIfNull: false)
  final num? gramsPerServing;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Serving &&
          other.amount == amount &&
          other.unit == unit &&
          other.gramsPerServing == gramsPerServing;

  @override
  int get hashCode =>
      amount.hashCode + unit.hashCode + gramsPerServing.hashCode;

  factory Serving.fromJson(Map<String, dynamic> json) =>
      _$ServingFromJson(json);

  Map<String, dynamic> toJson() => _$ServingToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
