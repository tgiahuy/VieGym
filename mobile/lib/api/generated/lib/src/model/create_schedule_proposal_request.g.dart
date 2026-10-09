// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_schedule_proposal_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateScheduleProposalRequestCWProxy {
  CreateScheduleProposalRequest sourceType(String? sourceType);

  CreateScheduleProposalRequest scope(String? scope);

  CreateScheduleProposalRequest sourceId(int? sourceId);

  CreateScheduleProposalRequest sourceDayId(int? sourceDayId);

  CreateScheduleProposalRequest targetDates(List<DateTime>? targetDates);

  CreateScheduleProposalRequest scheduledTime(String? scheduledTime);

  CreateScheduleProposalRequest items(List<ScheduleProposalItemRequest>? items);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateScheduleProposalRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateScheduleProposalRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateScheduleProposalRequest call({
    String? sourceType,
    String? scope,
    int? sourceId,
    int? sourceDayId,
    List<DateTime>? targetDates,
    String? scheduledTime,
    List<ScheduleProposalItemRequest>? items,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateScheduleProposalRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateScheduleProposalRequest.copyWith.fieldName(...)`
class _$CreateScheduleProposalRequestCWProxyImpl
    implements _$CreateScheduleProposalRequestCWProxy {
  const _$CreateScheduleProposalRequestCWProxyImpl(this._value);

  final CreateScheduleProposalRequest _value;

  @override
  CreateScheduleProposalRequest sourceType(String? sourceType) =>
      this(sourceType: sourceType);

  @override
  CreateScheduleProposalRequest scope(String? scope) => this(scope: scope);

  @override
  CreateScheduleProposalRequest sourceId(int? sourceId) =>
      this(sourceId: sourceId);

  @override
  CreateScheduleProposalRequest sourceDayId(int? sourceDayId) =>
      this(sourceDayId: sourceDayId);

  @override
  CreateScheduleProposalRequest targetDates(List<DateTime>? targetDates) =>
      this(targetDates: targetDates);

  @override
  CreateScheduleProposalRequest scheduledTime(String? scheduledTime) =>
      this(scheduledTime: scheduledTime);

  @override
  CreateScheduleProposalRequest items(
    List<ScheduleProposalItemRequest>? items,
  ) => this(items: items);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateScheduleProposalRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateScheduleProposalRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateScheduleProposalRequest call({
    Object? sourceType = const $CopyWithPlaceholder(),
    Object? scope = const $CopyWithPlaceholder(),
    Object? sourceId = const $CopyWithPlaceholder(),
    Object? sourceDayId = const $CopyWithPlaceholder(),
    Object? targetDates = const $CopyWithPlaceholder(),
    Object? scheduledTime = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return CreateScheduleProposalRequest(
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
      sourceDayId: sourceDayId == const $CopyWithPlaceholder()
          ? _value.sourceDayId
          // ignore: cast_nullable_to_non_nullable
          : sourceDayId as int?,
      targetDates: targetDates == const $CopyWithPlaceholder()
          ? _value.targetDates
          // ignore: cast_nullable_to_non_nullable
          : targetDates as List<DateTime>?,
      scheduledTime: scheduledTime == const $CopyWithPlaceholder()
          ? _value.scheduledTime
          // ignore: cast_nullable_to_non_nullable
          : scheduledTime as String?,
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<ScheduleProposalItemRequest>?,
    );
  }
}

extension $CreateScheduleProposalRequestCopyWith
    on CreateScheduleProposalRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateScheduleProposalRequest.copyWith(...)` or like so:`instanceOfCreateScheduleProposalRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateScheduleProposalRequestCWProxy get copyWith =>
      _$CreateScheduleProposalRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateScheduleProposalRequest _$CreateScheduleProposalRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateScheduleProposalRequest', json, ($checkedConvert) {
  final val = CreateScheduleProposalRequest(
    sourceType: $checkedConvert('sourceType', (v) => v as String?),
    scope: $checkedConvert('scope', (v) => v as String?),
    sourceId: $checkedConvert('sourceId', (v) => (v as num?)?.toInt()),
    sourceDayId: $checkedConvert('sourceDayId', (v) => (v as num?)?.toInt()),
    targetDates: $checkedConvert(
      'targetDates',
      (v) => (v as List<dynamic>?)
          ?.map((e) => DateTime.parse(e as String))
          .toList(),
    ),
    scheduledTime: $checkedConvert('scheduledTime', (v) => v as String?),
    items: $checkedConvert(
      'items',
      (v) => (v as List<dynamic>?)
          ?.map(
            (e) =>
                ScheduleProposalItemRequest.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$CreateScheduleProposalRequestToJson(
  CreateScheduleProposalRequest instance,
) => <String, dynamic>{
  'sourceType': ?instance.sourceType,
  'scope': ?instance.scope,
  'sourceId': ?instance.sourceId,
  'sourceDayId': ?instance.sourceDayId,
  'targetDates': ?instance.targetDates
      ?.map((e) => e.toIso8601String())
      .toList(),
  'scheduledTime': ?instance.scheduledTime,
  'items': ?instance.items?.map((e) => e.toJson()).toList(),
};
