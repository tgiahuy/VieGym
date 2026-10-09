// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_template_day_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkoutTemplateDayResponseCWProxy {
  WorkoutTemplateDayResponse id(int? id);

  WorkoutTemplateDayResponse dayNumber(int? dayNumber);

  WorkoutTemplateDayResponse name(String? name);

  WorkoutTemplateDayResponse note(String? note);

  WorkoutTemplateDayResponse exercises(List<ScheduleExercisePlan>? exercises);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutTemplateDayResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutTemplateDayResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutTemplateDayResponse call({
    int? id,
    int? dayNumber,
    String? name,
    String? note,
    List<ScheduleExercisePlan>? exercises,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkoutTemplateDayResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkoutTemplateDayResponse.copyWith.fieldName(...)`
class _$WorkoutTemplateDayResponseCWProxyImpl
    implements _$WorkoutTemplateDayResponseCWProxy {
  const _$WorkoutTemplateDayResponseCWProxyImpl(this._value);

  final WorkoutTemplateDayResponse _value;

  @override
  WorkoutTemplateDayResponse id(int? id) => this(id: id);

  @override
  WorkoutTemplateDayResponse dayNumber(int? dayNumber) =>
      this(dayNumber: dayNumber);

  @override
  WorkoutTemplateDayResponse name(String? name) => this(name: name);

  @override
  WorkoutTemplateDayResponse note(String? note) => this(note: note);

  @override
  WorkoutTemplateDayResponse exercises(List<ScheduleExercisePlan>? exercises) =>
      this(exercises: exercises);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutTemplateDayResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutTemplateDayResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutTemplateDayResponse call({
    Object? id = const $CopyWithPlaceholder(),
    Object? dayNumber = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? exercises = const $CopyWithPlaceholder(),
  }) {
    return WorkoutTemplateDayResponse(
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
          : exercises as List<ScheduleExercisePlan>?,
    );
  }
}

extension $WorkoutTemplateDayResponseCopyWith on WorkoutTemplateDayResponse {
  /// Returns a callable class that can be used as follows: `instanceOfWorkoutTemplateDayResponse.copyWith(...)` or like so:`instanceOfWorkoutTemplateDayResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkoutTemplateDayResponseCWProxy get copyWith =>
      _$WorkoutTemplateDayResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutTemplateDayResponse _$WorkoutTemplateDayResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('WorkoutTemplateDayResponse', json, ($checkedConvert) {
  final val = WorkoutTemplateDayResponse(
    id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
    dayNumber: $checkedConvert('dayNumber', (v) => (v as num?)?.toInt()),
    name: $checkedConvert('name', (v) => v as String?),
    note: $checkedConvert('note', (v) => v as String?),
    exercises: $checkedConvert(
      'exercises',
      (v) => (v as List<dynamic>?)
          ?.map((e) => ScheduleExercisePlan.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$WorkoutTemplateDayResponseToJson(
  WorkoutTemplateDayResponse instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'dayNumber': ?instance.dayNumber,
  'name': ?instance.name,
  'note': ?instance.note,
  'exercises': ?instance.exercises?.map((e) => e.toJson()).toList(),
};
