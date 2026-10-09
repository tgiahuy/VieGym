// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resume_session_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ResumeSessionResponseCWProxy {
  ResumeSessionResponse id(int? id);

  ResumeSessionResponse status(String? status);

  ResumeSessionResponse totalPausedSeconds(int? totalPausedSeconds);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ResumeSessionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ResumeSessionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ResumeSessionResponse call({
    int? id,
    String? status,
    int? totalPausedSeconds,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfResumeSessionResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfResumeSessionResponse.copyWith.fieldName(...)`
class _$ResumeSessionResponseCWProxyImpl
    implements _$ResumeSessionResponseCWProxy {
  const _$ResumeSessionResponseCWProxyImpl(this._value);

  final ResumeSessionResponse _value;

  @override
  ResumeSessionResponse id(int? id) => this(id: id);

  @override
  ResumeSessionResponse status(String? status) => this(status: status);

  @override
  ResumeSessionResponse totalPausedSeconds(int? totalPausedSeconds) =>
      this(totalPausedSeconds: totalPausedSeconds);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ResumeSessionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ResumeSessionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ResumeSessionResponse call({
    Object? id = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? totalPausedSeconds = const $CopyWithPlaceholder(),
  }) {
    return ResumeSessionResponse(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String?,
      totalPausedSeconds: totalPausedSeconds == const $CopyWithPlaceholder()
          ? _value.totalPausedSeconds
          // ignore: cast_nullable_to_non_nullable
          : totalPausedSeconds as int?,
    );
  }
}

extension $ResumeSessionResponseCopyWith on ResumeSessionResponse {
  /// Returns a callable class that can be used as follows: `instanceOfResumeSessionResponse.copyWith(...)` or like so:`instanceOfResumeSessionResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ResumeSessionResponseCWProxy get copyWith =>
      _$ResumeSessionResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResumeSessionResponse _$ResumeSessionResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ResumeSessionResponse', json, ($checkedConvert) {
  final val = ResumeSessionResponse(
    id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
    status: $checkedConvert('status', (v) => v as String?),
    totalPausedSeconds: $checkedConvert(
      'totalPausedSeconds',
      (v) => (v as num?)?.toInt(),
    ),
  );
  return val;
});

Map<String, dynamic> _$ResumeSessionResponseToJson(
  ResumeSessionResponse instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'status': ?instance.status,
  'totalPausedSeconds': ?instance.totalPausedSeconds,
};
