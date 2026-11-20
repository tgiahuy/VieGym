import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../onboarding/application/health_profile_controller.dart';
import '../../onboarding/domain/user_profile_models.dart';
import '../../profile/presentation/settings_screen.dart';
import '../../workout/application/workout_schedule_controller.dart';
import '../../workout/data/exercise_catalog.dart';
import '../../workout/data/workout_schedule_planning_repository.dart';
import '../../workout/domain/workout_models.dart';
import '../data/ai_repository.dart';
import '../domain/ai_plan_models.dart';
import 'widgets/ai_personalization_banner.dart';

class AiPersonalizedScheduleScreen extends ConsumerStatefulWidget {
  const AiPersonalizedScheduleScreen({super.key});

  @override
  ConsumerState<AiPersonalizedScheduleScreen> createState() =>
      _AiPersonalizedScheduleScreenState();
}

class _AiPersonalizedScheduleScreenState
    extends ConsumerState<AiPersonalizedScheduleScreen> {
  static const Map<String, String> _equipmentCodeMap = {
    'bw': 'BODYWEIGHT',
    'pullup_bar': 'PULL_UP_BAR',
    'db': 'DUMBBELL',
    'bb': 'BARBELL',
    'kb': 'KETTLEBELL',
    'bench': 'BENCH',
    'adjustable_bench': 'ADJUSTABLE_BENCH',
    'cable': 'CABLE_MACHINE',
    'machine': 'MACHINE',
    'band': 'RESISTANCE_BAND',
    'treadmill': 'TREADMILL',
  };

  static const List<int> _weekOptions = [2, 4, 8, 12];
  static const List<int> _durationOptions = [30, 45, 60, 75];
  static const List<String> _weekdayLabels = [
    'T2',
    'T3',
    'T4',
    'T5',
    'T6',
    'T7',
    'CN',
  ];

  late FitnessGoal _selectedGoal;
  String _intensity = 'MODERATE';
  DateTime _startDate = _dateOnly(DateTime.now());
  int _durationWeeks = 4;
  int _sessionMinutes = 45;
  TimeOfDay _preferredTime = const TimeOfDay(hour: 18, minute: 0);
  late Set<int> _selectedWeekdays; // 1 = Mon .. 7 = Sun
  final TextEditingController _goalNoteController = TextEditingController();

  bool _isGenerating = false;
  bool _isApplying = false;
  bool _generatedFromAi = false;
  List<_GeneratedSession> _generatedSessions = const [];
  final Set<int> _expandedWeeks = {1};

  @override
  void initState() {
    super.initState();
    final profile = ref.read(healthProfileProvider);
    _selectedGoal = profile.goal;
    _sessionMinutes = _durationOptions.contains(profile.sessionDurationMinutes)
        ? profile.sessionDurationMinutes
        : 45;
    _selectedWeekdays = _defaultWeekdaysForCount(profile.workoutDaysPerWeek);
    _intensity = switch (profile.experience) {
      TrainingExperience.beginner => 'LOW',
      TrainingExperience.intermediate => 'MODERATE',
      TrainingExperience.advanced => 'HIGH',
    };
  }

  @override
  void dispose() {
    _goalNoteController.dispose();
    super.dispose();
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static Set<int> _defaultWeekdaysForCount(int count) {
    return switch (count.clamp(2, 6)) {
      2 => {DateTime.monday, DateTime.thursday},
      3 => {DateTime.monday, DateTime.wednesday, DateTime.friday},
      4 => {
        DateTime.monday,
        DateTime.tuesday,
        DateTime.thursday,
        DateTime.friday,
      },
      5 => {
        DateTime.monday,
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.friday,
        DateTime.saturday,
      },
      _ => {
        DateTime.monday,
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,
        DateTime.saturday,
      },
    };
  }

  DateTime get _endDate =>
      _startDate.add(Duration(days: _durationWeeks * 7 - 1));

  List<DateTime> get _scheduledDates {
    final dates = <DateTime>[];
    final totalDays = _durationWeeks * 7;
    for (var i = 0; i < totalDays; i++) {
      final d = _startDate.add(Duration(days: i));
      if (_selectedWeekdays.contains(d.weekday)) {
        dates.add(d);
      }
    }
    return dates;
  }

  String get _formattedTime {
    final hh = _preferredTime.hour.toString().padLeft(2, '0');
    final mm = _preferredTime.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String _formatDateVi(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  String _formatIsoDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  String _weekdayShort(int weekday) => _weekdayLabels[weekday - 1];

  Future<void> _pickStartDate() async {
    final today = _dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate.isBefore(today) ? today : _startDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 180)),
      helpText: 'Chọn ngày bắt đầu lộ trình',
    );
    if (picked != null) {
      setState(() => _startDate = _dateOnly(picked));
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _preferredTime,
      helpText: 'Chọn khung giờ tập mặc định',
    );
    if (picked != null) {
      setState(() => _preferredTime = picked);
    }
  }

  List<_SplitTemplate> _buildSplitTemplates() {
    final count = _selectedWeekdays.length;
    if (_selectedGoal == FitnessGoal.loseFat) {
      if (count <= 3) {
        return const [
          _SplitTemplate(
            title: 'Toàn thân & Đốt mỡ (Full Body)',
            targetMusclesLabel: 'Ngực • Lưng • Chân • Core',
            muscleCodes: ['CHEST', 'BACK', 'QUADS', 'ABS'],
            muscleKeys: ['chest', 'lats', 'upper_back', 'quads', 'abs'],
          ),
          _SplitTemplate(
            title: 'Thân trên & Cardio HIIT',
            targetMusclesLabel: 'Vai • Tay • Bụng',
            muscleCodes: ['SHOULDERS', 'BICEPS', 'TRICEPS', 'ABS'],
            muscleKeys: [
              'front_delts',
              'side_delts',
              'biceps',
              'triceps',
              'abs',
            ],
          ),
          _SplitTemplate(
            title: 'Thân dưới & Core (Lower + Core)',
            targetMusclesLabel: 'Đùi • Mông • Bụng',
            muscleCodes: ['QUADS', 'HAMSTRINGS', 'GLUTES', 'ABS'],
            muscleKeys: ['quads', 'hamstrings', 'glutes', 'abs'],
          ),
        ];
      }
      return const [
        _SplitTemplate(
          title: 'Đẩy & Core (Push + Abs)',
          targetMusclesLabel: 'Ngực • Vai • Tay sau • Bụng',
          muscleCodes: ['CHEST', 'SHOULDERS', 'TRICEPS', 'ABS'],
          muscleKeys: [
            'chest',
            'upper_chest',
            'front_delts',
            'side_delts',
            'triceps',
            'abs',
          ],
        ),
        _SplitTemplate(
          title: 'Kéo & Lưng xô (Pull)',
          targetMusclesLabel: 'Lưng • Xô • Tay trước',
          muscleCodes: ['BACK', 'LATS', 'BICEPS'],
          muscleKeys: ['lats', 'upper_back', 'rear_delts', 'biceps'],
        ),
        _SplitTemplate(
          title: 'Chân & Mông đốt calo (Legs)',
          targetMusclesLabel: 'Đùi trước • Đùi sau • Mông',
          muscleCodes: ['QUADS', 'HAMSTRINGS', 'GLUTES'],
          muscleKeys: ['quads', 'hamstrings', 'glutes'],
        ),
        _SplitTemplate(
          title: 'Toàn thân & Conditioning',
          targetMusclesLabel: 'Toàn thân • Core',
          muscleCodes: ['CHEST', 'BACK', 'QUADS', 'ABS'],
          muscleKeys: ['chest', 'lats', 'quads', 'abs'],
        ),
      ];
    }

    if (count <= 2) {
      return const [
        _SplitTemplate(
          title: 'Thân trên (Upper Body)',
          targetMusclesLabel: 'Ngực • Lưng • Vai • Tay',
          muscleCodes: ['CHEST', 'BACK', 'SHOULDERS', 'BICEPS', 'TRICEPS'],
          muscleKeys: [
            'chest',
            'lats',
            'upper_back',
            'front_delts',
            'side_delts',
            'biceps',
            'triceps',
          ],
        ),
        _SplitTemplate(
          title: 'Thân dưới & Core (Lower Body)',
          targetMusclesLabel: 'Đùi • Mông • Bụng',
          muscleCodes: ['QUADS', 'HAMSTRINGS', 'GLUTES', 'ABS'],
          muscleKeys: ['quads', 'hamstrings', 'glutes', 'abs'],
        ),
      ];
    }

    if (count == 3) {
      return const [
        _SplitTemplate(
          title: 'Đẩy (Push — Ngực, Vai, Tay sau)',
          targetMusclesLabel: 'Ngực • Vai • Tay sau',
          muscleCodes: ['CHEST', 'SHOULDERS', 'TRICEPS'],
          muscleKeys: [
            'chest',
            'upper_chest',
            'front_delts',
            'side_delts',
            'triceps',
          ],
        ),
        _SplitTemplate(
          title: 'Kéo (Pull — Lưng, Xô, Tay trước)',
          targetMusclesLabel: 'Lưng • Xô • Tay trước',
          muscleCodes: ['BACK', 'LATS', 'BICEPS'],
          muscleKeys: ['lats', 'upper_back', 'rear_delts', 'biceps'],
        ),
        _SplitTemplate(
          title: 'Chân & Core (Legs & Abs)',
          targetMusclesLabel: 'Đùi trước • Đùi sau • Mông • Bụng',
          muscleCodes: ['QUADS', 'HAMSTRINGS', 'GLUTES', 'ABS'],
          muscleKeys: ['quads', 'hamstrings', 'glutes', 'abs'],
        ),
      ];
    }

    if (count == 4) {
      return const [
        _SplitTemplate(
          title: 'Thân trên A (Upper Power)',
          targetMusclesLabel: 'Ngực • Lưng • Vai',
          muscleCodes: ['CHEST', 'BACK', 'SHOULDERS'],
          muscleKeys: [
            'chest',
            'lats',
            'upper_back',
            'front_delts',
            'side_delts',
          ],
        ),
        _SplitTemplate(
          title: 'Thân dưới A (Lower Squat Focus)',
          targetMusclesLabel: 'Đùi trước • Mông • Bụng',
          muscleCodes: ['QUADS', 'GLUTES', 'ABS'],
          muscleKeys: ['quads', 'glutes', 'abs'],
        ),
        _SplitTemplate(
          title: 'Thân trên B (Upper Hypertrophy)',
          targetMusclesLabel: 'Ngực • Vai • Tay trước • Tay sau',
          muscleCodes: ['CHEST', 'SHOULDERS', 'BICEPS', 'TRICEPS'],
          muscleKeys: [
            'chest',
            'upper_chest',
            'side_delts',
            'biceps',
            'triceps',
          ],
        ),
        _SplitTemplate(
          title: 'Thân dưới B (Lower Hinge Focus)',
          targetMusclesLabel: 'Đùi sau • Mông • Bắp chân',
          muscleCodes: ['HAMSTRINGS', 'GLUTES', 'CALVES'],
          muscleKeys: ['hamstrings', 'glutes', 'calves'],
        ),
      ];
    }

    return const [
      _SplitTemplate(
        title: 'Đẩy (Push — Ngực, Vai, Tay sau)',
        targetMusclesLabel: 'Ngực • Vai • Tay sau',
        muscleCodes: ['CHEST', 'SHOULDERS', 'TRICEPS'],
        muscleKeys: [
          'chest',
          'upper_chest',
          'front_delts',
          'side_delts',
          'triceps',
        ],
      ),
      _SplitTemplate(
        title: 'Kéo (Pull — Lưng, Xô, Tay trước)',
        targetMusclesLabel: 'Lưng • Xô • Tay trước',
        muscleCodes: ['BACK', 'LATS', 'BICEPS'],
        muscleKeys: ['lats', 'upper_back', 'rear_delts', 'biceps'],
      ),
      _SplitTemplate(
        title: 'Chân & Mông (Legs)',
        targetMusclesLabel: 'Đùi trước • Đùi sau • Mông',
        muscleCodes: ['QUADS', 'HAMSTRINGS', 'GLUTES'],
        muscleKeys: ['quads', 'hamstrings', 'glutes'],
      ),
      _SplitTemplate(
        title: 'Thân trên (Upper Balance)',
        targetMusclesLabel: 'Ngực • Lưng • Vai',
        muscleCodes: ['CHEST', 'BACK', 'SHOULDERS'],
        muscleKeys: [
          'chest',
          'lats',
          'upper_back',
          'front_delts',
          'side_delts',
        ],
      ),
      _SplitTemplate(
        title: 'Thân dưới & Core (Lower & Abs)',
        targetMusclesLabel: 'Đùi • Mông • Bụng',
        muscleCodes: ['QUADS', 'GLUTES', 'ABS'],
        muscleKeys: ['quads', 'glutes', 'abs'],
      ),
    ];
  }

  Future<void> _generateSchedule() async {
    if (_selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất 1 ngày tập trong tuần.'),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isGenerating = true);

    final aiRepo = ref.read(aiRepositoryProvider);
    final aiConsent = ref.read(aiConsentProvider);
    final userEquipIds = ref.read(userEquipmentProvider);
    final equipmentCodes = userEquipIds
        .map((id) => _equipmentCodeMap[id])
        .whereType<String>()
        .toList();

    final templates = _buildSplitTemplates();
    final templatePlans = <int, AiWorkoutPlan?>{};
    var anyAi = false;

    if (aiConsent) {
      for (var i = 0; i < templates.length; i++) {
        try {
          final plan = await aiRepo.generateWorkout(
            targetDate: _startDate.add(Duration(days: i)),
            muscleCodes: templates[i].muscleCodes,
            equipmentCodes: equipmentCodes,
            durationMinutes: _sessionMinutes,
            intensity: _intensity,
          );
          templatePlans[i] = plan;
          if (plan.isAiGenerated) anyAi = true;
        } catch (_) {
          templatePlans[i] = null;
        }
      }
    }

    final dates = _scheduledDates;
    final sessions = <_GeneratedSession>[];

    for (var i = 0; i < dates.length; i++) {
      final date = dates[i];
      final weekIndex = (date.difference(_startDate).inDays ~/ 7) + 1;
      final splitIndex = i % templates.length;
      final template = templates[splitIndex];
      final aiPlan = templatePlans[splitIndex];

      final exercises = _buildExercisesForSession(
        aiPlan: aiPlan,
        template: template,
        weekIndex: weekIndex,
        userEquipIds: userEquipIds,
      );

      final phaseTitle = _phaseTitleForWeek(weekIndex);

      sessions.add(
        _GeneratedSession(
          weekNumber: weekIndex,
          date: date,
          time: _formattedTime,
          title: aiPlan != null && aiPlan.planTitle.trim().isNotEmpty
              ? aiPlan.planTitle.trim()
              : template.title,
          targetMuscles: template.targetMusclesLabel,
          durationMinutes: aiPlan != null && aiPlan.estimatedDurationMinutes > 0
              ? aiPlan.estimatedDurationMinutes
              : _sessionMinutes,
          phaseNote: phaseTitle,
          rationale: aiPlan?.rationale,
          exercises: exercises,
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      _generatedSessions = sessions;
      _generatedFromAi = anyAi;
      _isGenerating = false;
      _expandedWeeks
        ..clear()
        ..add(1);
    });
  }

  String _phaseTitleForWeek(int week) {
    if (_durationWeeks <= 2) {
      return week == 1
          ? 'Tuần 1: Thiết lập nhịp tập & kỹ thuật chuẩn'
          : 'Tuần 2: Tăng tải có kiểm soát';
    }
    if (week <= (_durationWeeks / 3).ceil()) {
      return 'Giai đoạn nền tảng: Ổn định kỹ thuật & thích nghi';
    }
    if (week <= (_durationWeeks * 2 / 3).ceil()) {
      return 'Giai đoạn phát triển: Tăng tải tiến bộ (Progressive Overload)';
    }
    return 'Giai đoạn bứt phá: Tối ưu cường độ & chạm mục tiêu';
  }

  List<_GeneratedExercise> _buildExercisesForSession({
    required AiWorkoutPlan? aiPlan,
    required _SplitTemplate template,
    required int weekIndex,
    required Set<String> userEquipIds,
  }) {
    final extraSet = weekIndex >= 3 ? 1 : 0;

    if (aiPlan != null && aiPlan.exercises.isNotEmpty) {
      return aiPlan.exercises.map((e) {
        final sets = (e.targetSets + extraSet).clamp(2, 6);
        final reps = e.targetRepsMin == e.targetRepsMax
            ? '${e.targetRepsMin}'
            : '${e.targetRepsMin}-${e.targetRepsMax}';
        return _GeneratedExercise(
          name: e.name,
          setsReps: '${sets}x$reps',
          targetSets: sets,
          targetRepsMin: e.targetRepsMin,
          targetRepsMax: e.targetRepsMax,
          restSeconds: e.restSeconds,
          primaryMuscle: e.primaryMuscleCode,
        );
      }).toList();
    }

    // Fallback to local ExerciseCatalog filtered by muscle groups & duration
    final targetCount = _sessionMinutes <= 30
        ? 4
        : _sessionMinutes <= 45
        ? 5
        : 6;
    final candidates = exerciseCatalog
        .where((ex) => template.muscleKeys.contains(ex.primaryMuscleKey))
        .toList();

    final picked = (candidates.isNotEmpty ? candidates : exerciseCatalog)
        .take(targetCount)
        .toList();

    final (repsMin, repsMax, restSec) = switch (_selectedGoal) {
      FitnessGoal.buildStrength => (4, 6, 150),
      FitnessGoal.loseFat => (12, 15, 60),
      FitnessGoal.maintain => (10, 12, 75),
      FitnessGoal.gainMuscle => (8, 12, 90),
    };

    return picked.map((ex) {
      final sets = (3 + extraSet).clamp(3, 5);
      return _GeneratedExercise(
        name: ex.name,
        setsReps: '${sets}x$repsMin-$repsMax',
        targetSets: sets,
        targetRepsMin: repsMin,
        targetRepsMax: repsMax,
        restSeconds: restSec,
        primaryMuscle: ex.primaryMuscle,
        definition: ex,
      );
    }).toList();
  }

  Future<void> _applyToSchedule() async {
    if (_generatedSessions.isEmpty) return;

    setState(() => _isApplying = true);
    HapticFeedback.mediumImpact();

    final items = _generatedSessions.asMap().entries.map((entry) {
      final idx = entry.key;
      final s = entry.value;
      return WorkoutScheduleItem(
        id: 'ai_plan_${DateTime.now().millisecondsSinceEpoch}_$idx',
        date: _formatIsoDate(s.date),
        time: s.time,
        title: s.title,
        targetMuscles: s.targetMuscles,
        durationMinutes: s.durationMinutes,
        status: ScheduleStatus.planned,
        plannedExercises: s.exercises
            .map(
              (e) => PlannedExercisePreview(
                name: e.name,
                setsReps: e.setsReps,
                primaryMuscle: e.primaryMuscle,
              ),
            )
            .toList(),
      );
    }).toList();

    // Merge into local schedule controller immediately so the user sees it right away
    ref.read(workoutScheduleProvider.notifier).mergeAppliedSchedules(items);

    // Best-effort sync of the first week's sessions to backend proposal API
    try {
      final planningRepo = ref.read(workoutSchedulePlanningRepositoryProvider);
      final firstWeek = _generatedSessions
          .where((s) => s.weekNumber == 1)
          .toList();
      final draftDays = <ScheduleDraftDay>[];
      for (final s in firstWeek) {
        final draftExercises = <ScheduleDraftExercise>[];
        for (final ex in s.exercises) {
          final def =
              ex.definition ??
              exerciseCatalog.firstWhere(
                (c) => c.name.toLowerCase() == ex.name.toLowerCase(),
                orElse: () => exerciseCatalog.first,
              );
          draftExercises.add(
            ScheduleDraftExercise(
              exercise: def,
              targetSets: ex.targetSets,
              targetRepsMin: ex.targetRepsMin,
              targetRepsMax: ex.targetRepsMax,
              restSeconds: ex.restSeconds,
            ),
          );
        }
        draftDays.add(
          ScheduleDraftDay(
            date: s.date,
            time: s.time,
            title: s.title,
            exercises: draftExercises,
          ),
        );
      }
      if (draftDays.isNotEmpty) {
        final proposal = await planningRepo.createDirectProposal(
          sourceType: 'AI',
          days: draftDays,
        );
        await planningRepo.applyProposal(proposal.id);
      }
    } catch (_) {
      // Offline or unmapped exercises: local schedule is already updated.
    }

    if (!mounted) return;
    setState(() => _isApplying = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã áp dụng ${_generatedSessions.length} buổi tập từ ${_formatDateVi(_startDate)} đến ${_formatDateVi(_endDate)}!',
        ),
        action: SnackBarAction(
          label: 'Xem lịch',
          onPressed: () => context.push('/workout/schedule'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(healthProfileProvider);
    final aiConsent = ref.watch(aiConsentProvider);

    final groupedByWeek = <int, List<_GeneratedSession>>{};
    for (final s in _generatedSessions) {
      groupedByWeek.putIfAbsent(s.weekNumber, () => []).add(s);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text(
          'Lịch trình luyện tập cá nhân hoá',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          const AiPersonalizationBanner(
            message:
                'Bật cá nhân hoá AI để hệ thống đọc thể trạng, thiết bị và tối ưu lịch tập chính xác hơn.',
          ),

          // Intro Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.aiVioletSoft,
                  AppColors.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.aiViolet.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.aiViolet.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.aiViolet,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lộ trình AI theo mốc thời gian thực',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'AI thiết kế lịch tập phân bổ theo ngày cụ thể, tăng tải tiến bộ qua từng tuần để đưa bạn chạm mục tiêu${profile.targetWeightKg > 0 ? ' (${profile.weightKg}kg → ${profile.targetWeightKg}kg)' : ''}.',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 1. Mục tiêu & Cường độ
          _sectionLabel('1. MỤC TIÊU HƯỚNG ĐẾN'),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: FitnessGoal.values.map((goal) {
                      final selected = _selectedGoal == goal;
                      return ChoiceChip(
                        label: Text(goal.label),
                        selected: selected,
                        selectedColor: AppColors.aiVioletSoft,
                        side: BorderSide(
                          color: selected
                              ? AppColors.aiViolet
                              : AppColors.border,
                        ),
                        labelStyle: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? AppColors.aiViolet
                              : AppColors.textPrimary,
                        ),
                        onSelected: (_) => setState(() => _selectedGoal = goal),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Cường độ mong muốn',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _intensityChip('LOW', 'Nhẹ nhàng'),
                      const SizedBox(width: 8),
                      _intensityChip('MODERATE', 'Trung bình'),
                      const SizedBox(width: 8),
                      _intensityChip('HIGH', 'Cường độ cao'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _goalNoteController,
                    decoration: const InputDecoration(
                      hintText:
                          'Ghi chú thêm (VD: Ưu tiên vai & lưng, hạn chế áp lực gối...)',
                      hintStyle: TextStyle(fontSize: 12.5),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2. Thời gian áp dụng cụ thể
          _sectionLabel('2. THỜI GIAN ÁP DỤNG CỤ THỂ'),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _DateTimeBox(
                          icon: Icons.calendar_today_rounded,
                          label: 'Ngày bắt đầu',
                          value: _formatDateVi(_startDate),
                          onTap: _pickStartDate,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DateTimeBox(
                          icon: Icons.schedule_rounded,
                          label: 'Giờ tập mặc định',
                          value: _formattedTime,
                          onTap: _pickTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Thời lượng lộ trình',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Đến ${_formatDateVi(_endDate)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.aiViolet,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: _weekOptions.map((weeks) {
                      final selected = _durationWeeks == weeks;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: weeks == _weekOptions.last ? 0 : 8,
                          ),
                          child: ChoiceChip(
                            label: Center(child: Text('$weeks tuần')),
                            selected: selected,
                            selectedColor: AppColors.aiVioletSoft,
                            side: BorderSide(
                              color: selected
                                  ? AppColors.aiViolet
                                  : AppColors.border,
                            ),
                            labelStyle: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: selected
                                  ? AppColors.aiViolet
                                  : AppColors.textPrimary,
                            ),
                            onSelected: (_) =>
                                setState(() => _durationWeeks = weeks),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Các ngày tập trong tuần',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${_selectedWeekdays.length} buổi/tuần • ${_scheduledDates.length} buổi tổng',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(7, (idx) {
                      final weekday = idx + 1;
                      final selected = _selectedWeekdays.contains(weekday);
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: idx == 6 ? 0 : 6),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              setState(() {
                                if (selected) {
                                  if (_selectedWeekdays.length > 1) {
                                    _selectedWeekdays.remove(weekday);
                                  }
                                } else {
                                  _selectedWeekdays.add(weekday);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.aiVioletSoft
                                    : AppColors.surfaceNested,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.aiViolet
                                      : AppColors.border,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _weekdayLabels[idx],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: selected
                                      ? AppColors.aiViolet
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Thời lượng mỗi buổi',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: _durationOptions.map((mins) {
                      final selected = _sessionMinutes == mins;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: mins == _durationOptions.last ? 0 : 8,
                          ),
                          child: ChoiceChip(
                            label: Center(child: Text('$mins ph')),
                            selected: selected,
                            selectedColor: AppColors.primarySoft,
                            side: BorderSide(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                            labelStyle: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                            onSelected: (_) =>
                                setState(() => _sessionMinutes = mins),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Generate CTA
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.aiViolet,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _isGenerating ? null : _generateSchedule,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(
                _isGenerating
                    ? 'AI đang thiết kế lịch trình...'
                    : 'AI Tạo lịch trình cá nhân hoá',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                ),
              ),
            ),
          ),

          if (_generatedSessions.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _sectionLabel(
                    'LỘ TRÌNH ĐỀ XUẤT (${_generatedSessions.length} BUỔI)',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _generatedFromAi && aiConsent
                        ? AppColors.aiVioletSoft
                        : AppColors.surfaceNested,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _generatedFromAi && aiConsent
                        ? 'VieGym AI'
                        : 'Lộ trình thông minh',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _generatedFromAi && aiConsent
                          ? AppColors.aiViolet
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ...groupedByWeek.entries.map((entry) {
              final weekNum = entry.key;
              final weekSessions = entry.value;
              final isExpanded = _expandedWeeks.contains(weekNum);
              final phaseNote = weekSessions.first.phaseNote;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    ListTile(
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedWeeks.remove(weekNum);
                          } else {
                            _expandedWeeks.add(weekNum);
                          }
                        });
                      },
                      title: Text(
                        'Tuần $weekNum (${weekSessions.length} buổi)',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14.5,
                        ),
                      ),
                      subtitle: Text(
                        phaseNote,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.aiViolet,
                        ),
                      ),
                      trailing: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                      ),
                    ),
                    if (isExpanded) ...[
                      const Divider(height: 1),
                      ...weekSessions.map((session) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primarySoft,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${_weekdayShort(session.date.weekday)}, ${_formatDateVi(session.date)} • ${session.time}',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${session.durationMinutes} phút',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                session.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                session.targetMuscles,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...session.exercises.map(
                                (ex) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.fiber_manual_record,
                                        size: 6,
                                        color: AppColors.textMuted,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          ex.name,
                                          style: const TextStyle(fontSize: 12.5),
                                        ),
                                      ),
                                      Text(
                                        ex.setsReps,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (session != weekSessions.last)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Divider(height: 1),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              );
            }),

            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _isApplying ? null : _applyToSchedule,
                icon: _isApplying
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.event_available_rounded),
                label: Text(
                  _isApplying
                      ? 'Đang áp dụng vào lịch...'
                      : 'Áp dụng lịch trình này vào Lịch tập',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.8,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
      ),
    );
  }

  Widget _intensityChip(String code, String label) {
    final selected = _intensity == code;
    return Expanded(
      child: ChoiceChip(
        label: Center(child: Text(label)),
        selected: selected,
        selectedColor: AppColors.aiVioletSoft,
        side: BorderSide(
          color: selected ? AppColors.aiViolet : AppColors.border,
        ),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: selected ? AppColors.aiViolet : AppColors.textPrimary,
        ),
        onSelected: (_) => setState(() => _intensity = code),
      ),
    );
  }
}

class _DateTimeBox extends StatelessWidget {
  const _DateTimeBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceNested,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.aiViolet),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplitTemplate {
  const _SplitTemplate({
    required this.title,
    required this.targetMusclesLabel,
    required this.muscleCodes,
    required this.muscleKeys,
  });

  final String title;
  final String targetMusclesLabel;
  final List<String> muscleCodes;
  final List<String> muscleKeys;
}

class _GeneratedExercise {
  const _GeneratedExercise({
    required this.name,
    required this.setsReps,
    required this.targetSets,
    required this.targetRepsMin,
    required this.targetRepsMax,
    required this.restSeconds,
    required this.primaryMuscle,
    this.definition,
  });

  final String name;
  final String setsReps;
  final int targetSets;
  final int targetRepsMin;
  final int targetRepsMax;
  final int restSeconds;
  final String primaryMuscle;
  final ExerciseDefinition? definition;
}

class _GeneratedSession {
  const _GeneratedSession({
    required this.weekNumber,
    required this.date,
    required this.time,
    required this.title,
    required this.targetMuscles,
    required this.durationMinutes,
    required this.phaseNote,
    required this.exercises,
    this.rationale,
  });

  final int weekNumber;
  final DateTime date;
  final String time;
  final String title;
  final String targetMuscles;
  final int durationMinutes;
  final String phaseNote;
  final String? rationale;
  final List<_GeneratedExercise> exercises;
}
