// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apply_schedule_proposal_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApplyScheduleProposalResponseCWProxy {
  ApplyScheduleProposalResponse proposalId(int? proposalId);

  ApplyScheduleProposalResponse status(String? status);

  ApplyScheduleProposalResponse schedules(
    List<WorkoutScheduleResponse>? schedules,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApplyScheduleProposalResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApplyScheduleProposalResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApplyScheduleProposalResponse call({
    int? proposalId,
    String? status,
    List<WorkoutScheduleResponse>? schedules,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApplyScheduleProposalResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApplyScheduleProposalResponse.copyWith.fieldName(...)`
class _$ApplyScheduleProposalResponseCWProxyImpl
    implements _$ApplyScheduleProposalResponseCWProxy {
  const _$ApplyScheduleProposalResponseCWProxyImpl(this._value);

  final ApplyScheduleProposalResponse _value;

  @override
  ApplyScheduleProposalResponse proposalId(int? proposalId) =>
      this(proposalId: proposalId);

  @override
  ApplyScheduleProposalResponse status(String? status) => this(status: status);

  @override
  ApplyScheduleProposalResponse schedules(
    List<WorkoutScheduleResponse>? schedules,
  ) => this(schedules: schedules);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApplyScheduleProposalResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApplyScheduleProposalResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ApplyScheduleProposalResponse call({
    Object? proposalId = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? schedules = const $CopyWithPlaceholder(),
  }) {
    return ApplyScheduleProposalResponse(
      proposalId: proposalId == const $CopyWithPlaceholder()
          ? _value.proposalId
          // ignore: cast_nullable_to_non_nullable
          : proposalId as int?,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String?,
      schedules: schedules == const $CopyWithPlaceholder()
          ? _value.schedules
          // ignore: cast_nullable_to_non_nullable
          : schedules as List<WorkoutScheduleResponse>?,
    );
  }
}

extension $ApplyScheduleProposalResponseCopyWith
    on ApplyScheduleProposalResponse {
  /// Returns a callable class that can be used as follows: `instanceOfApplyScheduleProposalResponse.copyWith(...)` or like so:`instanceOfApplyScheduleProposalResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApplyScheduleProposalResponseCWProxy get copyWith =>
      _$ApplyScheduleProposalResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApplyScheduleProposalResponse _$ApplyScheduleProposalResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApplyScheduleProposalResponse', json, ($checkedConvert) {
  final val = ApplyScheduleProposalResponse(
    proposalId: $checkedConvert('proposalId', (v) => (v as num?)?.toInt()),
    status: $checkedConvert('status', (v) => v as String?),
    schedules: $checkedConvert(
      'schedules',
      (v) => (v as List<dynamic>?)
          ?.map(
            (e) => WorkoutScheduleResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$ApplyScheduleProposalResponseToJson(
  ApplyScheduleProposalResponse instance,
) => <String, dynamic>{
  'proposalId': ?instance.proposalId,
  'status': ?instance.status,
  'schedules': ?instance.schedules?.map((e) => e.toJson()).toList(),
};
