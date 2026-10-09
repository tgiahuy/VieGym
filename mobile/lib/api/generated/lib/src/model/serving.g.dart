// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serving.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ServingCWProxy {
  Serving amount(num? amount);

  Serving unit(String? unit);

  Serving gramsPerServing(num? gramsPerServing);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Serving(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Serving(...).copyWith(id: 12, name: "My name")
  /// ````
  Serving call({num? amount, String? unit, num? gramsPerServing});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfServing.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfServing.copyWith.fieldName(...)`
class _$ServingCWProxyImpl implements _$ServingCWProxy {
  const _$ServingCWProxyImpl(this._value);

  final Serving _value;

  @override
  Serving amount(num? amount) => this(amount: amount);

  @override
  Serving unit(String? unit) => this(unit: unit);

  @override
  Serving gramsPerServing(num? gramsPerServing) =>
      this(gramsPerServing: gramsPerServing);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Serving(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Serving(...).copyWith(id: 12, name: "My name")
  /// ````
  Serving call({
    Object? amount = const $CopyWithPlaceholder(),
    Object? unit = const $CopyWithPlaceholder(),
    Object? gramsPerServing = const $CopyWithPlaceholder(),
  }) {
    return Serving(
      amount: amount == const $CopyWithPlaceholder()
          ? _value.amount
          // ignore: cast_nullable_to_non_nullable
          : amount as num?,
      unit: unit == const $CopyWithPlaceholder()
          ? _value.unit
          // ignore: cast_nullable_to_non_nullable
          : unit as String?,
      gramsPerServing: gramsPerServing == const $CopyWithPlaceholder()
          ? _value.gramsPerServing
          // ignore: cast_nullable_to_non_nullable
          : gramsPerServing as num?,
    );
  }
}

extension $ServingCopyWith on Serving {
  /// Returns a callable class that can be used as follows: `instanceOfServing.copyWith(...)` or like so:`instanceOfServing.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ServingCWProxy get copyWith => _$ServingCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Serving _$ServingFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Serving', json, ($checkedConvert) {
      final val = Serving(
        amount: $checkedConvert('amount', (v) => v as num?),
        unit: $checkedConvert('unit', (v) => v as String?),
        gramsPerServing: $checkedConvert('gramsPerServing', (v) => v as num?),
      );
      return val;
    });

Map<String, dynamic> _$ServingToJson(Serving instance) => <String, dynamic>{
  'amount': ?instance.amount,
  'unit': ?instance.unit,
  'gramsPerServing': ?instance.gramsPerServing,
};
