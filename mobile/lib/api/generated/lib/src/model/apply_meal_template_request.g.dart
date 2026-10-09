// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apply_meal_template_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApplyMealTemplateRequestCWProxy {
  ApplyMealTemplateRequest targetDate(DateTime targetDate);

  ApplyMealTemplateRequest mode(String? mode);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApplyMealTemplateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApplyMealTemplateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ApplyMealTemplateRequest call({DateTime targetDate, String? mode});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApplyMealTemplateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApplyMealTemplateRequest.copyWith.fieldName(...)`
class _$ApplyMealTemplateRequestCWProxyImpl
    implements _$ApplyMealTemplateRequestCWProxy {
  const _$ApplyMealTemplateRequestCWProxyImpl(this._value);

  final ApplyMealTemplateRequest _value;

  @override
  ApplyMealTemplateRequest targetDate(DateTime targetDate) =>
      this(targetDate: targetDate);

  @override
  ApplyMealTemplateRequest mode(String? mode) => this(mode: mode);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApplyMealTemplateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApplyMealTemplateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ApplyMealTemplateRequest call({
    Object? targetDate = const $CopyWithPlaceholder(),
    Object? mode = const $CopyWithPlaceholder(),
  }) {
    return ApplyMealTemplateRequest(
      targetDate: targetDate == const $CopyWithPlaceholder()
          ? _value.targetDate
          // ignore: cast_nullable_to_non_nullable
          : targetDate as DateTime,
      mode: mode == const $CopyWithPlaceholder()
          ? _value.mode
          // ignore: cast_nullable_to_non_nullable
          : mode as String?,
    );
  }
}

extension $ApplyMealTemplateRequestCopyWith on ApplyMealTemplateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfApplyMealTemplateRequest.copyWith(...)` or like so:`instanceOfApplyMealTemplateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApplyMealTemplateRequestCWProxy get copyWith =>
      _$ApplyMealTemplateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApplyMealTemplateRequest _$ApplyMealTemplateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApplyMealTemplateRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['targetDate']);
  final val = ApplyMealTemplateRequest(
    targetDate: $checkedConvert(
      'targetDate',
      (v) => DateTime.parse(v as String),
    ),
    mode: $checkedConvert('mode', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$ApplyMealTemplateRequestToJson(
  ApplyMealTemplateRequest instance,
) => <String, dynamic>{
  'targetDate': instance.targetDate.toIso8601String(),
  'mode': ?instance.mode,
};
