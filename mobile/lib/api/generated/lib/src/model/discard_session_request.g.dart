// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discard_session_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DiscardSessionRequestCWProxy {
  DiscardSessionRequest reason(String? reason);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DiscardSessionRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DiscardSessionRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  DiscardSessionRequest call({String? reason});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDiscardSessionRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDiscardSessionRequest.copyWith.fieldName(...)`
class _$DiscardSessionRequestCWProxyImpl
    implements _$DiscardSessionRequestCWProxy {
  const _$DiscardSessionRequestCWProxyImpl(this._value);

  final DiscardSessionRequest _value;

  @override
  DiscardSessionRequest reason(String? reason) => this(reason: reason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DiscardSessionRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DiscardSessionRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  DiscardSessionRequest call({Object? reason = const $CopyWithPlaceholder()}) {
    return DiscardSessionRequest(
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String?,
    );
  }
}

extension $DiscardSessionRequestCopyWith on DiscardSessionRequest {
  /// Returns a callable class that can be used as follows: `instanceOfDiscardSessionRequest.copyWith(...)` or like so:`instanceOfDiscardSessionRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DiscardSessionRequestCWProxy get copyWith =>
      _$DiscardSessionRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiscardSessionRequest _$DiscardSessionRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DiscardSessionRequest', json, ($checkedConvert) {
  final val = DiscardSessionRequest(
    reason: $checkedConvert('reason', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$DiscardSessionRequestToJson(
  DiscardSessionRequest instance,
) => <String, dynamic>{'reason': ?instance.reason};
