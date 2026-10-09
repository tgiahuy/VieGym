// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DashboardResponseCWProxy {
  DashboardResponse date(DateTime? date);

  DashboardResponse nutrition(NutritionSection? nutrition);

  DashboardResponse workout(WorkoutSection? workout);

  DashboardResponse body(BodySection? body);

  DashboardResponse recommendations(List<Object>? recommendations);

  DashboardResponse missingData(List<String>? missingData);

  DashboardResponse generatedAt(DateTime? generatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DashboardResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DashboardResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  DashboardResponse call({
    DateTime? date,
    NutritionSection? nutrition,
    WorkoutSection? workout,
    BodySection? body,
    List<Object>? recommendations,
    List<String>? missingData,
    DateTime? generatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDashboardResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDashboardResponse.copyWith.fieldName(...)`
class _$DashboardResponseCWProxyImpl implements _$DashboardResponseCWProxy {
  const _$DashboardResponseCWProxyImpl(this._value);

  final DashboardResponse _value;

  @override
  DashboardResponse date(DateTime? date) => this(date: date);

  @override
  DashboardResponse nutrition(NutritionSection? nutrition) =>
      this(nutrition: nutrition);

  @override
  DashboardResponse workout(WorkoutSection? workout) => this(workout: workout);

  @override
  DashboardResponse body(BodySection? body) => this(body: body);

  @override
  DashboardResponse recommendations(List<Object>? recommendations) =>
      this(recommendations: recommendations);

  @override
  DashboardResponse missingData(List<String>? missingData) =>
      this(missingData: missingData);

  @override
  DashboardResponse generatedAt(DateTime? generatedAt) =>
      this(generatedAt: generatedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DashboardResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DashboardResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  DashboardResponse call({
    Object? date = const $CopyWithPlaceholder(),
    Object? nutrition = const $CopyWithPlaceholder(),
    Object? workout = const $CopyWithPlaceholder(),
    Object? body = const $CopyWithPlaceholder(),
    Object? recommendations = const $CopyWithPlaceholder(),
    Object? missingData = const $CopyWithPlaceholder(),
    Object? generatedAt = const $CopyWithPlaceholder(),
  }) {
    return DashboardResponse(
      date: date == const $CopyWithPlaceholder()
          ? _value.date
          // ignore: cast_nullable_to_non_nullable
          : date as DateTime?,
      nutrition: nutrition == const $CopyWithPlaceholder()
          ? _value.nutrition
          // ignore: cast_nullable_to_non_nullable
          : nutrition as NutritionSection?,
      workout: workout == const $CopyWithPlaceholder()
          ? _value.workout
          // ignore: cast_nullable_to_non_nullable
          : workout as WorkoutSection?,
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as BodySection?,
      recommendations: recommendations == const $CopyWithPlaceholder()
          ? _value.recommendations
          // ignore: cast_nullable_to_non_nullable
          : recommendations as List<Object>?,
      missingData: missingData == const $CopyWithPlaceholder()
          ? _value.missingData
          // ignore: cast_nullable_to_non_nullable
          : missingData as List<String>?,
      generatedAt: generatedAt == const $CopyWithPlaceholder()
          ? _value.generatedAt
          // ignore: cast_nullable_to_non_nullable
          : generatedAt as DateTime?,
    );
  }
}

extension $DashboardResponseCopyWith on DashboardResponse {
  /// Returns a callable class that can be used as follows: `instanceOfDashboardResponse.copyWith(...)` or like so:`instanceOfDashboardResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DashboardResponseCWProxy get copyWith =>
      _$DashboardResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardResponse _$DashboardResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DashboardResponse', json, ($checkedConvert) {
  final val = DashboardResponse(
    date: $checkedConvert(
      'date',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    nutrition: $checkedConvert(
      'nutrition',
      (v) => v == null
          ? null
          : NutritionSection.fromJson(v as Map<String, dynamic>),
    ),
    workout: $checkedConvert(
      'workout',
      (v) =>
          v == null ? null : WorkoutSection.fromJson(v as Map<String, dynamic>),
    ),
    body: $checkedConvert(
      'body',
      (v) => v == null ? null : BodySection.fromJson(v as Map<String, dynamic>),
    ),
    recommendations: $checkedConvert(
      'recommendations',
      (v) => (v as List<dynamic>?)?.map((e) => e as Object).toList(),
    ),
    missingData: $checkedConvert(
      'missingData',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    generatedAt: $checkedConvert(
      'generatedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
  );
  return val;
});

Map<String, dynamic> _$DashboardResponseToJson(DashboardResponse instance) =>
    <String, dynamic>{
      'date': ?instance.date?.toIso8601String(),
      'nutrition': ?instance.nutrition?.toJson(),
      'workout': ?instance.workout?.toJson(),
      'body': ?instance.body?.toJson(),
      'recommendations': ?instance.recommendations,
      'missingData': ?instance.missingData,
      'generatedAt': ?instance.generatedAt?.toIso8601String(),
    };
