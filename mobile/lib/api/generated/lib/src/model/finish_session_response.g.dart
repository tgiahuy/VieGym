// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finish_session_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FinishSessionResponseCWProxy {
  FinishSessionResponse workoutLogId(int? workoutLogId);

  FinishSessionResponse workoutSessionId(int? workoutSessionId);

  FinishSessionResponse durationSeconds(int? durationSeconds);

  FinishSessionResponse totalVolumeKg(double? totalVolumeKg);

  FinishSessionResponse newPersonalRecords(
    List<PersonalRecordDto>? newPersonalRecords,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FinishSessionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FinishSessionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  FinishSessionResponse call({
    int? workoutLogId,
    int? workoutSessionId,
    int? durationSeconds,
    double? totalVolumeKg,
    List<PersonalRecordDto>? newPersonalRecords,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFinishSessionResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFinishSessionResponse.copyWith.fieldName(...)`
class _$FinishSessionResponseCWProxyImpl
    implements _$FinishSessionResponseCWProxy {
  const _$FinishSessionResponseCWProxyImpl(this._value);

  final FinishSessionResponse _value;

  @override
  FinishSessionResponse workoutLogId(int? workoutLogId) =>
      this(workoutLogId: workoutLogId);

  @override
  FinishSessionResponse workoutSessionId(int? workoutSessionId) =>
      this(workoutSessionId: workoutSessionId);

  @override
  FinishSessionResponse durationSeconds(int? durationSeconds) =>
      this(durationSeconds: durationSeconds);

  @override
  FinishSessionResponse totalVolumeKg(double? totalVolumeKg) =>
      this(totalVolumeKg: totalVolumeKg);

  @override
  FinishSessionResponse newPersonalRecords(
    List<PersonalRecordDto>? newPersonalRecords,
  ) => this(newPersonalRecords: newPersonalRecords);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FinishSessionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FinishSessionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  FinishSessionResponse call({
    Object? workoutLogId = const $CopyWithPlaceholder(),
    Object? workoutSessionId = const $CopyWithPlaceholder(),
    Object? durationSeconds = const $CopyWithPlaceholder(),
    Object? totalVolumeKg = const $CopyWithPlaceholder(),
    Object? newPersonalRecords = const $CopyWithPlaceholder(),
  }) {
    return FinishSessionResponse(
      workoutLogId: workoutLogId == const $CopyWithPlaceholder()
          ? _value.workoutLogId
          // ignore: cast_nullable_to_non_nullable
          : workoutLogId as int?,
      workoutSessionId: workoutSessionId == const $CopyWithPlaceholder()
          ? _value.workoutSessionId
          // ignore: cast_nullable_to_non_nullable
          : workoutSessionId as int?,
      durationSeconds: durationSeconds == const $CopyWithPlaceholder()
          ? _value.durationSeconds
          // ignore: cast_nullable_to_non_nullable
          : durationSeconds as int?,
      totalVolumeKg: totalVolumeKg == const $CopyWithPlaceholder()
          ? _value.totalVolumeKg
          // ignore: cast_nullable_to_non_nullable
          : totalVolumeKg as double?,
      newPersonalRecords: newPersonalRecords == const $CopyWithPlaceholder()
          ? _value.newPersonalRecords
          // ignore: cast_nullable_to_non_nullable
          : newPersonalRecords as List<PersonalRecordDto>?,
    );
  }
}

extension $FinishSessionResponseCopyWith on FinishSessionResponse {
  /// Returns a callable class that can be used as follows: `instanceOfFinishSessionResponse.copyWith(...)` or like so:`instanceOfFinishSessionResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FinishSessionResponseCWProxy get copyWith =>
      _$FinishSessionResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FinishSessionResponse _$FinishSessionResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('FinishSessionResponse', json, ($checkedConvert) {
  final val = FinishSessionResponse(
    workoutLogId: $checkedConvert('workoutLogId', (v) => (v as num?)?.toInt()),
    workoutSessionId: $checkedConvert(
      'workoutSessionId',
      (v) => (v as num?)?.toInt(),
    ),
    durationSeconds: $checkedConvert(
      'durationSeconds',
      (v) => (v as num?)?.toInt(),
    ),
    totalVolumeKg: $checkedConvert(
      'totalVolumeKg',
      (v) => (v as num?)?.toDouble(),
    ),
    newPersonalRecords: $checkedConvert(
      'newPersonalRecords',
      (v) => (v as List<dynamic>?)
          ?.map((e) => PersonalRecordDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$FinishSessionResponseToJson(
  FinishSessionResponse instance,
) => <String, dynamic>{
  'workoutLogId': ?instance.workoutLogId,
  'workoutSessionId': ?instance.workoutSessionId,
  'durationSeconds': ?instance.durationSeconds,
  'totalVolumeKg': ?instance.totalVolumeKg,
  'newPersonalRecords': ?instance.newPersonalRecords
      ?.map((e) => e.toJson())
      .toList(),
};
