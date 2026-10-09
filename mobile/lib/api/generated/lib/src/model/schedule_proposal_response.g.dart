// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_proposal_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ScheduleProposalResponseCWProxy {
  ScheduleProposalResponse id(int? id);

  ScheduleProposalResponse sourceType(String? sourceType);

  ScheduleProposalResponse scope(String? scope);

  ScheduleProposalResponse sourceId(int? sourceId);

  ScheduleProposalResponse sourceVersion(int? sourceVersion);

  ScheduleProposalResponse status(String? status);

  ScheduleProposalResponse expiresAt(DateTime? expiresAt);

  ScheduleProposalResponse appliedAt(DateTime? appliedAt);

  ScheduleProposalResponse items(List<ScheduleProposalItemResponse>? items);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ScheduleProposalResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ScheduleProposalResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ScheduleProposalResponse call({
    int? id,
    String? sourceType,
    String? scope,
    int? sourceId,
    int? sourceVersion,
    String? status,
    DateTime? expiresAt,
    DateTime? appliedAt,
    List<ScheduleProposalItemResponse>? items,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfScheduleProposalResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfScheduleProposalResponse.copyWith.fieldName(...)`
class _$ScheduleProposalResponseCWProxyImpl
    implements _$ScheduleProposalResponseCWProxy {
  const _$ScheduleProposalResponseCWProxyImpl(this._value);

  final ScheduleProposalResponse _value;

  @override
  ScheduleProposalResponse id(int? id) => this(id: id);

  @override
  ScheduleProposalResponse sourceType(String? sourceType) =>
      this(sourceType: sourceType);

  @override
  ScheduleProposalResponse scope(String? scope) => this(scope: scope);

  @override
  ScheduleProposalResponse sourceId(int? sourceId) => this(sourceId: sourceId);

  @override
  ScheduleProposalResponse sourceVersion(int? sourceVersion) =>
      this(sourceVersion: sourceVersion);

  @override
  ScheduleProposalResponse status(String? status) => this(status: status);

  @override
  ScheduleProposalResponse expiresAt(DateTime? expiresAt) =>
      this(expiresAt: expiresAt);

  @override
  ScheduleProposalResponse appliedAt(DateTime? appliedAt) =>
      this(appliedAt: appliedAt);

  @override
  ScheduleProposalResponse items(List<ScheduleProposalItemResponse>? items) =>
      this(items: items);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ScheduleProposalResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ScheduleProposalResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ScheduleProposalResponse call({
    Object? id = const $CopyWithPlaceholder(),
    Object? sourceType = const $CopyWithPlaceholder(),
    Object? scope = const $CopyWithPlaceholder(),
    Object? sourceId = const $CopyWithPlaceholder(),
    Object? sourceVersion = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
    Object? appliedAt = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return ScheduleProposalResponse(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      sourceType: sourceType == const $CopyWithPlaceholder()
          ? _value.sourceType
          // ignore: cast_nullable_to_non_nullable
          : sourceType as String?,
      scope: scope == const $CopyWithPlaceholder()
          ? _value.scope
          // ignore: cast_nullable_to_non_nullable
          : scope as String?,
      sourceId: sourceId == const $CopyWithPlaceholder()
          ? _value.sourceId
          // ignore: cast_nullable_to_non_nullable
          : sourceId as int?,
      sourceVersion: sourceVersion == const $CopyWithPlaceholder()
          ? _value.sourceVersion
          // ignore: cast_nullable_to_non_nullable
          : sourceVersion as int?,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String?,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime?,
      appliedAt: appliedAt == const $CopyWithPlaceholder()
          ? _value.appliedAt
          // ignore: cast_nullable_to_non_nullable
          : appliedAt as DateTime?,
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<ScheduleProposalItemResponse>?,
    );
  }
}

extension $ScheduleProposalResponseCopyWith on ScheduleProposalResponse {
  /// Returns a callable class that can be used as follows: `instanceOfScheduleProposalResponse.copyWith(...)` or like so:`instanceOfScheduleProposalResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ScheduleProposalResponseCWProxy get copyWith =>
      _$ScheduleProposalResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduleProposalResponse _$ScheduleProposalResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ScheduleProposalResponse', json, ($checkedConvert) {
  final val = ScheduleProposalResponse(
    id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
    sourceType: $checkedConvert('sourceType', (v) => v as String?),
    scope: $checkedConvert('scope', (v) => v as String?),
    sourceId: $checkedConvert('sourceId', (v) => (v as num?)?.toInt()),
    sourceVersion: $checkedConvert(
      'sourceVersion',
      (v) => (v as num?)?.toInt(),
    ),
    status: $checkedConvert('status', (v) => v as String?),
    expiresAt: $checkedConvert(
      'expiresAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    appliedAt: $checkedConvert(
      'appliedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    items: $checkedConvert(
      'items',
      (v) => (v as List<dynamic>?)
          ?.map(
            (e) => ScheduleProposalItemResponse.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$ScheduleProposalResponseToJson(
  ScheduleProposalResponse instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'sourceType': ?instance.sourceType,
  'scope': ?instance.scope,
  'sourceId': ?instance.sourceId,
  'sourceVersion': ?instance.sourceVersion,
  'status': ?instance.status,
  'expiresAt': ?instance.expiresAt?.toIso8601String(),
  'appliedAt': ?instance.appliedAt?.toIso8601String(),
  'items': ?instance.items?.map((e) => e.toJson()).toList(),
};
