// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_day_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkoutDayRequestCWProxy {
  WorkoutDayRequest id(int? id);

  WorkoutDayRequest dayNumber(int? dayNumber);

  WorkoutDayRequest name(String? name);

  WorkoutDayRequest note(String? note);

  WorkoutDayRequest exercises(List<WorkoutExerciseRequest>? exercises);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutDayRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutDayRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutDayRequest call({
    int? id,
    int? dayNumber,
    String? name,
    String? note,
    List<WorkoutExerciseRequest>? exercises,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkoutDayRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkoutDayRequest.copyWith.fieldName(...)`
class _$WorkoutDayRequestCWProxyImpl implements _$WorkoutDayRequestCWProxy {
  const _$WorkoutDayRequestCWProxyImpl(this._value);

  final WorkoutDayRequest _value;

  @override
  WorkoutDayRequest id(int? id) => this(id: id);

  @override
  WorkoutDayRequest dayNumber(int? dayNumber) => this(dayNumber: dayNumber);

  @override
  WorkoutDayRequest name(String? name) => this(name: name);

  @override
  WorkoutDayRequest note(String? note) => this(note: note);

  @override
  WorkoutDayRequest exercises(List<WorkoutExerciseRequest>? exercises) =>
      this(exercises: exercises);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutDayRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutDayRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutDayRequest call({
    Object? id = const $CopyWithPlaceholder(),
    Object? dayNumber = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? exercises = const $CopyWithPlaceholder(),
  }) {
    return WorkoutDayRequest(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      dayNumber: dayNumber == const $CopyWithPlaceholder()
          ? _value.dayNumber
          // ignore: cast_nullable_to_non_nullable
          : dayNumber as int?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
      exercises: exercises == const $CopyWithPlaceholder()
          ? _value.exercises
          // ignore: cast_nullable_to_non_nullable
          : exercises as List<WorkoutExerciseRequest>?,
    );
  }
}

extension $WorkoutDayRequestCopyWith on WorkoutDayRequest {
  /// Returns a callable class that can be used as follows: `instanceOfWorkoutDayRequest.copyWith(...)` or like so:`instanceOfWorkoutDayRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkoutDayRequestCWProxy get copyWith =>
      _$WorkoutDayRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutDayRequest _$WorkoutDayRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WorkoutDayRequest', json, ($checkedConvert) {
      final val = WorkoutDayRequest(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        dayNumber: $checkedConvert('dayNumber', (v) => (v as num?)?.toInt()),
        name: $checkedConvert('name', (v) => v as String?),
        note: $checkedConvert('note', (v) => v as String?),
        exercises: $checkedConvert(
          'exercises',
          (v) => (v as List<dynamic>?)
              ?.map(
                (e) =>
                    WorkoutExerciseRequest.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$WorkoutDayRequestToJson(WorkoutDayRequest instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'dayNumber': ?instance.dayNumber,
      'name': ?instance.name,
      'note': ?instance.note,
      'exercises': ?instance.exercises?.map((e) => e.toJson()).toList(),
    };
