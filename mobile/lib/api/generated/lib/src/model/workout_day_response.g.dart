// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_day_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkoutDayResponseCWProxy {
  WorkoutDayResponse id(int? id);

  WorkoutDayResponse dayNumber(int? dayNumber);

  WorkoutDayResponse name(String? name);

  WorkoutDayResponse note(String? note);

  WorkoutDayResponse exercises(List<WorkoutExerciseResponse>? exercises);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutDayResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutDayResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutDayResponse call({
    int? id,
    int? dayNumber,
    String? name,
    String? note,
    List<WorkoutExerciseResponse>? exercises,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkoutDayResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkoutDayResponse.copyWith.fieldName(...)`
class _$WorkoutDayResponseCWProxyImpl implements _$WorkoutDayResponseCWProxy {
  const _$WorkoutDayResponseCWProxyImpl(this._value);

  final WorkoutDayResponse _value;

  @override
  WorkoutDayResponse id(int? id) => this(id: id);

  @override
  WorkoutDayResponse dayNumber(int? dayNumber) => this(dayNumber: dayNumber);

  @override
  WorkoutDayResponse name(String? name) => this(name: name);

  @override
  WorkoutDayResponse note(String? note) => this(note: note);

  @override
  WorkoutDayResponse exercises(List<WorkoutExerciseResponse>? exercises) =>
      this(exercises: exercises);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutDayResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutDayResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutDayResponse call({
    Object? id = const $CopyWithPlaceholder(),
    Object? dayNumber = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? exercises = const $CopyWithPlaceholder(),
  }) {
    return WorkoutDayResponse(
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
          : exercises as List<WorkoutExerciseResponse>?,
    );
  }
}

extension $WorkoutDayResponseCopyWith on WorkoutDayResponse {
  /// Returns a callable class that can be used as follows: `instanceOfWorkoutDayResponse.copyWith(...)` or like so:`instanceOfWorkoutDayResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkoutDayResponseCWProxy get copyWith =>
      _$WorkoutDayResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutDayResponse _$WorkoutDayResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WorkoutDayResponse', json, ($checkedConvert) {
      final val = WorkoutDayResponse(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        dayNumber: $checkedConvert('dayNumber', (v) => (v as num?)?.toInt()),
        name: $checkedConvert('name', (v) => v as String?),
        note: $checkedConvert('note', (v) => v as String?),
        exercises: $checkedConvert(
          'exercises',
          (v) => (v as List<dynamic>?)
              ?.map(
                (e) =>
                    WorkoutExerciseResponse.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$WorkoutDayResponseToJson(WorkoutDayResponse instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'dayNumber': ?instance.dayNumber,
      'name': ?instance.name,
      'note': ?instance.note,
      'exercises': ?instance.exercises?.map((e) => e.toJson()).toList(),
    };
