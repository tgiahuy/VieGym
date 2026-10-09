// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_proposal_item_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ScheduleProposalItemResponseCWProxy {
  ScheduleProposalItemResponse id(int? id);

  ScheduleProposalItemResponse sortOrder(int? sortOrder);

  ScheduleProposalItemResponse sourceDayId(int? sourceDayId);

  ScheduleProposalItemResponse scheduledDate(DateTime? scheduledDate);

  ScheduleProposalItemResponse scheduledTime(String? scheduledTime);

  ScheduleProposalItemResponse title(String? title);

  ScheduleProposalItemResponse appliedScheduleId(int? appliedScheduleId);

  ScheduleProposalItemResponse exercises(List<ScheduleExercisePlan>? exercises);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ScheduleProposalItemResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ScheduleProposalItemResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ScheduleProposalItemResponse call({
    int? id,
    int? sortOrder,
    int? sourceDayId,
    DateTime? scheduledDate,
    String? scheduledTime,
    String? title,
    int? appliedScheduleId,
    List<ScheduleExercisePlan>? exercises,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfScheduleProposalItemResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfScheduleProposalItemResponse.copyWith.fieldName(...)`
class _$ScheduleProposalItemResponseCWProxyImpl
    implements _$ScheduleProposalItemResponseCWProxy {
  const _$ScheduleProposalItemResponseCWProxyImpl(this._value);

  final ScheduleProposalItemResponse _value;

  @override
  ScheduleProposalItemResponse id(int? id) => this(id: id);

  @override
  ScheduleProposalItemResponse sortOrder(int? sortOrder) =>
      this(sortOrder: sortOrder);

  @override
  ScheduleProposalItemResponse sourceDayId(int? sourceDayId) =>
      this(sourceDayId: sourceDayId);

  @override
  ScheduleProposalItemResponse scheduledDate(DateTime? scheduledDate) =>
      this(scheduledDate: scheduledDate);

  @override
  ScheduleProposalItemResponse scheduledTime(String? scheduledTime) =>
      this(scheduledTime: scheduledTime);

  @override
  ScheduleProposalItemResponse title(String? title) => this(title: title);

  @override
  ScheduleProposalItemResponse appliedScheduleId(int? appliedScheduleId) =>
      this(appliedScheduleId: appliedScheduleId);

  @override
  ScheduleProposalItemResponse exercises(
    List<ScheduleExercisePlan>? exercises,
  ) => this(exercises: exercises);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ScheduleProposalItemResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ScheduleProposalItemResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ScheduleProposalItemResponse call({
    Object? id = const $CopyWithPlaceholder(),
    Object? sortOrder = const $CopyWithPlaceholder(),
    Object? sourceDayId = const $CopyWithPlaceholder(),
    Object? scheduledDate = const $CopyWithPlaceholder(),
    Object? scheduledTime = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? appliedScheduleId = const $CopyWithPlaceholder(),
    Object? exercises = const $CopyWithPlaceholder(),
  }) {
    return ScheduleProposalItemResponse(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      sortOrder: sortOrder == const $CopyWithPlaceholder()
          ? _value.sortOrder
          // ignore: cast_nullable_to_non_nullable
          : sortOrder as int?,
      sourceDayId: sourceDayId == const $CopyWithPlaceholder()
          ? _value.sourceDayId
          // ignore: cast_nullable_to_non_nullable
          : sourceDayId as int?,
      scheduledDate: scheduledDate == const $CopyWithPlaceholder()
          ? _value.scheduledDate
          // ignore: cast_nullable_to_non_nullable
          : scheduledDate as DateTime?,
      scheduledTime: scheduledTime == const $CopyWithPlaceholder()
          ? _value.scheduledTime
          // ignore: cast_nullable_to_non_nullable
          : scheduledTime as String?,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      appliedScheduleId: appliedScheduleId == const $CopyWithPlaceholder()
          ? _value.appliedScheduleId
          // ignore: cast_nullable_to_non_nullable
          : appliedScheduleId as int?,
      exercises: exercises == const $CopyWithPlaceholder()
          ? _value.exercises
          // ignore: cast_nullable_to_non_nullable
          : exercises as List<ScheduleExercisePlan>?,
    );
  }
}

extension $ScheduleProposalItemResponseCopyWith
    on ScheduleProposalItemResponse {
  /// Returns a callable class that can be used as follows: `instanceOfScheduleProposalItemResponse.copyWith(...)` or like so:`instanceOfScheduleProposalItemResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ScheduleProposalItemResponseCWProxy get copyWith =>
      _$ScheduleProposalItemResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduleProposalItemResponse _$ScheduleProposalItemResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ScheduleProposalItemResponse', json, ($checkedConvert) {
  final val = ScheduleProposalItemResponse(
    id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
    sortOrder: $checkedConvert('sortOrder', (v) => (v as num?)?.toInt()),
    sourceDayId: $checkedConvert('sourceDayId', (v) => (v as num?)?.toInt()),
    scheduledDate: $checkedConvert(
      'scheduledDate',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    scheduledTime: $checkedConvert('scheduledTime', (v) => v as String?),
    title: $checkedConvert('title', (v) => v as String?),
    appliedScheduleId: $checkedConvert(
      'appliedScheduleId',
      (v) => (v as num?)?.toInt(),
    ),
    exercises: $checkedConvert(
      'exercises',
      (v) => (v as List<dynamic>?)
          ?.map((e) => ScheduleExercisePlan.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$ScheduleProposalItemResponseToJson(
  ScheduleProposalItemResponse instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'sortOrder': ?instance.sortOrder,
  'sourceDayId': ?instance.sourceDayId,
  'scheduledDate': ?instance.scheduledDate?.toIso8601String(),
  'scheduledTime': ?instance.scheduledTime,
  'title': ?instance.title,
  'appliedScheduleId': ?instance.appliedScheduleId,
  'exercises': ?instance.exercises?.map((e) => e.toJson()).toList(),
};
