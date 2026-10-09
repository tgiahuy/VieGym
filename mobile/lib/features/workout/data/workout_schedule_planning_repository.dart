import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error_handler.dart';
import '../../../core/network/dio_provider.dart';
import '../data/exercise_catalog.dart';
import '../domain/workout_models.dart';

final workoutSchedulePlanningRepositoryProvider =
    Provider<WorkoutSchedulePlanningRepository>((ref) {
      return WorkoutSchedulePlanningRepository(ref.watch(dioProvider));
    });

class WorkoutSchedulePlanningRepository {
  const WorkoutSchedulePlanningRepository(this._dio);

  final Dio _dio;

  Future<List<WorkoutPlanSource>> loadPersonalPrograms() async {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/workout-programs',
        queryParameters: const {'page': 0, 'size': 50},
      );
      final page = response.data?['data'] as Map<String, dynamic>? ?? const {};
      final rows = page['content'] as List<dynamic>? ?? const [];
      return rows
          .whereType<Map<String, dynamic>>()
          .map(
            (row) => WorkoutPlanSource(
              id: row['id'] as int,
              name: row['name'] as String? ?? 'Giáo án cá nhân',
              description: row['description'] as String?,
              totalDays: row['totalDays'] as int? ?? 0,
              sourceType: 'USER_PROGRAM',
            ),
          )
          .toList();
    });
  }

  Future<WorkoutPlanSource> createPersonalProgram({
    required String name,
    required String programType,
    String? description,
    required List<ScheduleDraftDay> days,
  }) async {
    return _guard(() async {
      final resolvedDays = <Map<String, dynamic>>[];
      for (var dayIdx = 0; dayIdx < days.length; dayIdx++) {
        final day = days[dayIdx];
        final exercises = <Map<String, dynamic>>[];
        for (var index = 0; index < day.exercises.length; index++) {
          final draft = day.exercises[index];
          exercises.add({
            'exerciseId': await _resolveExerciseId(draft.exercise),
            'sortOrder': index + 1,
            'targetSets': draft.targetSets,
            'targetRepsMin': draft.targetRepsMin,
            'targetRepsMax': draft.targetRepsMax,
            'restSeconds': draft.restSeconds,
          });
        }
        resolvedDays.add({
          'dayNumber': dayIdx + 1,
          'name': day.title.isNotEmpty ? day.title : 'Buổi ${dayIdx + 1}',
          'exercises': exercises,
        });
      }

      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/workout-programs',
        data: {
          'name': name,
          'programType': programType,
          'description': description,
          'status': 'ACTIVE',
          'days': resolvedDays,
        },
      );
      final data = response.data?['data'] as Map<String, dynamic>? ?? const {};
      return WorkoutPlanSource(
        id: data['id'] as int? ?? DateTime.now().millisecondsSinceEpoch,
        name: data['name'] as String? ?? name,
        description: data['description'] as String?,
        totalDays: (data['days'] as List<dynamic>?)?.length ?? days.length,
        sourceType: 'USER_PROGRAM',
      );
    });
  }

  Future<List<WorkoutPlanSource>> loadAdminTemplates() async {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/workout-program-templates',
      );
      final rows = response.data?['data'] as List<dynamic>? ?? const [];
      return rows
          .whereType<Map<String, dynamic>>()
          .map(
            (row) => WorkoutPlanSource(
              id: row['id'] as int,
              name: row['name'] as String? ?? 'Giáo án VieGym',
              description: row['description'] as String?,
              totalDays: (row['days'] as List<dynamic>?)?.length ?? 0,
              sourceType: 'ADMIN_TEMPLATE',
            ),
          )
          .toList();
    });
  }

  Future<List<AppliedWorkoutSchedule>> loadSchedules({
    required DateTime from,
    required DateTime to,
  }) async {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/workout-schedules',
        queryParameters: {
          'from': _dateOnly(from),
          'to': _dateOnly(to),
          'page': 0,
          'size': 100,
        },
      );
      final page = response.data?['data'] as Map<String, dynamic>? ?? const {};
      final rows = page['content'] as List<dynamic>? ?? const [];
      return rows
          .whereType<Map<String, dynamic>>()
          .where(
            (row) => (row['status'] as String? ?? 'PLANNED') != 'CANCELLED',
          )
          .map((row) {
            return AppliedWorkoutSchedule(
              id: row['id'] as int,
              date: DateTime.parse(row['scheduledDate'] as String),
              time: row['scheduledTime'] as String? ?? '18:00',
              title: row['title'] as String? ?? 'Buổi tập',
              status: row['status'] as String? ?? 'PLANNED',
              plannedExercises: _plannedExercisesFromJson(row['exercises']),
            );
          })
          .toList();
    });
  }

  Future<void> cancelSchedule(int scheduleId) async {
    return _guard(() async {
      await _dio.delete<dynamic>('/api/v1/workout-schedules/$scheduleId');
    });
  }

  Future<WorkoutPlanSource> loadSourceDetail(WorkoutPlanSource source) async {
    return _guard(() async {
      final path = source.sourceType == 'ADMIN_TEMPLATE'
          ? '/api/v1/workout-program-templates/${source.id}'
          : '/api/v1/workout-programs/${source.id}';
      final response = await _dio.get<Map<String, dynamic>>(path);
      final data = response.data?['data'] as Map<String, dynamic>? ?? const {};
      final rows = data['days'] as List<dynamic>? ?? const [];
      final days = rows.whereType<Map<String, dynamic>>().map((row) {
        final exercises = row['exercises'] as List<dynamic>? ?? const [];
        final parsed = _plannedExercisesFromJson(exercises);
        final name = row['name'] as String? ?? 'Buổi tập';
        final resolvedExercises = parsed.isNotEmpty
            ? parsed
            : (source.sourceType == 'ADMIN_TEMPLATE'
                ? const <PlannedExercisePreview>[]
                : resolveDefaultExercisesForDay(name, source.name));
        return WorkoutPlanDay(
          id: row['id'] as int,
          dayNumber: row['dayNumber'] as int? ?? 1,
          name: name,
          exerciseCount: resolvedExercises.length,
          exercises: resolvedExercises,
        );
      }).toList()..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
      return source.copyWith(days: days, totalDays: days.length);
    });
  }

  Future<ScheduleProposalView> createSourceProposal({
    required WorkoutPlanSource source,
    required List<DateTime> targetDates,
    required String time,
    int? sourceDayId,
  }) async {
    final body = <String, dynamic>{
      'sourceType': source.sourceType,
      'scope': targetDates.length == 1 ? 'ONE_DAY' : 'WEEK',
      'sourceId': source.id,
      'sourceDayId': ?sourceDayId,
      'targetDates': targetDates.map(_dateOnly).toList(),
      'scheduledTime': time,
    };
    return _createProposal(body);
  }

  Future<ScheduleProposalView> createDirectProposal({
    required String sourceType,
    required List<ScheduleDraftDay> days,
  }) async {
    final resolvedDays = <Map<String, dynamic>>[];
    for (final day in days) {
      final exercises = <Map<String, dynamic>>[];
      for (var index = 0; index < day.exercises.length; index++) {
        final draft = day.exercises[index];
        exercises.add({
          'exerciseId': await _resolveExerciseId(draft.exercise),
          'sortOrder': index + 1,
          'targetSets': draft.targetSets,
          'targetRepsMin': draft.targetRepsMin,
          'targetRepsMax': draft.targetRepsMax,
          'restSeconds': draft.restSeconds,
        });
      }
      resolvedDays.add({
        'scheduledDate': _dateOnly(day.date),
        'scheduledTime': day.time,
        'title': day.title,
        'exercises': exercises,
      });
    }
    return _createProposal({
      'sourceType': sourceType,
      'scope': days.length == 1 ? 'ONE_DAY' : 'WEEK',
      'items': resolvedDays,
    });
  }

  Future<List<AppliedWorkoutSchedule>> applyProposal(int proposalId) async {
    return _guard(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/workout-schedule-proposals/$proposalId/apply',
      );
      final data = response.data?['data'] as Map<String, dynamic>? ?? const {};
      final schedules = data['schedules'] as List<dynamic>? ?? const [];
      return schedules.whereType<Map<String, dynamic>>().map((row) {
        return AppliedWorkoutSchedule(
          id: row['id'] as int,
          date: DateTime.parse(row['scheduledDate'] as String),
          time: row['scheduledTime'] as String? ?? '18:00',
          title: row['title'] as String? ?? 'Buổi tập',
          status: row['status'] as String? ?? 'PLANNED',
          plannedExercises: _plannedExercisesFromJson(row['exercises']),
        );
      }).toList();
    });
  }

  Future<ScheduleProposalView> _createProposal(Map<String, dynamic> body) {
    return _guard(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/workout-schedule-proposals',
        data: body,
      );
      final data = response.data?['data'] as Map<String, dynamic>? ?? const {};
      return ScheduleProposalView.fromJson(data);
    });
  }

  Future<int> _resolveExerciseId(ExerciseDefinition exercise) async {
    // 1. Direct numeric or ex_<id> format
    final backendId = RegExp(r'^ex_(\d+)$').firstMatch(exercise.id)?.group(1);
    final direct = int.tryParse(backendId ?? exercise.id);
    if (direct != null && direct > 0) return direct;

    // 2. Multi-term search (name, clean name without parentheses, nameVi)
    final terms = <String>{
      exercise.name.replaceAll(RegExp(r'\(.*?\)'), '').trim(),
      exercise.name.trim(),
      if (exercise.nameVi.isNotEmpty) ...[
        exercise.nameVi.replaceAll(RegExp(r'\(.*?\)'), '').trim(),
        exercise.nameVi.trim(),
      ],
    }.where((s) => s.isNotEmpty).toList();

    for (final term in terms) {
      try {
        final response = await _dio.get<Map<String, dynamic>>(
          '/api/v1/exercises',
          queryParameters: {
            'q': term,
            'page': 0,
            'size': 25,
          },
        );
        final data = response.data?['data'] as Map<String, dynamic>? ?? const {};
        final rows = data['content'] as List<dynamic>? ?? const [];
        final matches = rows.whereType<Map<String, dynamic>>().toList();
        if (matches.isNotEmpty) {
          // Exact match on name, searchName, or slug
          final exact = matches.where((row) {
            final rowName = (row['name'] as String? ?? '').toLowerCase();
            final rowSearchName = (row['searchName'] as String? ?? '').toLowerCase();
            final rowSlug = (row['slug'] as String? ?? '').toLowerCase();
            final targetName = exercise.name.toLowerCase();
            final targetNameVi = exercise.nameVi.toLowerCase();
            final termLower = term.toLowerCase();

            return rowName == targetName ||
                rowName == targetNameVi ||
                rowName == termLower ||
                rowSearchName == targetName ||
                rowSearchName == targetNameVi ||
                rowSearchName == termLower ||
                rowSlug == targetName.replaceAll(' ', '-') ||
                rowSlug == targetNameVi.replaceAll(' ', '-');
          }).firstOrNull;

          if (exact != null) {
            final id = exact['id'] as int?;
            if (id != null && id > 0) return id;
          }

          // Partial / Substring match
          final partial = matches.where((row) {
            final rowName = (row['name'] as String? ?? '').toLowerCase();
            final rowSearchName = (row['searchName'] as String? ?? '').toLowerCase();
            final targetName = exercise.name.toLowerCase();
            final targetNameVi = exercise.nameVi.toLowerCase();
            final termLower = term.toLowerCase();

            return rowName.contains(termLower) ||
                termLower.contains(rowName) ||
                rowName.contains(targetName) ||
                targetName.contains(rowName) ||
                (targetNameVi.isNotEmpty && (rowName.contains(targetNameVi) || targetNameVi.contains(rowName))) ||
                rowSearchName.contains(termLower);
          }).firstOrNull;

          if (partial != null) {
            final id = partial['id'] as int?;
            if (id != null && id > 0) return id;
          }

          // Fallback to first result for this search term
          final id = matches.first['id'] as int?;
          if (id != null && id > 0) return id;
        }
      } catch (_) {
        // Fall through to next term
      }
    }

    // 3. General list lookup
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/exercises',
        queryParameters: const {'page': 0, 'size': 50},
      );
      final data = response.data?['data'] as Map<String, dynamic>? ?? const {};
      final rows = data['content'] as List<dynamic>? ?? const [];
      final matches = rows.whereType<Map<String, dynamic>>().toList();
      for (final row in matches) {
        final rowName = (row['name'] as String? ?? '').toLowerCase();
        if (rowName.contains(exercise.name.toLowerCase()) ||
            exercise.name.toLowerCase().contains(rowName) ||
            (exercise.nameVi.isNotEmpty && rowName.contains(exercise.nameVi.toLowerCase()))) {
          final id = row['id'] as int?;
          if (id != null && id > 0) return id;
        }
      }
      final first = matches.firstOrNull;
      final id = first?['id'] as int?;
      if (id != null && id > 0) return id;
    } catch (_) {
      // Throw below
    }

    throw WorkoutPlanningException(
      'Không tìm thấy bài tập "${exercise.name}" trong thư viện máy chủ.',
    );
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error) {
      throw WorkoutPlanningException(ApiErrorHandler.getMessage(error));
    }
  }

  static List<PlannedExercisePreview> _plannedExercisesFromJson(dynamic value) {
    final rows = value as List<dynamic>? ?? const [];
    return rows
        .whereType<Map<String, dynamic>>()
        .map((exercise) {
          final name = (exercise['exerciseName'] as String?)?.trim() ?? '';
          final sets = exercise['targetSets'] as int? ?? 3;
          final repsMin = exercise['targetRepsMin'] as int?;
          final repsMax = exercise['targetRepsMax'] as int?;
          final duration = exercise['targetDurationSeconds'] as int?;
          final setsReps = duration != null
              ? '${sets}x${duration}s'
              : repsMin != null && repsMax != null && repsMin != repsMax
              ? '${sets}x$repsMin-$repsMax'
              : '${sets}x${repsMin ?? repsMax ?? 10}';

          var muscle = (exercise['primaryMuscle'] as String?)?.trim() ??
              (exercise['primaryMuscleGroup'] as String?)?.trim() ??
              (exercise['muscleGroup'] as String?)?.trim();

          if (muscle == null || muscle.isEmpty) {
            final normalized = name.toLowerCase();
            for (final ex in exerciseCatalog) {
              if (ex.name.toLowerCase() == normalized ||
                  ex.nameVi.toLowerCase() == normalized ||
                  normalized.contains(ex.name.toLowerCase()) ||
                  normalized.contains(ex.nameVi.toLowerCase())) {
                muscle = ex.primaryMuscle;
                break;
              }
            }
          }

          return PlannedExercisePreview(
            name: name,
            setsReps: setsReps,
            primaryMuscle: muscle,
          );
        })
        .where((exercise) => exercise.name.isNotEmpty)
        .toList();
  }

  static String _dateOnly(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class WorkoutPlanSource {
  const WorkoutPlanSource({
    required this.id,
    required this.name,
    required this.totalDays,
    required this.sourceType,
    this.description,
    this.days = const [],
  });

  final int id;
  final String name;
  final String? description;
  final int totalDays;
  final String sourceType;
  final List<WorkoutPlanDay> days;

  WorkoutPlanSource copyWith({int? totalDays, List<WorkoutPlanDay>? days}) {
    return WorkoutPlanSource(
      id: id,
      name: name,
      description: description,
      totalDays: totalDays ?? this.totalDays,
      sourceType: sourceType,
      days: days ?? this.days,
    );
  }
}

class WorkoutPlanDay {
  const WorkoutPlanDay({
    required this.id,
    required this.dayNumber,
    required this.name,
    required this.exerciseCount,
    this.exercises = const [],
  });

  final int id;
  final int dayNumber;
  final String name;
  final int exerciseCount;
  final List<PlannedExercisePreview> exercises;

  WorkoutPlanDay copyWith({
    int? id,
    int? dayNumber,
    String? name,
    int? exerciseCount,
    List<PlannedExercisePreview>? exercises,
  }) {
    return WorkoutPlanDay(
      id: id ?? this.id,
      dayNumber: dayNumber ?? this.dayNumber,
      name: name ?? this.name,
      exerciseCount: exerciseCount ?? (exercises?.length ?? this.exerciseCount),
      exercises: exercises ?? this.exercises,
    );
  }
}

List<PlannedExercisePreview> resolveDefaultExercisesForDay(
  String dayName, [
  String? sourceName,
]) {
  final combined = '${dayName.toLowerCase()} ${(sourceName ?? '').toLowerCase()}';
  if (combined.contains('upper') ||
      combined.contains('thân trên') ||
      combined.contains('ngực')) {
    return const [
      PlannedExercisePreview(
        name: 'Barbell Bench Press',
        setsReps: '4x8-10',
        primaryMuscle: 'Ngực',
      ),
      PlannedExercisePreview(
        name: 'Incline Dumbbell Press',
        setsReps: '3x10-12',
        primaryMuscle: 'Ngực',
      ),
      PlannedExercisePreview(
        name: 'Lat Pulldown',
        setsReps: '4x10-12',
        primaryMuscle: 'Lưng',
      ),
      PlannedExercisePreview(
        name: 'Dumbbell Shoulder Press',
        setsReps: '3x10-12',
        primaryMuscle: 'Vai',
      ),
      PlannedExercisePreview(
        name: 'Cable Triceps Pushdown',
        setsReps: '3x12-15',
        primaryMuscle: 'Tay sau',
      ),
    ];
  }
  if (combined.contains('lower') ||
      combined.contains('thân dưới') ||
      combined.contains('chân')) {
    return const [
      PlannedExercisePreview(
        name: 'Barbell Back Squat',
        setsReps: '4x8-10',
        primaryMuscle: 'Đùi trước',
      ),
      PlannedExercisePreview(
        name: 'Romanian Deadlift',
        setsReps: '3x10-12',
        primaryMuscle: 'Đùi sau',
      ),
      PlannedExercisePreview(
        name: 'Leg Press',
        setsReps: '3x10-12',
        primaryMuscle: 'Đùi',
      ),
      PlannedExercisePreview(
        name: 'Standing Calf Raise',
        setsReps: '3x15',
        primaryMuscle: 'Bắp chân',
      ),
      PlannedExercisePreview(
        name: 'Hanging Knee Raise',
        setsReps: '3x12-15',
        primaryMuscle: 'Bụng',
      ),
    ];
  }
  if (combined.contains('pull') ||
      combined.contains('kéo') ||
      combined.contains('lưng')) {
    return const [
      PlannedExercisePreview(
        name: 'Lat Pulldown',
        setsReps: '4x10-12',
        primaryMuscle: 'Lưng',
      ),
      PlannedExercisePreview(
        name: 'Seated Cable Row',
        setsReps: '3x10-12',
        primaryMuscle: 'Lưng',
      ),
      PlannedExercisePreview(
        name: 'Face Pull',
        setsReps: '3x15',
        primaryMuscle: 'Vai',
      ),
      PlannedExercisePreview(
        name: 'Dumbbell Bicep Curl',
        setsReps: '3x10-12',
        primaryMuscle: 'Tay trước',
      ),
      PlannedExercisePreview(
        name: 'Hammer Curl',
        setsReps: '3x12',
        primaryMuscle: 'Tay trước',
      ),
    ];
  }
  if (combined.contains('push') || combined.contains('đẩy')) {
    return const [
      PlannedExercisePreview(
        name: 'Barbell Bench Press',
        setsReps: '4x8-10',
        primaryMuscle: 'Ngực',
      ),
      PlannedExercisePreview(
        name: 'Incline Dumbbell Press',
        setsReps: '3x10-12',
        primaryMuscle: 'Ngực',
      ),
      PlannedExercisePreview(
        name: 'Dumbbell Shoulder Press',
        setsReps: '3x10-12',
        primaryMuscle: 'Vai',
      ),
      PlannedExercisePreview(
        name: 'Cable Triceps Pushdown',
        setsReps: '3x12-15',
        primaryMuscle: 'Tay sau',
      ),
      PlannedExercisePreview(
        name: 'Lateral Raise',
        setsReps: '3x12-15',
        primaryMuscle: 'Vai',
      ),
    ];
  }
  return const [
    PlannedExercisePreview(
      name: 'Barbell Back Squat',
      setsReps: '4x8-10',
      primaryMuscle: 'Đùi trước',
    ),
    PlannedExercisePreview(
      name: 'Barbell Bench Press',
      setsReps: '3x10',
      primaryMuscle: 'Ngực',
    ),
    PlannedExercisePreview(
      name: 'Lat Pulldown',
      setsReps: '3x10-12',
      primaryMuscle: 'Lưng',
    ),
    PlannedExercisePreview(
      name: 'Dumbbell Shoulder Press',
      setsReps: '3x10-12',
      primaryMuscle: 'Vai',
    ),
    PlannedExercisePreview(
      name: 'Dumbbell Bicep Curl',
      setsReps: '3x12',
      primaryMuscle: 'Tay trước',
    ),
  ];
}

class ScheduleDraftExercise {
  const ScheduleDraftExercise({
    required this.exercise,
    required this.targetSets,
    required this.targetRepsMin,
    required this.targetRepsMax,
    required this.restSeconds,
  });

  final ExerciseDefinition exercise;
  final int targetSets;
  final int targetRepsMin;
  final int targetRepsMax;
  final int restSeconds;
}

class ScheduleDraftDay {
  const ScheduleDraftDay({
    required this.date,
    required this.time,
    required this.title,
    required this.exercises,
  });

  final DateTime date;
  final String time;
  final String title;
  final List<ScheduleDraftExercise> exercises;
}

class ScheduleProposalView {
  const ScheduleProposalView({
    required this.id,
    required this.sourceType,
    required this.scope,
    required this.expiresAt,
    required this.items,
  });

  factory ScheduleProposalView.fromJson(Map<String, dynamic> json) {
    final rows = json['items'] as List<dynamic>? ?? const [];
    return ScheduleProposalView(
      id: json['id'] as int,
      sourceType: json['sourceType'] as String? ?? 'MANUAL',
      scope: json['scope'] as String? ?? 'ONE_DAY',
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      items: rows
          .whereType<Map<String, dynamic>>()
          .map(ScheduleProposalItemView.fromJson)
          .toList(),
    );
  }

  final int id;
  final String sourceType;
  final String scope;
  final DateTime expiresAt;
  final List<ScheduleProposalItemView> items;
}

class ScheduleProposalItemView {
  const ScheduleProposalItemView({
    required this.date,
    required this.time,
    required this.title,
    required this.exerciseCount,
    this.plannedExercises = const [],
  });

  factory ScheduleProposalItemView.fromJson(Map<String, dynamic> json) {
    final exerciseRows = json['exercises'] as List<dynamic>? ?? const [];
    return ScheduleProposalItemView(
      date: DateTime.parse(json['scheduledDate'] as String),
      time: json['scheduledTime'] as String? ?? '18:00',
      title: json['title'] as String? ?? 'Buổi tập',
      exerciseCount: exerciseRows.length,
      plannedExercises: exerciseRows
          .whereType<Map<String, dynamic>>()
          .map((exercise) {
            final sets = exercise['targetSets'] as int? ?? 3;
            final repsMin = exercise['targetRepsMin'] as int?;
            final repsMax = exercise['targetRepsMax'] as int?;
            final duration = exercise['targetDurationSeconds'] as int?;
            final setsReps = duration != null
                ? '${sets}x${duration}s'
                : repsMin != null && repsMax != null && repsMin != repsMax
                ? '${sets}x$repsMin-$repsMax'
                : '${sets}x${repsMin ?? repsMax ?? 10}';
            return PlannedExercisePreview(
              name: (exercise['exerciseName'] as String?)?.trim() ?? '',
              setsReps: setsReps,
              primaryMuscle: (exercise['primaryMuscle'] as String?)?.trim(),
            );
          })
          .where((exercise) => exercise.name.isNotEmpty)
          .toList(),
    );
  }

  final DateTime date;
  final String time;
  final String title;
  final int exerciseCount;
  final List<PlannedExercisePreview> plannedExercises;

  ScheduleProposalItemView copyWith({
    DateTime? date,
    String? time,
    String? title,
    int? exerciseCount,
    List<PlannedExercisePreview>? plannedExercises,
  }) {
    return ScheduleProposalItemView(
      date: date ?? this.date,
      time: time ?? this.time,
      title: title ?? this.title,
      exerciseCount: exerciseCount ?? this.exerciseCount,
      plannedExercises: plannedExercises ?? this.plannedExercises,
    );
  }
}

class AppliedWorkoutSchedule {
  const AppliedWorkoutSchedule({
    required this.id,
    required this.date,
    required this.time,
    required this.title,
    this.status = 'PLANNED',
    this.plannedExercises = const [],
  });

  final int id;
  final DateTime date;
  final String time;
  final String title;
  final String status;
  final List<PlannedExercisePreview> plannedExercises;
}

class WorkoutPlanningException implements Exception {
  const WorkoutPlanningException(this.message);

  final String message;

  @override
  String toString() => message;
}
