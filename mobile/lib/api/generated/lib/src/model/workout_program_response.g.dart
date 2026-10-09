// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_program_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkoutProgramResponseCWProxy {
  WorkoutProgramResponse id(int? id);

  WorkoutProgramResponse name(String? name);

  WorkoutProgramResponse programType(String? programType);

  WorkoutProgramResponse description(String? description);

  WorkoutProgramResponse status(String? status);

  WorkoutProgramResponse days(List<WorkoutDayResponse>? days);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutProgramResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutProgramResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutProgramResponse call({
    int? id,
    String? name,
    String? programType,
    String? description,
    String? status,
    List<WorkoutDayResponse>? days,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkoutProgramResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkoutProgramResponse.copyWith.fieldName(...)`
class _$WorkoutProgramResponseCWProxyImpl
    implements _$WorkoutProgramResponseCWProxy {
  const _$WorkoutProgramResponseCWProxyImpl(this._value);

  final WorkoutProgramResponse _value;

  @override
  WorkoutProgramResponse id(int? id) => this(id: id);

  @override
  WorkoutProgramResponse name(String? name) => this(name: name);

  @override
  WorkoutProgramResponse programType(String? programType) =>
      this(programType: programType);

  @override
  WorkoutProgramResponse description(String? description) =>
      this(description: description);

  @override
  WorkoutProgramResponse status(String? status) => this(status: status);

  @override
  WorkoutProgramResponse days(List<WorkoutDayResponse>? days) =>
      this(days: days);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutProgramResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutProgramResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutProgramResponse call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? programType = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? days = const $CopyWithPlaceholder(),
  }) {
    return WorkoutProgramResponse(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
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
          : days as List<WorkoutDayResponse>?,
    );
  }
}

extension $WorkoutProgramResponseCopyWith on WorkoutProgramResponse {
  /// Returns a callable class that can be used as follows: `instanceOfWorkoutProgramResponse.copyWith(...)` or like so:`instanceOfWorkoutProgramResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkoutProgramResponseCWProxy get copyWith =>
      _$WorkoutProgramResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutProgramResponse _$WorkoutProgramResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('WorkoutProgramResponse', json, ($checkedConvert) {
  final val = WorkoutProgramResponse(
    id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
    name: $checkedConvert('name', (v) => v as String?),
    programType: $checkedConvert('programType', (v) => v as String?),
    description: $checkedConvert('description', (v) => v as String?),
    status: $checkedConvert('status', (v) => v as String?),
    days: $checkedConvert(
      'days',
      (v) => (v as List<dynamic>?)
          ?.map((e) => WorkoutDayResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$WorkoutProgramResponseToJson(
  WorkoutProgramResponse instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'name': ?instance.name,
  'programType': ?instance.programType,
  'description': ?instance.description,
  'status': ?instance.status,
  'days': ?instance.days?.map((e) => e.toJson()).toList(),
};
