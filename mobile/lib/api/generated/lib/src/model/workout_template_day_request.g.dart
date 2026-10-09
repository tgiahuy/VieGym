// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_template_day_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkoutTemplateDayRequestCWProxy {
  WorkoutTemplateDayRequest dayNumber(int? dayNumber);

  WorkoutTemplateDayRequest name(String? name);

  WorkoutTemplateDayRequest note(String? note);

  WorkoutTemplateDayRequest exercises(List<ScheduleExercisePlan>? exercises);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutTemplateDayRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutTemplateDayRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutTemplateDayRequest call({
    int? dayNumber,
    String? name,
    String? note,
    List<ScheduleExercisePlan>? exercises,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkoutTemplateDayRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkoutTemplateDayRequest.copyWith.fieldName(...)`
class _$WorkoutTemplateDayRequestCWProxyImpl
    implements _$WorkoutTemplateDayRequestCWProxy {
  const _$WorkoutTemplateDayRequestCWProxyImpl(this._value);

  final WorkoutTemplateDayRequest _value;

  @override
  WorkoutTemplateDayRequest dayNumber(int? dayNumber) =>
      this(dayNumber: dayNumber);

  @override
  WorkoutTemplateDayRequest name(String? name) => this(name: name);

  @override
  WorkoutTemplateDayRequest note(String? note) => this(note: note);

  @override
  WorkoutTemplateDayRequest exercises(List<ScheduleExercisePlan>? exercises) =>
      this(exercises: exercises);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutTemplateDayRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutTemplateDayRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutTemplateDayRequest call({
    Object? dayNumber = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? exercises = const $CopyWithPlaceholder(),
  }) {
    return WorkoutTemplateDayRequest(
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

extension $WorkoutTemplateDayRequestCopyWith on WorkoutTemplateDayRequest {
  /// Returns a callable class that can be used as follows: `instanceOfWorkoutTemplateDayRequest.copyWith(...)` or like so:`instanceOfWorkoutTemplateDayRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkoutTemplateDayRequestCWProxy get copyWith =>
      _$WorkoutTemplateDayRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutTemplateDayRequest _$WorkoutTemplateDayRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('WorkoutTemplateDayRequest', json, ($checkedConvert) {
  final val = WorkoutTemplateDayRequest(
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

Map<String, dynamic> _$WorkoutTemplateDayRequestToJson(
  WorkoutTemplateDayRequest instance,
) => <String, dynamic>{
  'dayNumber': ?instance.dayNumber,
  'name': ?instance.name,
  'note': ?instance.note,
  'exercises': ?instance.exercises?.map((e) => e.toJson()).toList(),
};
