// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_exercise_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkoutExerciseRequestCWProxy {
  WorkoutExerciseRequest id(int? id);

  WorkoutExerciseRequest exerciseId(int? exerciseId);

  WorkoutExerciseRequest sortOrder(int? sortOrder);

  WorkoutExerciseRequest targetSets(int? targetSets);

  WorkoutExerciseRequest targetRepsMin(int? targetRepsMin);

  WorkoutExerciseRequest targetRepsMax(int? targetRepsMax);

  WorkoutExerciseRequest targetDurationSeconds(int? targetDurationSeconds);

  WorkoutExerciseRequest restSeconds(int? restSeconds);

  WorkoutExerciseRequest note(String? note);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutExerciseRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutExerciseRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutExerciseRequest call({
    int? id,
    int? exerciseId,
    int? sortOrder,
    int? targetSets,
    int? targetRepsMin,
    int? targetRepsMax,
    int? targetDurationSeconds,
    int? restSeconds,
    String? note,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkoutExerciseRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkoutExerciseRequest.copyWith.fieldName(...)`
class _$WorkoutExerciseRequestCWProxyImpl
    implements _$WorkoutExerciseRequestCWProxy {
  const _$WorkoutExerciseRequestCWProxyImpl(this._value);

  final WorkoutExerciseRequest _value;

  @override
  WorkoutExerciseRequest id(int? id) => this(id: id);

  @override
  WorkoutExerciseRequest exerciseId(int? exerciseId) =>
      this(exerciseId: exerciseId);

  @override
  WorkoutExerciseRequest sortOrder(int? sortOrder) =>
      this(sortOrder: sortOrder);

  @override
  WorkoutExerciseRequest targetSets(int? targetSets) =>
      this(targetSets: targetSets);

  @override
  WorkoutExerciseRequest targetRepsMin(int? targetRepsMin) =>
      this(targetRepsMin: targetRepsMin);

  @override
  WorkoutExerciseRequest targetRepsMax(int? targetRepsMax) =>
      this(targetRepsMax: targetRepsMax);

  @override
  WorkoutExerciseRequest targetDurationSeconds(int? targetDurationSeconds) =>
      this(targetDurationSeconds: targetDurationSeconds);

  @override
  WorkoutExerciseRequest restSeconds(int? restSeconds) =>
      this(restSeconds: restSeconds);

  @override
  WorkoutExerciseRequest note(String? note) => this(note: note);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WorkoutExerciseRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WorkoutExerciseRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  WorkoutExerciseRequest call({
    Object? id = const $CopyWithPlaceholder(),
    Object? exerciseId = const $CopyWithPlaceholder(),
    Object? sortOrder = const $CopyWithPlaceholder(),
    Object? targetSets = const $CopyWithPlaceholder(),
    Object? targetRepsMin = const $CopyWithPlaceholder(),
    Object? targetRepsMax = const $CopyWithPlaceholder(),
    Object? targetDurationSeconds = const $CopyWithPlaceholder(),
    Object? restSeconds = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
  }) {
    return WorkoutExerciseRequest(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      exerciseId: exerciseId == const $CopyWithPlaceholder()
          ? _value.exerciseId
          // ignore: cast_nullable_to_non_nullable
          : exerciseId as int?,
      sortOrder: sortOrder == const $CopyWithPlaceholder()
          ? _value.sortOrder
          // ignore: cast_nullable_to_non_nullable
          : sortOrder as int?,
      targetSets: targetSets == const $CopyWithPlaceholder()
          ? _value.targetSets
          // ignore: cast_nullable_to_non_nullable
          : targetSets as int?,
      targetRepsMin: targetRepsMin == const $CopyWithPlaceholder()
          ? _value.targetRepsMin
          // ignore: cast_nullable_to_non_nullable
          : targetRepsMin as int?,
      targetRepsMax: targetRepsMax == const $CopyWithPlaceholder()
          ? _value.targetRepsMax
          // ignore: cast_nullable_to_non_nullable
          : targetRepsMax as int?,
      targetDurationSeconds:
          targetDurationSeconds == const $CopyWithPlaceholder()
          ? _value.targetDurationSeconds
          // ignore: cast_nullable_to_non_nullable
          : targetDurationSeconds as int?,
      restSeconds: restSeconds == const $CopyWithPlaceholder()
          ? _value.restSeconds
          // ignore: cast_nullable_to_non_nullable
          : restSeconds as int?,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
    );
  }
}

extension $WorkoutExerciseRequestCopyWith on WorkoutExerciseRequest {
  /// Returns a callable class that can be used as follows: `instanceOfWorkoutExerciseRequest.copyWith(...)` or like so:`instanceOfWorkoutExerciseRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkoutExerciseRequestCWProxy get copyWith =>
      _$WorkoutExerciseRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutExerciseRequest _$WorkoutExerciseRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('WorkoutExerciseRequest', json, ($checkedConvert) {
  final val = WorkoutExerciseRequest(
    id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
    exerciseId: $checkedConvert('exerciseId', (v) => (v as num?)?.toInt()),
    sortOrder: $checkedConvert('sortOrder', (v) => (v as num?)?.toInt()),
    targetSets: $checkedConvert('targetSets', (v) => (v as num?)?.toInt()),
    targetRepsMin: $checkedConvert(
      'targetRepsMin',
      (v) => (v as num?)?.toInt(),
    ),
    targetRepsMax: $checkedConvert(
      'targetRepsMax',
      (v) => (v as num?)?.toInt(),
    ),
    targetDurationSeconds: $checkedConvert(
      'targetDurationSeconds',
      (v) => (v as num?)?.toInt(),
    ),
    restSeconds: $checkedConvert('restSeconds', (v) => (v as num?)?.toInt()),
    note: $checkedConvert('note', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$WorkoutExerciseRequestToJson(
  WorkoutExerciseRequest instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'exerciseId': ?instance.exerciseId,
  'sortOrder': ?instance.sortOrder,
  'targetSets': ?instance.targetSets,
  'targetRepsMin': ?instance.targetRepsMin,
  'targetRepsMax': ?instance.targetRepsMax,
  'targetDurationSeconds': ?instance.targetDurationSeconds,
  'restSeconds': ?instance.restSeconds,
  'note': ?instance.note,
};
