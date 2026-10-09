// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_program_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkoutProgramRequestCWProxy {
  WorkoutProgramRequest name(String? name);

  WorkoutProgramRequest programType(String? programType);

  WorkoutProgramRequest description(String? description);

  WorkoutProgramRequest status(String? status);

  WorkoutProgramRequest days(List<WorkoutDayRequest>? days);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutProgramRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutProgramRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutProgramRequest call({
    String? name,
    String? programType,
    String? description,
    String? status,
    List<WorkoutDayRequest>? days,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkoutProgramRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkoutProgramRequest.copyWith.fieldName(...)`
class _$WorkoutProgramRequestCWProxyImpl
    implements _$WorkoutProgramRequestCWProxy {
  const _$WorkoutProgramRequestCWProxyImpl(this._value);

  final WorkoutProgramRequest _value;

  @override
  WorkoutProgramRequest name(String? name) => this(name: name);

  @override
  WorkoutProgramRequest programType(String? programType) =>
      this(programType: programType);

  @override
  WorkoutProgramRequest description(String? description) =>
      this(description: description);

  @override
  WorkoutProgramRequest status(String? status) => this(status: status);

  @override
  WorkoutProgramRequest days(List<WorkoutDayRequest>? days) => this(days: days);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutProgramRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutProgramRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutProgramRequest call({
    Object? name = const $CopyWithPlaceholder(),
    Object? programType = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? days = const $CopyWithPlaceholder(),
  }) {
    return WorkoutProgramRequest(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      programType: programType == const $CopyWithPlaceholder()
          ? _value.programType
          // ignore: cast_nullable_to_non_nullable
          : programType as String?,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String?,
      days: days == const $CopyWithPlaceholder()
          ? _value.days
          // ignore: cast_nullable_to_non_nullable
          : days as List<WorkoutDayRequest>?,
    );
  }
}

extension $WorkoutProgramRequestCopyWith on WorkoutProgramRequest {
  /// Returns a callable class that can be used as follows: `instanceOfWorkoutProgramRequest.copyWith(...)` or like so:`instanceOfWorkoutProgramRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkoutProgramRequestCWProxy get copyWith =>
      _$WorkoutProgramRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutProgramRequest _$WorkoutProgramRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('WorkoutProgramRequest', json, ($checkedConvert) {
  final val = WorkoutProgramRequest(
    name: $checkedConvert('name', (v) => v as String?),
    programType: $checkedConvert('programType', (v) => v as String?),
    description: $checkedConvert('description', (v) => v as String?),
    status: $checkedConvert('status', (v) => v as String?),
    days: $checkedConvert(
      'days',
      (v) => (v as List<dynamic>?)
          ?.map((e) => WorkoutDayRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$WorkoutProgramRequestToJson(
  WorkoutProgramRequest instance,
) => <String, dynamic>{
  'name': ?instance.name,
  'programType': ?instance.programType,
  'description': ?instance.description,
  'status': ?instance.status,
  'days': ?instance.days?.map((e) => e.toJson()).toList(),
};
