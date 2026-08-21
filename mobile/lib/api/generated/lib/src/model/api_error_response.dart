//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:viegym_api/src/model/field_violation.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api_error_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ApiErrorResponse {
  /// Returns a new [ApiErrorResponse] instance.
  ApiErrorResponse({

    required  this.success,

    required  this.code,

    required  this.message,

     this.data,

    required  this.errors,

    required  this.correlationId,

    required  this.timestamp,
  });

  @JsonKey(
    
    name: r'success',
    required: true,
    includeIfNull: false,
  )


  final bool success;



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



  @JsonKey(
    
    name: r'data',
    required: false,
    includeIfNull: false,
  )


  final Object? data;



  @JsonKey(
    
    name: r'errors',
    required: true,
    includeIfNull: false,
  )


  final List<FieldViolation> errors;



  @JsonKey(
    
    name: r'correlationId',
    required: true,
    includeIfNull: false,
  )


  final String correlationId;



  @JsonKey(
    
    name: r'timestamp',
    required: true,
    includeIfNull: false,
  )


  final DateTime timestamp;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ApiErrorResponse &&
      other.success == success &&
      other.code == code &&
      other.message == message &&
      other.data == data &&
      other.errors == errors &&
      other.correlationId == correlationId &&
      other.timestamp == timestamp;

    @override
    int get hashCode =>
        success.hashCode +
        code.hashCode +
        message.hashCode +
        (data == null ? 0 : data.hashCode) +
        errors.hashCode +
        correlationId.hashCode +
        timestamp.hashCode;

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) => _$ApiErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

