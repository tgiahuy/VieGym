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
}
