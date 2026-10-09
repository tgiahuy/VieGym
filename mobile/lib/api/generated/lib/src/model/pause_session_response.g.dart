// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pause_session_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PauseSessionResponseCWProxy {
  PauseSessionResponse id(int? id);

  PauseSessionResponse status(String? status);

  PauseSessionResponse pausedAt(DateTime? pausedAt);

  PauseSessionResponse totalPausedSeconds(int? totalPausedSeconds);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PauseSessionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PauseSessionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PauseSessionResponse call({
    int? id,
    String? status,
    DateTime? pausedAt,
    int? totalPausedSeconds,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPauseSessionResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPauseSessionResponse.copyWith.fieldName(...)`
class _$PauseSessionResponseCWProxyImpl
    implements _$PauseSessionResponseCWProxy {
  const _$PauseSessionResponseCWProxyImpl(this._value);

  final PauseSessionResponse _value;

  @override
  PauseSessionResponse id(int? id) => this(id: id);

  @override
  PauseSessionResponse status(String? status) => this(status: status);

  @override
  PauseSessionResponse pausedAt(DateTime? pausedAt) => this(pausedAt: pausedAt);

  @override
  PauseSessionResponse totalPausedSeconds(int? totalPausedSeconds) =>
      this(totalPausedSeconds: totalPausedSeconds);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PauseSessionResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PauseSessionResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PauseSessionResponse call({
    Object? id = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? pausedAt = const $CopyWithPlaceholder(),
    Object? totalPausedSeconds = const $CopyWithPlaceholder(),
  }) {
    return PauseSessionResponse(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String?,
      pausedAt: pausedAt == const $CopyWithPlaceholder()
          ? _value.pausedAt
          // ignore: cast_nullable_to_non_nullable
          : pausedAt as DateTime?,
      totalPausedSeconds: totalPausedSeconds == const $CopyWithPlaceholder()
          ? _value.totalPausedSeconds
          // ignore: cast_nullable_to_non_nullable
          : totalPausedSeconds as int?,
    );
  }
}

extension $PauseSessionResponseCopyWith on PauseSessionResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPauseSessionResponse.copyWith(...)` or like so:`instanceOfPauseSessionResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PauseSessionResponseCWProxy get copyWith =>
      _$PauseSessionResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PauseSessionResponse _$PauseSessionResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PauseSessionResponse', json, ($checkedConvert) {
  final val = PauseSessionResponse(
    id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
    status: $checkedConvert('status', (v) => v as String?),
    pausedAt: $checkedConvert(
      'pausedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    totalPausedSeconds: $checkedConvert(
      'totalPausedSeconds',
      (v) => (v as num?)?.toInt(),
    ),
  );
  return val;
});

Map<String, dynamic> _$PauseSessionResponseToJson(
  PauseSessionResponse instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'status': ?instance.status,
  'pausedAt': ?instance.pausedAt?.toIso8601String(),
  'totalPausedSeconds': ?instance.totalPausedSeconds,
};
