//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'field_violation.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FieldViolation {
  /// Returns a new [FieldViolation] instance.
  FieldViolation({

    required  this.field,

    required  this.code,

    required  this.message,
  });

  @JsonKey(
    
    name: r'field',
    required: true,
    includeIfNull: false,
  )


  final String field;



  @JsonKey(
    
    name: r'code',
    required: true,
    includeIfNull: false,
  )


  final String code;



  @JsonKey(
    
    name: r'message',
    required: true,
    includeIfNull: false,
  )


  final String message;





    @override
    bool operator ==(Object other) => identical(this, other) || other is FieldViolation &&
      other.field == field &&
      other.code == code &&
      other.message == message;

    @override
    int get hashCode =>
        field.hashCode +
        code.hashCode +
        message.hashCode;

  factory FieldViolation.fromJson(Map<String, dynamic> json) => _$FieldViolationFromJson(json);

  Map<String, dynamic> toJson() => _$FieldViolationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

