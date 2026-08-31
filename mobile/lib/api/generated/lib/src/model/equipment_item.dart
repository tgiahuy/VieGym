//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'equipment_item.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EquipmentItem {
  /// Returns a new [EquipmentItem] instance.
  EquipmentItem({this.id, this.code, this.name, this.selected});

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'code', required: false, includeIfNull: false)
  final String? code;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'selected', required: false, includeIfNull: false)
  final bool? selected;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentItem &&
          other.id == id &&
          other.code == code &&
          other.name == name &&
          other.selected == selected;

  @override
  int get hashCode =>
      id.hashCode + code.hashCode + name.hashCode + selected.hashCode;

  factory EquipmentItem.fromJson(Map<String, dynamic> json) =>
      _$EquipmentItemFromJson(json);

  Map<String, dynamic> toJson() => _$EquipmentItemToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
