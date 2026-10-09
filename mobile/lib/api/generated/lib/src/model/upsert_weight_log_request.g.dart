// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upsert_weight_log_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpsertWeightLogRequestCWProxy {
  UpsertWeightLogRequest weightKg(num weightKg);

  UpsertWeightLogRequest note(String? note);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpsertWeightLogRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpsertWeightLogRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpsertWeightLogRequest call({num weightKg, String? note});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUpsertWeightLogRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUpsertWeightLogRequest.copyWith.fieldName(...)`
class _$UpsertWeightLogRequestCWProxyImpl
    implements _$UpsertWeightLogRequestCWProxy {
  const _$UpsertWeightLogRequestCWProxyImpl(this._value);

  final UpsertWeightLogRequest _value;

  @override
  UpsertWeightLogRequest weightKg(num weightKg) => this(weightKg: weightKg);

  @override
  UpsertWeightLogRequest note(String? note) => this(note: note);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpsertWeightLogRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpsertWeightLogRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpsertWeightLogRequest call({
    Object? weightKg = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
  }) {
    return UpsertWeightLogRequest(
      weightKg: weightKg == const $CopyWithPlaceholder()
          ? _value.weightKg
          // ignore: cast_nullable_to_non_nullable
          : weightKg as num,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
    );
  }
}

extension $UpsertWeightLogRequestCopyWith on UpsertWeightLogRequest {
  /// Returns a callable class that can be used as follows: `instanceOfUpsertWeightLogRequest.copyWith(...)` or like so:`instanceOfUpsertWeightLogRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpsertWeightLogRequestCWProxy get copyWith =>
      _$UpsertWeightLogRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpsertWeightLogRequest _$UpsertWeightLogRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UpsertWeightLogRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['weightKg']);
  final val = UpsertWeightLogRequest(
    weightKg: $checkedConvert('weightKg', (v) => v as num),
    note: $checkedConvert('note', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$UpsertWeightLogRequestToJson(
  UpsertWeightLogRequest instance,
) => <String, dynamic>{'weightKg': instance.weightKg, 'note': ?instance.note};
