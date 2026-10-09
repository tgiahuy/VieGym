// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_program_summary_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkoutProgramSummaryResponseCWProxy {
  WorkoutProgramSummaryResponse id(int? id);

  WorkoutProgramSummaryResponse name(String? name);

  WorkoutProgramSummaryResponse programType(String? programType);

  WorkoutProgramSummaryResponse description(String? description);

  WorkoutProgramSummaryResponse status(String? status);

  WorkoutProgramSummaryResponse totalDays(int? totalDays);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutProgramSummaryResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutProgramSummaryResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutProgramSummaryResponse call({
    int? id,
    String? name,
    String? programType,
    String? description,
    String? status,
    int? totalDays,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkoutProgramSummaryResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkoutProgramSummaryResponse.copyWith.fieldName(...)`
class _$WorkoutProgramSummaryResponseCWProxyImpl
    implements _$WorkoutProgramSummaryResponseCWProxy {
  const _$WorkoutProgramSummaryResponseCWProxyImpl(this._value);

  final WorkoutProgramSummaryResponse _value;

  @override
  WorkoutProgramSummaryResponse id(int? id) => this(id: id);

  @override
  WorkoutProgramSummaryResponse name(String? name) => this(name: name);

  @override
  WorkoutProgramSummaryResponse programType(String? programType) =>
      this(programType: programType);

  @override
  WorkoutProgramSummaryResponse description(String? description) =>
      this(description: description);

  @override
  WorkoutProgramSummaryResponse status(String? status) => this(status: status);

  @override
  WorkoutProgramSummaryResponse totalDays(int? totalDays) =>
      this(totalDays: totalDays);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutProgramSummaryResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutProgramSummaryResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutProgramSummaryResponse call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? programType = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? totalDays = const $CopyWithPlaceholder(),
  }) {
    return WorkoutProgramSummaryResponse(
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
      totalDays: totalDays == const $CopyWithPlaceholder()
          ? _value.totalDays
          // ignore: cast_nullable_to_non_nullable
          : totalDays as int?,
    );
  }
}

extension $WorkoutProgramSummaryResponseCopyWith
    on WorkoutProgramSummaryResponse {
  /// Returns a callable class that can be used as follows: `instanceOfWorkoutProgramSummaryResponse.copyWith(...)` or like so:`instanceOfWorkoutProgramSummaryResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkoutProgramSummaryResponseCWProxy get copyWith =>
      _$WorkoutProgramSummaryResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutProgramSummaryResponse _$WorkoutProgramSummaryResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('WorkoutProgramSummaryResponse', json, ($checkedConvert) {
  final val = WorkoutProgramSummaryResponse(
    id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
    name: $checkedConvert('name', (v) => v as String?),
    programType: $checkedConvert('programType', (v) => v as String?),
    description: $checkedConvert('description', (v) => v as String?),
    status: $checkedConvert('status', (v) => v as String?),
    totalDays: $checkedConvert('totalDays', (v) => (v as num?)?.toInt()),
  );
  return val;
});

Map<String, dynamic> _$WorkoutProgramSummaryResponseToJson(
  WorkoutProgramSummaryResponse instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'name': ?instance.name,
  'programType': ?instance.programType,
  'description': ?instance.description,
  'status': ?instance.status,
  'totalDays': ?instance.totalDays,
};
