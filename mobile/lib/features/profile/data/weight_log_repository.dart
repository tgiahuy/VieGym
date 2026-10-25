import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../application/progress_controller.dart';

final weightLogRepositoryProvider = Provider<WeightLogRepository>((ref) {
  return WeightLogRepository(ref.watch(dioProvider));
});

class UpsertWeightLogResult {
  const UpsertWeightLogResult({
    required this.weightLog,
    required this.metricsUpdated,
    this.bmi,
    this.bmrKcal,
    this.tdeeKcal,
  });

  final WeightLogItem weightLog;
  final bool metricsUpdated;
  final double? bmi;
  final int? bmrKcal;
  final int? tdeeKcal;
}

class WeightLogRepository {
  const WeightLogRepository(this._dio);

  final Dio _dio;

  static String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Future<UpsertWeightLogResult> upsertWeightLog(
    DateTime date,
    double weightKg, {
    String? note,
  }) async {
    final dateStr = _formatDate(date);
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/v1/weight-logs/$dateStr',
      data: {
        'weightKg': weightKg,
        if (note != null && note.isNotEmpty) 'note': note,
      },
    );

    final body = response.data;
    final data = body?['data'] as Map<String, dynamic>? ?? {};
    final logMap = data['weightLog'] as Map<String, dynamic>? ?? {};
    final metricsUpdated = data['metricsUpdated'] as bool? ?? false;
    final metricsMap = data['metrics'] as Map<String, dynamic>?;

    final id =
        logMap['id']?.toString() ??
        'w_${DateTime.now().millisecondsSinceEpoch}';
    final loggedDateStr = logMap['loggedDate'] as String? ?? dateStr;

    String displayDate =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
    try {
      final parsedDate = DateTime.parse(loggedDateStr);
      displayDate =
          '${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}';
    } catch (_) {}

    final weight = (logMap['weightKg'] as num?)?.toDouble() ?? weightKg;
    final bmi = (metricsMap?['bmi'] as num?)?.toDouble();
    final bmr = (metricsMap?['bmrKcal'] as num?)?.toInt();
    final tdee = (metricsMap?['tdeeKcal'] as num?)?.toInt();

