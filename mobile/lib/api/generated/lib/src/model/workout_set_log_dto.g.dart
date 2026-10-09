// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_set_log_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkoutSetLogDtoCWProxy {
  WorkoutSetLogDto setNumber(int? setNumber);

  WorkoutSetLogDto reps(int? reps);

  WorkoutSetLogDto weightKg(double? weightKg);

  WorkoutSetLogDto durationSeconds(int? durationSeconds);

  WorkoutSetLogDto rpe(double? rpe);

  WorkoutSetLogDto completed(bool? completed);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutSetLogDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutSetLogDto(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutSetLogDto call({
    int? setNumber,
    int? reps,
    double? weightKg,
    int? durationSeconds,
    double? rpe,
    bool? completed,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkoutSetLogDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkoutSetLogDto.copyWith.fieldName(...)`
class _$WorkoutSetLogDtoCWProxyImpl implements _$WorkoutSetLogDtoCWProxy {
  const _$WorkoutSetLogDtoCWProxyImpl(this._value);

  final WorkoutSetLogDto _value;

  @override
  WorkoutSetLogDto setNumber(int? setNumber) => this(setNumber: setNumber);

  @override
  WorkoutSetLogDto reps(int? reps) => this(reps: reps);

  @override
  WorkoutSetLogDto weightKg(double? weightKg) => this(weightKg: weightKg);

  @override
  WorkoutSetLogDto durationSeconds(int? durationSeconds) =>
      this(durationSeconds: durationSeconds);

  @override
  WorkoutSetLogDto rpe(double? rpe) => this(rpe: rpe);

  @override
  WorkoutSetLogDto completed(bool? completed) => this(completed: completed);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutSetLogDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutSetLogDto(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutSetLogDto call({
    Object? setNumber = const $CopyWithPlaceholder(),
    Object? reps = const $CopyWithPlaceholder(),
    Object? weightKg = const $CopyWithPlaceholder(),
    Object? durationSeconds = const $CopyWithPlaceholder(),
    Object? rpe = const $CopyWithPlaceholder(),
    Object? completed = const $CopyWithPlaceholder(),
  }) {
    return WorkoutSetLogDto(
      setNumber: setNumber == const $CopyWithPlaceholder()
          ? _value.setNumber
          // ignore: cast_nullable_to_non_nullable
          : setNumber as int?,
      reps: reps == const $CopyWithPlaceholder()
          ? _value.reps
          // ignore: cast_nullable_to_non_nullable
          : reps as int?,
      weightKg: weightKg == const $CopyWithPlaceholder()
          ? _value.weightKg
          // ignore: cast_nullable_to_non_nullable
          : weightKg as double?,
      durationSeconds: durationSeconds == const $CopyWithPlaceholder()
          ? _value.durationSeconds
          // ignore: cast_nullable_to_non_nullable
          : durationSeconds as int?,
      rpe: rpe == const $CopyWithPlaceholder()
          ? _value.rpe
          // ignore: cast_nullable_to_non_nullable
          : rpe as double?,
      completed: completed == const $CopyWithPlaceholder()
          ? _value.completed
          // ignore: cast_nullable_to_non_nullable
          : completed as bool?,
    );
  }
}

extension $WorkoutSetLogDtoCopyWith on WorkoutSetLogDto {
  /// Returns a callable class that can be used as follows: `instanceOfWorkoutSetLogDto.copyWith(...)` or like so:`instanceOfWorkoutSetLogDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkoutSetLogDtoCWProxy get copyWith => _$WorkoutSetLogDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutSetLogDto _$WorkoutSetLogDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WorkoutSetLogDto', json, ($checkedConvert) {
      final val = WorkoutSetLogDto(
        setNumber: $checkedConvert('setNumber', (v) => (v as num?)?.toInt()),
        reps: $checkedConvert('reps', (v) => (v as num?)?.toInt()),
        weightKg: $checkedConvert('weightKg', (v) => (v as num?)?.toDouble()),
        durationSeconds: $checkedConvert(
          'durationSeconds',
          (v) => (v as num?)?.toInt(),
        ),
        rpe: $checkedConvert('rpe', (v) => (v as num?)?.toDouble()),
        completed: $checkedConvert('completed', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$WorkoutSetLogDtoToJson(WorkoutSetLogDto instance) =>
    <String, dynamic>{
      'setNumber': ?instance.setNumber,
      'reps': ?instance.reps,
      'weightKg': ?instance.weightKg,
      'durationSeconds': ?instance.durationSeconds,
      'rpe': ?instance.rpe,
      'completed': ?instance.completed,
    };
