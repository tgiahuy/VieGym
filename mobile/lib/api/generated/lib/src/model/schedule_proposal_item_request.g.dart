// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_proposal_item_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ScheduleProposalItemRequestCWProxy {
  ScheduleProposalItemRequest scheduledDate(DateTime? scheduledDate);

  ScheduleProposalItemRequest scheduledTime(String? scheduledTime);

  ScheduleProposalItemRequest title(String? title);

  ScheduleProposalItemRequest exercises(List<ScheduleExercisePlan>? exercises);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ScheduleProposalItemRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ScheduleProposalItemRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ScheduleProposalItemRequest call({
    DateTime? scheduledDate,
    String? scheduledTime,
    String? title,
    List<ScheduleExercisePlan>? exercises,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfScheduleProposalItemRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfScheduleProposalItemRequest.copyWith.fieldName(...)`
class _$ScheduleProposalItemRequestCWProxyImpl
    implements _$ScheduleProposalItemRequestCWProxy {
  const _$ScheduleProposalItemRequestCWProxyImpl(this._value);

  final ScheduleProposalItemRequest _value;

  @override
  ScheduleProposalItemRequest scheduledDate(DateTime? scheduledDate) =>
      this(scheduledDate: scheduledDate);

  @override
  ScheduleProposalItemRequest scheduledTime(String? scheduledTime) =>
      this(scheduledTime: scheduledTime);

  @override
  ScheduleProposalItemRequest title(String? title) => this(title: title);

  @override
  ScheduleProposalItemRequest exercises(
    List<ScheduleExercisePlan>? exercises,
  ) => this(exercises: exercises);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ScheduleProposalItemRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ScheduleProposalItemRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ScheduleProposalItemRequest call({
    Object? scheduledDate = const $CopyWithPlaceholder(),
    Object? scheduledTime = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? exercises = const $CopyWithPlaceholder(),
  }) {
    return ScheduleProposalItemRequest(
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
      exercises: exercises == const $CopyWithPlaceholder()
          ? _value.exercises
          // ignore: cast_nullable_to_non_nullable
          : exercises as List<ScheduleExercisePlan>?,
    );
  }
}

extension $ScheduleProposalItemRequestCopyWith on ScheduleProposalItemRequest {
  /// Returns a callable class that can be used as follows: `instanceOfScheduleProposalItemRequest.copyWith(...)` or like so:`instanceOfScheduleProposalItemRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ScheduleProposalItemRequestCWProxy get copyWith =>
      _$ScheduleProposalItemRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduleProposalItemRequest _$ScheduleProposalItemRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ScheduleProposalItemRequest', json, ($checkedConvert) {
  final val = ScheduleProposalItemRequest(
    scheduledDate: $checkedConvert(
      'scheduledDate',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    scheduledTime: $checkedConvert('scheduledTime', (v) => v as String?),
    title: $checkedConvert('title', (v) => v as String?),
    exercises: $checkedConvert(
      'exercises',
      (v) => (v as List<dynamic>?)
          ?.map((e) => ScheduleExercisePlan.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$ScheduleProposalItemRequestToJson(
  ScheduleProposalItemRequest instance,
) => <String, dynamic>{
  'scheduledDate': ?instance.scheduledDate?.toIso8601String(),
  'scheduledTime': ?instance.scheduledTime,
  'title': ?instance.title,
  'exercises': ?instance.exercises?.map((e) => e.toJson()).toList(),
};