    return UpsertWeightLogResult(
      weightLog: WeightLogItem(
        id: id,
        date: displayDate,
        weightKg: weight,
      ),
      metricsUpdated: metricsUpdated,
      bmi: bmi,
      bmrKcal: bmr,
      tdeeKcal: tdee,
    );
  }

  Future<List<WeightLogItem>> getWeightLogs({
    DateTime? from,
    DateTime? to,
    int page = 0,
    int size = 30,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      if (from != null) 'from': _formatDate(from),
      if (to != null) 'to': _formatDate(to),
    };

    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/weight-logs',
      queryParameters: queryParams,
    );

    final body = response.data;
    final data = body?['data'] as Map<String, dynamic>? ?? {};
    final content = data['content'] as List<dynamic>? ?? [];

    return content.map((item) {
      final map = item as Map<String, dynamic>;
      final id = map['id']?.toString() ?? '';
      final loggedDateStr = map['loggedDate'] as String? ?? '';
      String displayDate = loggedDateStr;
      try {
        final parsed = DateTime.parse(loggedDateStr);
        displayDate =
            '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}';
      } catch (_) {}
      final weight = (map['weightKg'] as num?)?.toDouble() ?? 0.0;
      return WeightLogItem(
        id: id,
        date: displayDate,
        weightKg: weight,
      );
    }).toList();
  }

  Future<WeightTrendResult> getWeightTrend({int days = 30}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/weight-logs/trend',
      queryParameters: {'days': days},
    );

    final body = response.data;
    final data = body?['data'] as Map<String, dynamic>? ?? {};
    final pointsList = data['points'] as List<dynamic>? ?? [];

    final points = pointsList.map((p) {
      final map = p as Map<String, dynamic>;
      final dateStr = map['date'] as String? ?? '';
      final weight = (map['weightKg'] as num?)?.toDouble() ?? 0.0;
      return WeightTrendPointItem(
        date: DateTime.tryParse(dateStr) ?? DateTime.now(),
        weightKg: weight,
      );
    }).toList();

    return WeightTrendResult(
      days: (data['days'] as num?)?.toInt() ?? days,
      from: DateTime.tryParse(data['from'] as String? ?? ''),
      to: DateTime.tryParse(data['to'] as String? ?? ''),
      startWeightKg: (data['startWeightKg'] as num?)?.toDouble(),
      currentWeightKg: (data['currentWeightKg'] as num?)?.toDouble(),
      changeKg: (data['changeKg'] as num?)?.toDouble() ?? 0.0,
      direction: data['direction'] as String? ?? 'STABLE',
      sufficientData: data['sufficientData'] as bool? ?? false,
      points: points,
    );
  }

  Future<List<PersonalRecordItem>> getPersonalRecords() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/personal-records',
      queryParameters: {'size': 50},
    );

    final body = response.data;
    final data = body?['data'] as Map<String, dynamic>? ?? {};
    final content = data['content'] as List<dynamic>? ?? [];

    return content.map((item) {
      final map = item as Map<String, dynamic>;
      final id = map['id']?.toString() ?? '';
      final name = map['exerciseName'] as String? ?? '';
      final val = (map['value'] as num?)?.toDouble() ?? 0.0;
      final achievedAtStr = map['achievedAt'] as String? ?? '';
      String displayDate = '';
      try {
        final parsed = DateTime.parse(achievedAtStr);
        displayDate =
            '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}';
      } catch (_) {}

      return PersonalRecordItem(
        id: id,
        exerciseName: name,
        weightKg: val,
        reps: 1,
        date: displayDate,
      );
    }).toList();
  }

  Future<List<WorkoutLogServerItem>> getWorkoutLogs({
    DateTime? from,
    DateTime? to,
    int page = 0,
    int size = 50,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      if (from != null) 'from': _formatDate(from),
      if (to != null) 'to': _formatDate(to),
    };

    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/workout-logs',
      queryParameters: queryParams,
    );

    final body = response.data;
    final data = body?['data'] as Map<String, dynamic>? ?? {};
    final content = data['content'] as List<dynamic>? ?? [];

    return content.map((item) {
      final map = item as Map<String, dynamic>;
      final id = (map['id'] as num?)?.toInt() ?? 0;
      final title = map['title'] as String? ?? 'Buổi tập';
      final completedAtStr = map['completedAt'] as String? ?? '';
      final completedAt = DateTime.tryParse(completedAtStr) ?? DateTime.now();
      final durationSeconds = (map['durationSeconds'] as num?)?.toInt() ?? 0;
      final totalVolumeKg = (map['totalVolumeKg'] as num?)?.toDouble() ?? 0.0;
      final totalExercises = (map['totalExercises'] as num?)?.toInt() ?? 0;
      final prCount = (map['prCount'] as num?)?.toInt() ?? 0;

      return WorkoutLogServerItem(
        id: id,
        title: title,
        completedAt: completedAt,
        durationMinutes: durationSeconds ~/ 60,
        totalVolumeKg: totalVolumeKg,
        totalExercises: totalExercises,
        prCount: prCount,
      );
    }).toList();
  }
}

class WeightTrendPointItem {
  const WeightTrendPointItem({
    required this.date,
    required this.weightKg,
  });

  final DateTime date;
  final double weightKg;
}

class WeightTrendResult {
  const WeightTrendResult({
    required this.days,
    required this.from,
    required this.to,
    this.startWeightKg,
    this.currentWeightKg,
    this.changeKg = 0.0,
    this.direction = 'STABLE',
    this.sufficientData = false,
    this.points = const [],
  });

  final int days;
  final DateTime? from;
  final DateTime? to;
  final double? startWeightKg;
  final double? currentWeightKg;
  final double changeKg;
  final String direction;
  final bool sufficientData;
  final List<WeightTrendPointItem> points;
}

class WorkoutLogServerItem {
  const WorkoutLogServerItem({
    required this.id,
    required this.title,
    required this.completedAt,
    required this.durationMinutes,
    required this.totalVolumeKg,
    required this.totalExercises,
    required this.prCount,
  });

  final int id;
  final String title;
  final DateTime completedAt;
  final int durationMinutes;
  final double totalVolumeKg;
  final int totalExercises;
  final int prCount;
}
