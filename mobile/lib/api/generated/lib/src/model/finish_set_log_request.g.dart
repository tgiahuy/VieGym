// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finish_set_log_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FinishSetLogRequestCWProxy {
  FinishSetLogRequest setNumber(int? setNumber);

  FinishSetLogRequest reps(int? reps);

  FinishSetLogRequest weightKg(double? weightKg);

  FinishSetLogRequest durationSeconds(int? durationSeconds);

  FinishSetLogRequest rpe(double? rpe);

  FinishSetLogRequest completed(bool? completed);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FinishSetLogRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FinishSetLogRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  FinishSetLogRequest call({
    int? setNumber,
    int? reps,
    double? weightKg,
    int? durationSeconds,
    double? rpe,
    bool? completed,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFinishSetLogRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFinishSetLogRequest.copyWith.fieldName(...)`
class _$FinishSetLogRequestCWProxyImpl implements _$FinishSetLogRequestCWProxy {
  const _$FinishSetLogRequestCWProxyImpl(this._value);

  final FinishSetLogRequest _value;

  @override
  FinishSetLogRequest setNumber(int? setNumber) => this(setNumber: setNumber);

  @override
  FinishSetLogRequest reps(int? reps) => this(reps: reps);

  @override
  FinishSetLogRequest weightKg(double? weightKg) => this(weightKg: weightKg);

  @override
  FinishSetLogRequest durationSeconds(int? durationSeconds) =>
      this(durationSeconds: durationSeconds);

  @override
  FinishSetLogRequest rpe(double? rpe) => this(rpe: rpe);

  @override
  FinishSetLogRequest completed(bool? completed) => this(completed: completed);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FinishSetLogRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FinishSetLogRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  FinishSetLogRequest call({
    Object? setNumber = const $CopyWithPlaceholder(),
    Object? reps = const $CopyWithPlaceholder(),
    Object? weightKg = const $CopyWithPlaceholder(),
    Object? durationSeconds = const $CopyWithPlaceholder(),
    Object? rpe = const $CopyWithPlaceholder(),
    Object? completed = const $CopyWithPlaceholder(),
  }) {
    return FinishSetLogRequest(
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

extension $FinishSetLogRequestCopyWith on FinishSetLogRequest {
  /// Returns a callable class that can be used as follows: `instanceOfFinishSetLogRequest.copyWith(...)` or like so:`instanceOfFinishSetLogRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FinishSetLogRequestCWProxy get copyWith =>
      _$FinishSetLogRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FinishSetLogRequest _$FinishSetLogRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('FinishSetLogRequest', json, ($checkedConvert) {
      final val = FinishSetLogRequest(
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

Map<String, dynamic> _$FinishSetLogRequestToJson(
  FinishSetLogRequest instance,
) => <String, dynamic>{
  'setNumber': ?instance.setNumber,
  'reps': ?instance.reps,
  'weightKg': ?instance.weightKg,
  'durationSeconds': ?instance.durationSeconds,
  'rpe': ?instance.rpe,
  'completed': ?instance.completed,
};
