import 'package:viegym_api/src/model/api_error_response.dart';
import 'package:viegym_api/src/model/field_violation.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

  ReturnType deserialize<ReturnType, BaseType>(dynamic value, String targetType, {bool growable= true}) {
      switch (targetType) {
        case 'String':
          return '$value' as ReturnType;
        case 'int':
          return (value is int ? value : int.parse('$value')) as ReturnType;
        case 'bool':
          if (value is bool) {
            return value as ReturnType;
          }
          final valueString = '$value'.toLowerCase();
          return (valueString == 'true' || valueString == '1') as ReturnType;
        case 'double':
          return (value is double ? value : double.parse('$value')) as ReturnType;
        case 'ApiErrorResponse':
          return ApiErrorResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'FieldViolation':
          return FieldViolation.fromJson(value as Map<String, dynamic>) as ReturnType;
        default:
          RegExpMatch? match;

          if (value is List && (match = _regList.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toList(growable: growable) as ReturnType;
          }
          if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toSet() as ReturnType;
          }
          if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
            targetType = match![1]!.trim(); // ignore: parameter_assignments
            return Map<String, BaseType>.fromIterables(
              value.keys as Iterable<String>,
              value.values.map((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable)),
            ) as ReturnType;
          }
          break;
    }
    throw Exception('Cannot deserialize');
  }*** Add File: /Users/xbaek/VieGym/mobile/lib/api/generated/lib/src/model/api_error_response.dart
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

