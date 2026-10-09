// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finish_exercise_log_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FinishExerciseLogRequestCWProxy {
  FinishExerciseLogRequest exerciseId(int? exerciseId);

  FinishExerciseLogRequest sortOrder(int? sortOrder);

  FinishExerciseLogRequest durationSeconds(int? durationSeconds);

  FinishExerciseLogRequest completed(bool? completed);

  FinishExerciseLogRequest sets(List<FinishSetLogRequest>? sets);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FinishExerciseLogRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FinishExerciseLogRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  FinishExerciseLogRequest call({
    int? exerciseId,
    int? sortOrder,
    int? durationSeconds,
    bool? completed,
    List<FinishSetLogRequest>? sets,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFinishExerciseLogRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFinishExerciseLogRequest.copyWith.fieldName(...)`
class _$FinishExerciseLogRequestCWProxyImpl
    implements _$FinishExerciseLogRequestCWProxy {
  const _$FinishExerciseLogRequestCWProxyImpl(this._value);

  final FinishExerciseLogRequest _value;

  @override
  FinishExerciseLogRequest exerciseId(int? exerciseId) =>
      this(exerciseId: exerciseId);

  @override
  FinishExerciseLogRequest sortOrder(int? sortOrder) =>
      this(sortOrder: sortOrder);

  @override
  FinishExerciseLogRequest durationSeconds(int? durationSeconds) =>
      this(durationSeconds: durationSeconds);

  @override
  FinishExerciseLogRequest completed(bool? completed) =>
      this(completed: completed);

  @override
  FinishExerciseLogRequest sets(List<FinishSetLogRequest>? sets) =>
      this(sets: sets);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FinishExerciseLogRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FinishExerciseLogRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  FinishExerciseLogRequest call({
    Object? exerciseId = const $CopyWithPlaceholder(),
    Object? sortOrder = const $CopyWithPlaceholder(),
    Object? durationSeconds = const $CopyWithPlaceholder(),
    Object? completed = const $CopyWithPlaceholder(),
    Object? sets = const $CopyWithPlaceholder(),
  }) {
    return FinishExerciseLogRequest(
      exerciseId: exerciseId == const $CopyWithPlaceholder()
          ? _value.exerciseId
          // ignore: cast_nullable_to_non_nullable
          : exerciseId as int?,
      sortOrder: sortOrder == const $CopyWithPlaceholder()
          ? _value.sortOrder
          // ignore: cast_nullable_to_non_nullable
          : sortOrder as int?,
      durationSeconds: durationSeconds == const $CopyWithPlaceholder()
          ? _value.durationSeconds
          // ignore: cast_nullable_to_non_nullable
          : durationSeconds as int?,
      completed: completed == const $CopyWithPlaceholder()
          ? _value.completed
          // ignore: cast_nullable_to_non_nullable
          : completed as bool?,
      sets: sets == const $CopyWithPlaceholder()
          ? _value.sets
          // ignore: cast_nullable_to_non_nullable
          : sets as List<FinishSetLogRequest>?,
    );
  }
}

extension $FinishExerciseLogRequestCopyWith on FinishExerciseLogRequest {
  /// Returns a callable class that can be used as follows: `instanceOfFinishExerciseLogRequest.copyWith(...)` or like so:`instanceOfFinishExerciseLogRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FinishExerciseLogRequestCWProxy get copyWith =>
      _$FinishExerciseLogRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FinishExerciseLogRequest _$FinishExerciseLogRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('FinishExerciseLogRequest', json, ($checkedConvert) {
  final val = FinishExerciseLogRequest(
    exerciseId: $checkedConvert('exerciseId', (v) => (v as num?)?.toInt()),
    sortOrder: $checkedConvert('sortOrder', (v) => (v as num?)?.toInt()),
    durationSeconds: $checkedConvert(
      'durationSeconds',
      (v) => (v as num?)?.toInt(),
    ),
    completed: $checkedConvert('completed', (v) => v as bool?),
    sets: $checkedConvert(
      'sets',
      (v) => (v as List<dynamic>?)
          ?.map((e) => FinishSetLogRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$FinishExerciseLogRequestToJson(
  FinishExerciseLogRequest instance,
) => <String, dynamic>{
  'exerciseId': ?instance.exerciseId,
  'sortOrder': ?instance.sortOrder,
  'durationSeconds': ?instance.durationSeconds,
  'completed': ?instance.completed,
  'sets': ?instance.sets?.map((e) => e.toJson()).toList(),
};
