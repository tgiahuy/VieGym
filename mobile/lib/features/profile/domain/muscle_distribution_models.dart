import '../../workout/domain/muscle_models.dart';

enum TimeframeFilter {
  sevenDays('7 ngày', 7),
  thirtyDays('30 ngày', 30),
  threeMonths('3 tháng', 90);

  const TimeframeFilter(this.label, this.days);
  final String label;
  final int days;
}

class MuscleDistributionItem {
  const MuscleDistributionItem({
    required this.muscleGroup,
    required this.nameVi,
    required this.volumeKg,
    required this.percentage,
    required this.bodySide,
    this.daysAgo,
  });

  final MuscleGroup muscleGroup;
  final String nameVi;
  final double volumeKg;
  final int percentage;
  final BodySide bodySide;
  final int? daysAgo;

  MuscleDistributionItem copyWith({
    MuscleGroup? muscleGroup,
    String? nameVi,
    double? volumeKg,
    int? percentage,
    BodySide? bodySide,
    int? daysAgo,
  }) {
    return MuscleDistributionItem(
      muscleGroup: muscleGroup ?? this.muscleGroup,
      nameVi: nameVi ?? this.nameVi,
      volumeKg: volumeKg ?? this.volumeKg,
      percentage: percentage ?? this.percentage,
      bodySide: bodySide ?? this.bodySide,
      daysAgo: daysAgo ?? this.daysAgo,
    );
  }
}

class MuscleDistributionState {
  const MuscleDistributionState({
    required this.timeframe,
    required this.bodySide,
    this.selectedMuscle,
    required this.items,
    required this.totalVolumeKg,
  });

  final TimeframeFilter timeframe;
  final BodySide bodySide;
  final MuscleGroup? selectedMuscle;
  final Map<MuscleGroup, MuscleDistributionItem> items;
  final double totalVolumeKg;

  Map<MuscleGroup, double> get muscleIntensities {
    final result = <MuscleGroup, double>{};
    for (final entry in items.entries) {
      // Percentage to normalized intensity ratio (0.0 - 1.0)
      result[entry.key] = entry.value.percentage / 100.0;
    }
    return result;
  }

  MuscleDistributionState copyWith({
    TimeframeFilter? timeframe,
    BodySide? bodySide,
    MuscleGroup? selectedMuscle,
    bool clearSelectedMuscle = false,
    Map<MuscleGroup, MuscleDistributionItem>? items,
    double? totalVolumeKg,
  }) {
    return MuscleDistributionState(
      timeframe: timeframe ?? this.timeframe,
      bodySide: bodySide ?? this.bodySide,
      selectedMuscle: clearSelectedMuscle
          ? null
          : (selectedMuscle ?? this.selectedMuscle),
      items: items ?? this.items,
      totalVolumeKg: totalVolumeKg ?? this.totalVolumeKg,
    );
  }
}
