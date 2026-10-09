// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finish_session_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FinishSessionRequestCWProxy {
  FinishSessionRequest note(String? note);

  FinishSessionRequest exercises(List<FinishExerciseLogRequest>? exercises);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FinishSessionRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FinishSessionRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  FinishSessionRequest call({
    String? note,
    List<FinishExerciseLogRequest>? exercises,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFinishSessionRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFinishSessionRequest.copyWith.fieldName(...)`
class _$FinishSessionRequestCWProxyImpl
    implements _$FinishSessionRequestCWProxy {
  const _$FinishSessionRequestCWProxyImpl(this._value);

  final FinishSessionRequest _value;

  @override
  FinishSessionRequest note(String? note) => this(note: note);

  @override
  FinishSessionRequest exercises(List<FinishExerciseLogRequest>? exercises) =>
      this(exercises: exercises);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FinishSessionRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FinishSessionRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  FinishSessionRequest call({
    Object? note = const $CopyWithPlaceholder(),
    Object? exercises = const $CopyWithPlaceholder(),
  }) {
    return FinishSessionRequest(
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
      exercises: exercises == const $CopyWithPlaceholder()
          ? _value.exercises
          // ignore: cast_nullable_to_non_nullable
          : exercises as List<FinishExerciseLogRequest>?,
    );
  }
}

extension $FinishSessionRequestCopyWith on FinishSessionRequest {
  /// Returns a callable class that can be used as follows: `instanceOfFinishSessionRequest.copyWith(...)` or like so:`instanceOfFinishSessionRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FinishSessionRequestCWProxy get copyWith =>
      _$FinishSessionRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FinishSessionRequest _$FinishSessionRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('FinishSessionRequest', json, ($checkedConvert) {
  final val = FinishSessionRequest(
    note: $checkedConvert('note', (v) => v as String?),
    exercises: $checkedConvert(
      'exercises',
      (v) => (v as List<dynamic>?)
          ?.map(
            (e) => FinishExerciseLogRequest.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$FinishSessionRequestToJson(
  FinishSessionRequest instance,
) => <String, dynamic>{
  'note': ?instance.note,
  'exercises': ?instance.exercises?.map((e) => e.toJson()).toList(),
};
