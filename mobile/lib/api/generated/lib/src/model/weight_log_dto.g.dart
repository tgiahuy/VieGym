// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_log_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeightLogDtoCWProxy {
  WeightLogDto id(int? id);

  WeightLogDto loggedDate(DateTime? loggedDate);

  WeightLogDto weightKg(num? weightKg);

  WeightLogDto note(String? note);

  WeightLogDto createdAt(DateTime? createdAt);

  WeightLogDto updatedAt(DateTime? updatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightLogDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightLogDto(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightLogDto call({
    int? id,
    DateTime? loggedDate,
    num? weightKg,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeightLogDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeightLogDto.copyWith.fieldName(...)`
class _$WeightLogDtoCWProxyImpl implements _$WeightLogDtoCWProxy {
  const _$WeightLogDtoCWProxyImpl(this._value);

  final WeightLogDto _value;

  @override
  WeightLogDto id(int? id) => this(id: id);

  @override
  WeightLogDto loggedDate(DateTime? loggedDate) => this(loggedDate: loggedDate);

  @override
  WeightLogDto weightKg(num? weightKg) => this(weightKg: weightKg);

  @override
  WeightLogDto note(String? note) => this(note: note);

  @override
  WeightLogDto createdAt(DateTime? createdAt) => this(createdAt: createdAt);

  @override
  WeightLogDto updatedAt(DateTime? updatedAt) => this(updatedAt: updatedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightLogDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightLogDto(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightLogDto call({
    Object? id = const $CopyWithPlaceholder(),
    Object? loggedDate = const $CopyWithPlaceholder(),
    Object? weightKg = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return WeightLogDto(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      loggedDate: loggedDate == const $CopyWithPlaceholder()
          ? _value.loggedDate
          // ignore: cast_nullable_to_non_nullable
          : loggedDate as DateTime?,
      weightKg: weightKg == const $CopyWithPlaceholder()
          ? _value.weightKg
          // ignore: cast_nullable_to_non_nullable
          : weightKg as num?,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime?,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime?,
    );
  }
}

extension $WeightLogDtoCopyWith on WeightLogDto {
  /// Returns a callable class that can be used as follows: `instanceOfWeightLogDto.copyWith(...)` or like so:`instanceOfWeightLogDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeightLogDtoCWProxy get copyWith => _$WeightLogDtoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightLogDto _$WeightLogDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WeightLogDto', json, ($checkedConvert) {
      final val = WeightLogDto(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        loggedDate: $checkedConvert(
          'loggedDate',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        weightKg: $checkedConvert('weightKg', (v) => v as num?),
        note: $checkedConvert('note', (v) => v as String?),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        updatedAt: $checkedConvert(
          'updatedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$WeightLogDtoToJson(WeightLogDto instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'loggedDate': ?instance.loggedDate?.toIso8601String(),
      'weightKg': ?instance.weightKg,
      'note': ?instance.note,
      'createdAt': ?instance.createdAt?.toIso8601String(),
      'updatedAt': ?instance.updatedAt?.toIso8601String(),
    };
