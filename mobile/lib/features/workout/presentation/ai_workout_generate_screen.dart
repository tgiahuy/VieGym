import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/exercise_tag_chip.dart';
import '../../onboarding/application/health_profile_controller.dart';
import '../application/workout_schedule_controller.dart';
import '../application/workout_session_controller.dart';
import '../data/exercise_catalog.dart';
import '../data/workout_schedule_planning_repository.dart';
import '../domain/muscle_models.dart';
import '../domain/workout_models.dart';
import 'widgets/body_muscle_map.dart';
import 'widgets/exercise_thumbnail.dart';
import 'widgets/schedule_proposal_dialog.dart';

enum _PlanApplyMode { append, replace }

class _MuscleVisualItem {
  const _MuscleVisualItem({
    required this.id,
    required this.code,
    required this.name,
    required this.shortName,
    required this.subtitle,
    required this.imageUrl,
    required this.icon,
    required this.muscleGroup,
  });

  final int id;
  final String code;
  final String name;
  final String shortName;
  final String subtitle;
  final String imageUrl;
  final IconData icon;
  final MuscleGroup muscleGroup;
}

class _EquipmentVisualItem {
  const _EquipmentVisualItem({
    required this.id,
    required this.type,
    required this.name,
    required this.category,
    required this.icon,
    required this.imageUrl,
  });

  final String id;
  final EquipmentType type;
  final String name;
  final String category;
  final IconData icon;
  final String imageUrl;
}

class AiWorkoutGenerateScreen extends ConsumerStatefulWidget {
  const AiWorkoutGenerateScreen({super.key, this.initialDate});

  final DateTime? initialDate;

  @override
  ConsumerState<AiWorkoutGenerateScreen> createState() =>
      _AiWorkoutGenerateScreenState();
}

class _AiWorkoutGenerateScreenState
    extends ConsumerState<AiWorkoutGenerateScreen> {
  final Set<String> _selectedMuscles = {'Cơ ngực', 'Cơ vai'};
  final Set<String> _selectedEquipmentIds = {
    'bw',
    'pullup_bar',
    'db',
    'bb',
    'kb',
    'bench',
    'adjustable_bench',
    'cable',
    'machine',
    'band',
    'treadmill',
  };
  double _durationMinutes = 45;
  String _goal = 'Tăng cơ nạc (Hypertrophy)';
  bool _generateWholeWeek = false;
  bool _isGenerating = false;
  bool _generated = false;
  List<ExerciseDefinition> _generatedExercises = [];

  static const List<_MuscleVisualItem> _allMuscles = [
    _MuscleVisualItem(
      id: 1,
      code: 'ABS',
      name: 'Cơ bụng',
      shortName: 'Bụng',
      subtitle: 'Vùng bụng & core cơ lõi trọng tâm',
      imageUrl:
          'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400&auto=format&fit=crop&q=80',
      icon: Icons.grid_view_rounded,
      muscleGroup: MuscleGroup.abs,
    ),
    _MuscleVisualItem(
      id: 2,
      code: 'ABDUCTORS',
      name: 'Cơ dạng hông',
      shortName: 'Dạng hông',
      subtitle: 'Đưa chân ra xa & ổn định xương chậu',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=400&auto=format&fit=crop&q=80',
      icon: Icons.open_in_full_rounded,
      muscleGroup: MuscleGroup.abductors,
    ),
    _MuscleVisualItem(
      id: 3,
      code: 'ADDUCTORS',
      name: 'Cơ khép hông',
      shortName: 'Khép hông',
      subtitle: 'Đưa chân vào trong & cân bằng cơ đùi trong',
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&auto=format&fit=crop&q=80',
      icon: Icons.close_fullscreen_rounded,
      muscleGroup: MuscleGroup.adductors,
    ),
    _MuscleVisualItem(
      id: 4,
      code: 'BICEPS',
      name: 'Cơ tay trước',
      shortName: 'Tay trước',
      subtitle: 'Bắp tay trước & gập khuỷu phát lực',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=400&auto=format&fit=crop&q=80',
      icon: Icons.sports_gymnastics_rounded,
      muscleGroup: MuscleGroup.biceps,
    ),
    _MuscleVisualItem(
      id: 5,
      code: 'CALVES',
      name: 'Cơ bắp chân',
      shortName: 'Bắp chân',
      subtitle: 'Bắp chân, cơ dép & sức bật bàn chân',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=400&auto=format&fit=crop&q=80',
      icon: Icons.directions_walk_rounded,
      muscleGroup: MuscleGroup.calves,
    ),
    _MuscleVisualItem(
      id: 6,
      code: 'CHEST',
      name: 'Cơ ngực',
      shortName: 'Ngực',
      subtitle: 'Ngực trên, giữa & dưới dày khỏe',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&auto=format&fit=crop&q=80',
      icon: Icons.fitness_center_rounded,
      muscleGroup: MuscleGroup.chest,
    ),
    _MuscleVisualItem(
      id: 7,
      code: 'FOREARMS',
      name: 'Cơ cẳng tay',
      shortName: 'Cẳng tay',
      subtitle: 'Cẳng tay, gân duỗi gập & lực nắm',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=400&auto=format&fit=crop&q=80',
      icon: Icons.pan_tool_rounded,
      muscleGroup: MuscleGroup.forearms,
    ),
    _MuscleVisualItem(
      id: 8,
      code: 'GLUTES',
      name: 'Cơ mông',
      shortName: 'Mông',
      subtitle: 'Cơ mông lớn & mông nhỡ phát lực',
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&auto=format&fit=crop&q=80',
      icon: Icons.airline_seat_legroom_extra_rounded,
      muscleGroup: MuscleGroup.glutes,
    ),
    _MuscleVisualItem(
      id: 9,
      code: 'HAMSTRINGS',
      name: 'Cơ đùi sau',
      shortName: 'Đùi sau',
      subtitle: 'Gân kheo & cơ nhị đầu đùi săn chắc',
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&auto=format&fit=crop&q=80',
      icon: Icons.directions_run_rounded,
      muscleGroup: MuscleGroup.hamstrings,
    ),
    _MuscleVisualItem(
      id: 10,
      code: 'LATS',
      name: 'Cơ lưng xô',
      shortName: 'Lưng xô',
      subtitle: 'Xô lưng rộng chữ V & lưng dày',
      imageUrl:
          'https://images.unsplash.com/photo-1605296867304-46d5465a13f1?w=400&auto=format&fit=crop&q=80',
      icon: Icons.straighten_rounded,
      muscleGroup: MuscleGroup.lats,
    ),
    _MuscleVisualItem(
      id: 11,
      code: 'LOWER_BACK',
      name: 'Cơ lưng dưới',
      shortName: 'Lưng dưới',
      subtitle: 'Cơ dựng sống & thắt lưng trụ vững',
      imageUrl:
          'https://images.unsplash.com/photo-1605296867304-46d5465a13f1?w=400&auto=format&fit=crop&q=80',
      icon: Icons.accessibility_rounded,
      muscleGroup: MuscleGroup.lowerBack,
    ),
    _MuscleVisualItem(
      id: 12,
      code: 'NECK',
      name: 'Cơ cổ',
      shortName: 'Cổ',
      subtitle: 'Nâng đỡ & ổn định đốt sống cổ',
      imageUrl:
          'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=400&auto=format&fit=crop&q=80',
      icon: Icons.person_pin_rounded,
      muscleGroup: MuscleGroup.neck,
    ),
    _MuscleVisualItem(
      id: 13,
      code: 'QUADRICEPS',
      name: 'Cơ đùi trước',
      shortName: 'Đùi trước',
      subtitle: 'Tứ đầu đùi săn chắc phát lực đẩy',
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=400&auto=format&fit=crop&q=80',
      icon: Icons.airline_seat_recline_normal_rounded,
      muscleGroup: MuscleGroup.quads,
    ),
    _MuscleVisualItem(
      id: 14,
      code: 'SHOULDERS',
      name: 'Cơ vai',
      shortName: 'Vai',
      subtitle: 'Khung vai 3D trước, giữa & sau cân đối',
      imageUrl:
          'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=400&auto=format&fit=crop&q=80',
      icon: Icons.shield_rounded,
      muscleGroup: MuscleGroup.sideDelts,
    ),
    _MuscleVisualItem(
      id: 15,
      code: 'TRAPS',
      name: 'Cơ cầu vai',
      shortName: 'Cầu vai',
      subtitle: 'Cơ thang dày dặn & bờ vai vững chãi',
      imageUrl:
          'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=400&auto=format&fit=crop&q=80',
      icon: Icons.keyboard_double_arrow_up_rounded,
      muscleGroup: MuscleGroup.traps,
    ),
    _MuscleVisualItem(
      id: 16,
      code: 'TRICEPS',
      name: 'Cơ tay sau',
      shortName: 'Tay sau',
      subtitle: 'Cơ tam đầu bắp tay sau khỏe khoắn',
      imageUrl:
          'https://images.unsplash.com/photo-1530822847156-5df684ec5ee1?w=400&auto=format&fit=crop&q=80',
      icon: Icons.bolt_rounded,
      muscleGroup: MuscleGroup.triceps,
    ),
    _MuscleVisualItem(
      id: 17,
      code: 'UPPER_BACK',
      name: 'Cơ lưng trên',
      shortName: 'Lưng trên',
      subtitle: 'Cơ trám, lưng trên & ép bả vai',
      imageUrl:
          'https://images.unsplash.com/photo-1605296867304-46d5465a13f1?w=400&auto=format&fit=crop&q=80',
      icon: Icons.view_compact_alt_rounded,
      muscleGroup: MuscleGroup.upperBack,
    ),
  ];

  static const List<_EquipmentVisualItem> _equipmentList = [
    _EquipmentVisualItem(
      id: 'bw',
      type: EquipmentType.bodyweight,
      name: 'Trọng lượng cơ thể (Bodyweight)',
      category: 'Thể trọng',
      icon: Icons.accessibility_new_rounded,
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&auto=format&fit=crop&q=80',
    ),
    _EquipmentVisualItem(
      id: 'pullup_bar',
      type: EquipmentType.bodyweight,
      name: 'Xà đơn / Xà kép (Pull-up / Dip)',
      category: 'Thể trọng',
      icon: Icons.horizontal_rule_rounded,
      imageUrl:
          'https://images.unsplash.com/photo-1599058945522-28d584b6f0ff?w=400&auto=format&fit=crop&q=80',
    ),
    _EquipmentVisualItem(
      id: 'db',
      type: EquipmentType.dumbbell,
      name: 'Tạ đơn (Dumbbell)',
      category: 'Tạ tự do',
      icon: Icons.fitness_center_outlined,
      imageUrl:
          'https://images.unsplash.com/photo-1586401100295-7a833e3f3e82?w=400&auto=format&fit=crop&q=80',
    ),
    _EquipmentVisualItem(
      id: 'bb',
      type: EquipmentType.barbell,
      name: 'Thanh đòn Olympic & Đĩa tạ',
      category: 'Tạ tự do',
      icon: Icons.fitness_center_rounded,
      imageUrl:
          'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=400&auto=format&fit=crop&q=80',
    ),
    _EquipmentVisualItem(
      id: 'kb',
      type: EquipmentType.dumbbell,
      name: 'Tạ bình vôi (Kettlebell)',
      category: 'Tạ tự do',
      icon: Icons.fitness_center_rounded,
      imageUrl:
          'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=400&auto=format&fit=crop&q=80',
    ),
    _EquipmentVisualItem(
      id: 'bench',
      type: EquipmentType.bench,
      name: 'Ghế tập phẳng (Flat Bench)',
      category: 'Ghế & Giá đỡ',
      icon: Icons.chair_alt_rounded,
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&auto=format&fit=crop&q=80',
    ),
    _EquipmentVisualItem(
      id: 'adjustable_bench',
      type: EquipmentType.bench,
      name: 'Ghế tập điều chỉnh (Adjustable Bench)',
      category: 'Ghế & Giá đỡ',
      icon: Icons.airline_seat_recline_extra_rounded,
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&auto=format&fit=crop&q=80',
    ),
    _EquipmentVisualItem(
      id: 'cable',
      type: EquipmentType.cable,
      name: 'Dàn kéo cáp (Cable Station)',
      category: 'Máy & Dây cáp',
      icon: Icons.alt_route_rounded,
      imageUrl:
          'https://images.unsplash.com/photo-1530822847156-5df684ec5ee1?w=400&auto=format&fit=crop&q=80',
    ),
    _EquipmentVisualItem(
      id: 'machine',
      type: EquipmentType.machine,
      name: 'Máy khối chuyên dụng',
      category: 'Máy & Dây cáp',
      icon: Icons.precision_manufacturing_rounded,
      imageUrl:
          'https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?w=400&auto=format&fit=crop&q=80',
    ),
    _EquipmentVisualItem(
      id: 'band',
      type: EquipmentType.bodyweight,
      name: 'Dây kháng lực (Resistance Bands)',
      category: 'Phụ kiện',
      icon: Icons.all_inclusive_rounded,
      imageUrl:
          'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400&auto=format&fit=crop&q=80',
    ),
    _EquipmentVisualItem(
      id: 'treadmill',
      type: EquipmentType.machine,
      name: 'Máy chạy bộ (Treadmill)',
      category: 'Thiết bị Cardio',
      icon: Icons.directions_run_rounded,
      imageUrl:
          'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=400&auto=format&fit=crop&q=80',
    ),
  ];

  static const _goals = [
    (
      'Tăng cơ nạc (Hypertrophy)',
      'Tối ưu phì đại cơ bắp, 8-12 reps, kích thích tổng hợp protein.',
      Icons.fitness_center_rounded,
      '8-12 reps',
    ),
    (
      'Tăng sức mạnh (Strength)',
      'Tải nặng 5-6 reps, tập trung compound và hệ thần kinh.',
      Icons.bolt_rounded,
      '5-6 reps',
    ),
    (
      'Giảm mỡ & Săn chắc (Fat Burn)',
      'Nhịp độ cao 12-15 reps, đốt mỡ và tăng trao đổi chất.',
      Icons.local_fire_department_rounded,
      '12-15 reps',
    ),
    (
      'Phục hồi chức năng (Mobility)',
      'Biên độ toàn diện 15-20 reps, bảo vệ khớp và tăng độ dẻo.',
      Icons.self_improvement_rounded,
      '15-20 reps',
    ),
  ];

  Set<EquipmentType> get _resolvedEquipmentTypes {
    final types = <EquipmentType>{};
    for (final id in _selectedEquipmentIds) {
      final found = _equipmentList.where((e) => e.id == id).firstOrNull;
      if (found != null) {
        types.add(found.type);
      }
    }
    if (types.isEmpty) {
      types.add(EquipmentType.bodyweight);
    }
    return types;
  }

  void _applyEquipmentPreset(String preset) {
    HapticFeedback.selectionClick();
    setState(() {
      if (preset == 'full_gym') {
        _selectedEquipmentIds.clear();
        _selectedEquipmentIds.addAll(_equipmentList.map((e) => e.id));
      } else if (preset == 'home_dumbbell') {
        _selectedEquipmentIds.clear();
        _selectedEquipmentIds.addAll(['db', 'bench', 'bw', 'band']);
      } else if (preset == 'bodyweight') {
        _selectedEquipmentIds.clear();
        _selectedEquipmentIds.addAll(['bw', 'pullup_bar', 'band']);
      } else if (preset == 'saved_profile') {
        final saved = ref.read(userEquipmentProvider);
        if (saved.isNotEmpty) {
          _selectedEquipmentIds.clear();
          _selectedEquipmentIds.addAll(saved);
        } else {
          _selectedEquipmentIds.clear();
          _selectedEquipmentIds.addAll(['db', 'bb', 'bench', 'bw']);
        }
      }
    });
  }

  void _applyMusclePreset(String split) {
    HapticFeedback.selectionClick();
    setState(() {
      if (split == 'all') {
        _selectedMuscles.clear();
        _selectedMuscles.addAll(_allMuscles.map((m) => m.name));
      } else if (split == 'upper') {
        _selectedMuscles.clear();
        _selectedMuscles.addAll([
          'Cơ ngực',
          'Cơ vai',
          'Cơ lưng xô',
          'Cơ lưng trên',
          'Cơ tay trước',
          'Cơ tay sau',
          'Cơ cầu vai',
          'Cơ cẳng tay',
          'Cơ cổ',
        ]);
      } else if (split == 'lower') {
        _selectedMuscles.clear();
        _selectedMuscles.addAll([
          'Cơ đùi trước',
          'Cơ đùi sau',
          'Cơ mông',
          'Cơ bắp chân',
          'Cơ dạng hông',
          'Cơ khép hông',
          'Cơ bụng',
        ]);
      } else if (split == 'push') {
        _selectedMuscles.clear();
        _selectedMuscles.addAll(['Cơ ngực', 'Cơ vai', 'Cơ tay sau']);
      } else if (split == 'pull') {
        _selectedMuscles.clear();
        _selectedMuscles.addAll([
          'Cơ lưng xô',
          'Cơ lưng trên',
          'Cơ tay trước',
          'Cơ cầu vai',
          'Cơ cẳng tay',
        ]);
      }
    });
  }

  String _getSetsRepsRecommendation() {
    if (_goal.contains('Strength')) {
      return '4 hiệp × 5-6 reps (Nghỉ 120s)';
    } else if (_goal.contains('Fat Burn')) {
      return '3 hiệp × 12-15 reps (Nghỉ 45s)';
    } else if (_goal.contains('Mobility')) {
      return '3 hiệp × 15-20 reps (Nghỉ 60s)';
    }
    return '4 hiệp × 8-12 reps (Nghỉ 75-90s)';
  }

  Future<void> _generatePlan() async {
    HapticFeedback.mediumImpact();
    setState(() => _isGenerating = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));

    final availableTypes = _resolvedEquipmentTypes;
    final targetMusclesLower = _selectedMuscles
        .map((m) => m.toLowerCase())
        .toList();

    final matchingExercises = exerciseCatalog.where((ex) {
      final matchesEquipment = availableTypes.contains(ex.equipment);
      final primaryLower = ex.primaryMuscle.toLowerCase();
      final secondaryLower = ex.secondaryMuscles
          .map((m) => m.toLowerCase())
          .toList();

      final matchesMuscle = targetMusclesLower.any((rawM) {
        // Strip prefix "cơ "
        final m = rawM.startsWith('cơ ') ? rawM.substring(3).trim() : rawM.trim();

        if (m.contains('ngực') && (primaryLower.contains('ngực') || secondaryLower.any((s) => s.contains('ngực')))) {
          return true;
        }
        if (m.contains('vai') &&
            (primaryLower.contains('vai') ||
                secondaryLower.any((s) => s.contains('vai')))) {
          return true;
        }
        if ((m.contains('lưng xô') || m.contains('lưng trên') || m.contains('lưng dưới') || m.contains('xô') || m.contains('lưng')) &&
            (primaryLower.contains('lưng') || primaryLower.contains('xô') || secondaryLower.any((s) => s.contains('lưng') || s.contains('xô')))) {
          return true;
        }
        if (m.contains('cầu vai') &&
            (primaryLower.contains('cầu vai') || primaryLower.contains('vai') || secondaryLower.any((s) => s.contains('vai')))) {
          return true;
        }
        if (m.contains('cổ') &&
            (primaryLower.contains('cổ') || primaryLower.contains('vai'))) {
          return true;
        }
        if (m.contains('tay trước') &&
            (primaryLower.contains('tay trước') || secondaryLower.any((s) => s.contains('tay trước')))) {
          return true;
        }
        if (m.contains('tay sau') &&
            (primaryLower.contains('tay sau') || secondaryLower.any((s) => s.contains('tay sau')))) {
          return true;
        }
        if (m.contains('cẳng tay') &&
            (primaryLower.contains('cẳng tay') || primaryLower.contains('tay') || secondaryLower.any((s) => s.contains('tay')))) {
          return true;
        }
        if (m.contains('đùi trước') &&
            (primaryLower.contains('đùi trước') || primaryLower.contains('quad') || secondaryLower.any((s) => s.contains('đùi trước')))) {
          return true;
        }
        if (m.contains('đùi sau') &&
            (primaryLower.contains('đùi sau') ||
                primaryLower.contains('mông') ||
                secondaryLower.any((s) => s.contains('đùi sau') || s.contains('mông')))) {
          return true;
        }
        if (m.contains('mông') &&
            (primaryLower.contains('mông') || primaryLower.contains('đùi') || secondaryLower.any((s) => s.contains('mông')))) {
          return true;
        }
        if (m.contains('bắp chân') &&
            (primaryLower.contains('bắp chân') || primaryLower.contains('chân') || secondaryLower.any((s) => s.contains('chân')))) {
          return true;
        }
        if ((m.contains('dạng hông') || m.contains('khép hông')) &&
            (primaryLower.contains('mông') || primaryLower.contains('đùi') || secondaryLower.any((s) => s.contains('đùi')))) {
          return true;
        }
        if (m.contains('bụng') &&
            (primaryLower.contains('bụng') || primaryLower.contains('core') || secondaryLower.any((s) => s.contains('bụng')))) {
          return true;
        }
        return primaryLower.contains(m) || primaryLower.contains(rawM);
      });

      return matchesEquipment && matchesMuscle;
    }).toList();

    int targetCount = 4;
    if (_durationMinutes <= 30) {
      targetCount = 3;
    } else if (_durationMinutes >= 60) {
      targetCount = 5;
    }
    if (_durationMinutes >= 75) {
      targetCount = 6;
    }

    final selectedList = <ExerciseDefinition>[];
    if (matchingExercises.isNotEmpty) {
      final pool = [...matchingExercises];
      pool.shuffle();
      selectedList.addAll(pool.take(targetCount));
    }

    if (selectedList.length < targetCount) {
      final fallbackPool = exerciseCatalog
          .where((ex) => availableTypes.contains(ex.equipment))
          .toList();
      fallbackPool.shuffle();
      for (final ex in fallbackPool) {
        if (!selectedList.any((s) => s.id == ex.id)) {
          selectedList.add(ex);
          if (selectedList.length >= targetCount) break;
        }
      }
    }

    if (mounted) {
      setState(() {
        _isGenerating = false;
        _generated = true;
        _generatedExercises = selectedList.isNotEmpty
            ? selectedList
            : exerciseCatalog.take(4).toList();
      });
    }
  }

  Future<_PlanApplyMode?> _chooseApplyMode(WorkoutSessionState session) {
    return showDialog<_PlanApplyMode>(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;
        final completedSetsCount = session.logs.values
            .expand((l) => l)
            .where((s) => s.completed)
            .length;
        final hasProgress = completedSetsCount > 0;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(
              color: colors.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          backgroundColor: colors.surfaceContainer,
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_motion_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Hôm nay đã có buổi tập',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        hasProgress
                            ? Icons.trending_up_rounded
                            : Icons.fitness_center_rounded,
                        size: 18,
                        color: hasProgress ? AppColors.green : AppColors.blue,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.title.isNotEmpty
                                  ? session.title
                                  : 'Buổi tập hiện tại',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              hasProgress
                                  ? 'Đã hoàn thành $completedSetsCount hiệp tập'
                                  : 'Đang có ${session.exercises.length} bài tập được lên lịch',
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Option 1: Append (Recommended)
                Material(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () =>
                        Navigator.pop(dialogContext, _PlanApplyMode.append),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.6),
                          width: 1.4,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.add_circle_outline_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Thêm vào buổi hiện tại',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Khuyên dùng',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Ghép thêm ${_generatedExercises.length} bài tập AI vào cuối buổi tập và giữ nguyên 100% các hiệp đã hoàn thành.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: colors.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Option 2: Replace
                Material(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () =>
                        Navigator.pop(dialogContext, _PlanApplyMode.replace),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colors.outlineVariant.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.swap_horiz_rounded,
                                color: colors.onSurfaceVariant,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Thay thế',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Hủy toàn bộ bài tập cũ chưa hoàn thành và thay mới bằng ${_generatedExercises.length} bài tập AI vừa tạo.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: colors.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(
                foregroundColor: colors.onSurfaceVariant,
              ),
              child: const Text(
                'Hủy',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _applyPlan() async {
    HapticFeedback.lightImpact();
    final scheduleState = ref.read(workoutScheduleProvider);
    final sessionState = ref.read(workoutSessionProvider);
    final requestedDate =
        widget.initialDate ??
        DateTime.tryParse(scheduleState.selectedDate) ??
        DateTime.now();
    final selectedDate = _formatDate(DateUtils.dateOnly(requestedDate));
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final newTitle = 'AI Giáo án: ${_selectedMuscles.join(' - ')}';
    final isAdditionalWorkout =
        selectedDate == todayStr &&
        (scheduleState.isTodayWorkoutCompleted || sessionState.isFinalized);
    final hasActiveWorkoutToday =
        !_generateWholeWeek &&
        selectedDate == todayStr &&
        sessionState.exercises.isNotEmpty &&
        !sessionState.isFinalized;
    var applyMode = _PlanApplyMode.replace;
    if (hasActiveWorkoutToday) {
      final selectedMode = await _chooseApplyMode(sessionState);
      if (selectedMode == null || !mounted) return;
      applyMode = selectedMode;
    }

    if (!hasActiveWorkoutToday) {
      try {
        setState(() => _isGenerating = true);
        final selected = DateTime.parse(selectedDate);
        var weekStart = selected.subtract(Duration(days: selected.weekday - 1));
        final today = DateUtils.dateOnly(DateTime.now());
        if (weekStart.add(const Duration(days: 6)).isBefore(today)) {
          weekStart = weekStart.add(const Duration(days: 7));
        }
        final dates = _generateWholeWeek
            ? _buildAiWeekDates(weekStart: weekStart, today: today)
            : [selected];
        final repository = ref.read(workoutSchedulePlanningRepositoryProvider);
        final initialDrafts = dates.asMap().entries.map((entry) {
          final rotated = [
            ..._generatedExercises.skip(entry.key),
            ..._generatedExercises.take(entry.key),
          ];
          return ScheduleDraftDay(
            date: entry.value,
            time: '17:30',
            title: _generateWholeWeek
                ? '$newTitle — Buổi ${entry.key + 1}'
                : newTitle,
            exercises: rotated
                .map(
                  (exercise) => ScheduleDraftExercise(
                    exercise: exercise,
                    targetSets: 3,
                    targetRepsMin: 8,
                    targetRepsMax: 12,
                    restSeconds: 90,
                  ),
                )
                .toList(),
          );
        }).toList();

        ScheduleProposalView proposal;
        try {
          proposal = await repository.createDirectProposal(
            sourceType: 'AI',
            days: initialDrafts,
          );
        } catch (_) {
          proposal = ScheduleProposalView(
            id: 0,
            sourceType: 'AI',
            scope: initialDrafts.length == 1 ? 'ONE_DAY' : 'WEEK',
            expiresAt: DateTime.now().add(const Duration(minutes: 30)),
            items: initialDrafts
                .map(
                  (d) => ScheduleProposalItemView(
                    date: d.date,
                    time: d.time,
                    title: d.title,
                    exerciseCount: d.exercises.length,
                  ),
                )
                .toList(),
          );
        }

        if (!mounted) return;
        setState(() => _isGenerating = false);
        final result = await showScheduleProposalDialog(context, proposal);
        if (result == null || !result.confirmed || !mounted) return;
        setState(() => _isGenerating = true);

        var effectiveDrafts = initialDrafts;
        if (result.items.isNotEmpty) {
          effectiveDrafts = List.generate(initialDrafts.length, (index) {
            final original = initialDrafts[index];
            if (index < result.items.length) {
              final updatedItem = result.items[index];
              return ScheduleDraftDay(
                date: updatedItem.date,
                time: updatedItem.time,
                title: original.title,
                exercises: original.exercises,
              );
            }
            return original;
          });
        }

        if (proposal.id > 0) {
          try {
            final bool changed = List.generate(
              initialDrafts.length,
              (i) =>
                  i < effectiveDrafts.length &&
                  (initialDrafts[i].date != effectiveDrafts[i].date ||
                      initialDrafts[i].time != effectiveDrafts[i].time),
            ).any((c) => c);

            final proposalToApply = changed
                ? await repository.createDirectProposal(
                    sourceType: 'AI',
                    days: effectiveDrafts,
                  )
                : proposal;

            final applied = await repository.applyProposal(proposalToApply.id);
            if (!mounted) return;
            ref
                .read(workoutScheduleProvider.notifier)
                .mergeAppliedSchedules(
                  applied.indexed.map((entry) {
                    final item = entry.$2;
                    final draft = entry.$1 < effectiveDrafts.length
                        ? effectiveDrafts[entry.$1]
                        : null;
                    return WorkoutScheduleItem(
                      id: 'server_${item.id}',
                      date:
                          '${item.date.year}-${item.date.month.toString().padLeft(2, '0')}-${item.date.day.toString().padLeft(2, '0')}',
                      time: item.time.substring(0, 5),
                      title: item.title,
                      targetMuscles: draft == null
                          ? _selectedMuscles.join(' • ')
                          : draft.exercises
                                .map((e) => e.exercise.primaryMuscle)
                                .toSet()
                                .join(' • '),
                      durationMinutes: _durationMinutes.round(),
                      plannedExercises: draft == null
                          ? const []
                          : draft.exercises
                                .map(
                                  (exercise) => PlannedExercisePreview(
                                    name: exercise.exercise.name,
                                    setsReps:
                                        '${exercise.targetSets}x${exercise.targetRepsMin}-${exercise.targetRepsMax}',
                                  ),
                                )
                                .toList(),
                    );
                  }).toList(),
                );
            if (applied.isNotEmpty) {
              ref
                  .read(workoutScheduleProvider.notifier)
                  .selectDate(_formatDate(applied.first.date));
            }
            final todayDraft = effectiveDrafts
                .where((d) => _formatDate(d.date) == todayStr)
                .firstOrNull;
            if (todayDraft != null && todayDraft.exercises.isNotEmpty) {
              ref
                  .read(workoutSessionProvider.notifier)
                  .setSession(
                    title: todayDraft.title,
                    exercises: todayDraft.exercises
                        .map(
                          (e) => SessionExercise(
                            exerciseId: e.exercise.id,
                            name: e.exercise.name,
                            primaryMuscle: e.exercise.primaryMuscle,
                            equipment: e.exercise.equipment,
                            targetSets: e.targetSets,
                            targetReps: e.targetRepsMin,
                            weightKg:
                                e.exercise.equipment == EquipmentType.bodyweight
                                ? 0
                                : 25,
                            thumbnailUrl: e.exercise.thumbnailUrl,
                          ),
                        )
                        .toList(),
                  );
            } else if (!_generateWholeWeek &&
                selectedDate == todayStr &&
                _generatedExercises.isNotEmpty) {
              ref
                  .read(workoutSessionProvider.notifier)
                  .setSession(
                    title: newTitle,
                    exercises: _generatedExercises
                        .map(
                          (exercise) => SessionExercise(
                            exerciseId: exercise.id,
                            name: exercise.name,
                            primaryMuscle: exercise.primaryMuscle,
                            equipment: exercise.equipment,
                            targetSets: 3,
                            targetReps: 10,
                            weightKg:
                                exercise.equipment == EquipmentType.bodyweight
                                ? 0
                                : 25,
                            thumbnailUrl: exercise.thumbnailUrl,
                          ),
                        )
                        .toList(),
                  );
            }
            setState(() => _isGenerating = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _generateWholeWeek
                      ? 'Đã áp dụng ${applied.length} buổi AI vào lịch tuần.'
                      : 'Đã áp dụng giáo án AI vào lịch tập thành công!',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.go('/workout');
            return;
          } catch (_) {
            // Fall through to local merge below
          }
        }

        // Local merge fallback
        final scheduleNotifier = ref.read(workoutScheduleProvider.notifier);
        for (final draft in effectiveDrafts) {
          final dateStr =
              '${draft.date.year}-${draft.date.month.toString().padLeft(2, '0')}-${draft.date.day.toString().padLeft(2, '0')}';
          scheduleNotifier.addSchedule(
            title: draft.title,
            targetMuscles: _selectedMuscles.join(' • '),
            durationMinutes: _durationMinutes.round(),
            date: dateStr,
            time: draft.time,
            plannedExercises: _generatedExercises
                .map(
                  (exercise) => PlannedExercisePreview(
                    name: exercise.name,
                    setsReps: _getSetsRepsRecommendation(),
                  ),
                )
                .toList(),
          );
        }

        final todayDraftFallback = effectiveDrafts
            .where((d) => _formatDate(d.date) == todayStr)
            .firstOrNull;
        if (todayDraftFallback != null &&
            todayDraftFallback.exercises.isNotEmpty) {
          ref
              .read(workoutSessionProvider.notifier)
              .setSession(
                title: todayDraftFallback.title,
                exercises: todayDraftFallback.exercises
                    .map(
                      (e) => SessionExercise(
                        exerciseId: e.exercise.id,
                        name: e.exercise.name,
                        primaryMuscle: e.exercise.primaryMuscle,
                        equipment: e.exercise.equipment,
                        targetSets: e.targetSets,
                        targetReps: e.targetRepsMin,
                        weightKg:
                            e.exercise.equipment == EquipmentType.bodyweight
                            ? 0
                            : 25,
                        thumbnailUrl: e.exercise.thumbnailUrl,
                      ),
                    )
                    .toList(),
              );
        } else if (!_generateWholeWeek &&
            selectedDate == todayStr &&
            _generatedExercises.isNotEmpty) {
          ref
              .read(workoutSessionProvider.notifier)
              .setSession(
                title: newTitle,
                exercises: _generatedExercises
                    .map(
                      (exercise) => SessionExercise(
                        exerciseId: exercise.id,
                        name: exercise.name,
                        primaryMuscle: exercise.primaryMuscle,
                        equipment: exercise.equipment,
                        targetSets: 3,
                        targetReps: 10,
                        weightKg: exercise.equipment == EquipmentType.bodyweight
                            ? 0
                            : 25,
                        thumbnailUrl: exercise.thumbnailUrl,
                      ),
                    )
                    .toList(),
              );
        }

        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _generateWholeWeek
                  ? 'Đã áp dụng ${effectiveDrafts.length} buổi AI vào lịch tuần.'
                  : 'Đã áp dụng giáo án AI vào lịch tập thành công!',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/workout');
        return;
      } catch (error) {
        if (!mounted) return;
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    final plannedExercises = _generatedExercises
        .map(
          (exercise) => PlannedExercisePreview(
            name: exercise.name,
            setsReps: _getSetsRepsRecommendation(),
          ),
        )
        .toList();
    final scheduleNotifier = ref.read(workoutScheduleProvider.notifier);

    if (hasActiveWorkoutToday && applyMode == _PlanApplyMode.append) {
      final extended = scheduleNotifier.extendLatestPlannedSchedule(
        date: selectedDate,
        targetMuscles: _selectedMuscles.join(', '),
        addedDurationMinutes: _durationMinutes.round(),
        plannedExercises: plannedExercises,
      );
      if (!extended) {
        scheduleNotifier.addSchedule(
          title: sessionState.title,
          targetMuscles: {
            ...sessionState.exercises.map((item) => item.primaryMuscle),
            ..._selectedMuscles,
          }.join(' • '),
          durationMinutes: _durationMinutes.round(),
          date: selectedDate,
          time: '17:30',
          plannedExercises: plannedExercises,
        );
      }
      final sessionNotifier = ref.read(workoutSessionProvider.notifier);
      for (final exercise in _generatedExercises) {
        sessionNotifier.addExercise(exercise);
      }
    } else {
      final replaced =
          hasActiveWorkoutToday &&
          scheduleNotifier.replaceLatestPlannedSchedule(
            date: selectedDate,
            title: newTitle,
            targetMuscles: _selectedMuscles.join(', '),
            durationMinutes: _durationMinutes.round(),
            time: '17:30',
            plannedExercises: plannedExercises,
          );
      if (!replaced) {
        scheduleNotifier.addSchedule(
          title: newTitle,
          targetMuscles: _selectedMuscles.join(', '),
          durationMinutes: _durationMinutes.round(),
          date: selectedDate,
          time: '17:30',
          plannedExercises: plannedExercises,
        );
      }

      if (selectedDate == todayStr && _generatedExercises.isNotEmpty) {
        ref
            .read(workoutSessionProvider.notifier)
            .setSession(
              title: newTitle,
              exercises: _generatedExercises
                  .map(
                    (ex) => SessionExercise(
                      exerciseId: ex.id,
                      name: ex.name,
                      primaryMuscle: ex.primaryMuscle,
                      equipment: ex.equipment,
                      targetSets: 3,
                      targetReps: 10,
                      weightKg: ex.equipment == EquipmentType.bodyweight
                          ? 0
                          : 25,
                      thumbnailUrl: ex.thumbnailUrl,
                    ),
                  )
                  .toList(),
            );
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          hasActiveWorkoutToday && applyMode == _PlanApplyMode.append
              ? 'Đã bổ sung các bài AI và giữ nguyên tiến độ buổi hiện tại.'
              : isAdditionalWorkout
              ? 'Đã tạo buổi tập thêm bằng AI. Buổi đã hoàn thành vẫn được giữ trong lịch sử.'
              : 'Đã áp dụng giáo án AI vào lịch tập thành công!',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.go('/workout');
  }

  static String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  static List<DateTime> _buildAiWeekDates({
    required DateTime weekStart,
    required DateTime today,
  }) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final earliest = today.isAfter(weekStart) ? today : weekStart;
    final dates = <DateTime>[];

    for (final offset in const [0, 2, 4]) {
      final candidate = weekStart.add(Duration(days: offset));
      if (!candidate.isBefore(earliest) && !candidate.isAfter(weekEnd)) {
        dates.add(candidate);
      }
    }
    for (var offset = 0; offset < 7 && dates.length < 3; offset++) {
      final candidate = weekStart.add(Duration(days: offset));
      if (!candidate.isBefore(earliest) && !dates.contains(candidate)) {
        dates.add(candidate);
      }
    }
    dates.sort();
    return dates;
  }

  Future<void> _showMusclePickerModal(BuildContext context) async {
    HapticFeedback.selectionClick();
    final tempSelected = Set<String>.from(_selectedMuscles);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final colors = Theme.of(context).colorScheme;

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.82,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.fitness_center_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Chọn nhóm cơ mục tiêu',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Đang chọn ${tempSelected.length}/${_allMuscles.length} nhóm cơ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(modalContext),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Divider(color: colors.outlineVariant.withValues(alpha: 0.5)),

                  // Quick presets in modal
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                tempSelected.clear();
                                tempSelected.addAll(
                                  _allMuscles.map((m) => m.name),
                                );
                              });
                            },
                            child: const Text('Chọn tất cả'),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                tempSelected.clear();
                                tempSelected.addAll(['Cơ ngực', 'Cơ vai', 'Cơ tay sau']);
                              });
                            },
                            child: const Text('Đẩy (Push)'),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                tempSelected.clear();
                                tempSelected.addAll([
                                  'Cơ lưng xô',
                                  'Cơ lưng trên',
                                  'Cơ tay trước',
                                  'Cơ cầu vai',
                                  'Cơ cẳng tay',
                                ]);
                              });
                            },
                            child: const Text('Kéo (Pull)'),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                tempSelected.clear();
                                tempSelected.addAll([
                                  'Cơ đùi trước',
                                  'Cơ đùi sau',
                                  'Cơ mông',
                                  'Cơ bắp chân',
                                  'Cơ dạng hông',
                                  'Cơ khép hông',
                                ]);
                              });
                            },
                            child: const Text('Chân & Mông'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // List of muscles
                  Flexible(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      shrinkWrap: true,
                      itemCount: _allMuscles.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final muscle = _allMuscles[index];
                        final isSelected = tempSelected.contains(muscle.name) ||
                            tempSelected.contains(muscle.shortName);

                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setModalState(() {
                              if (isSelected) {
                                if (tempSelected.length > 1) {
                                  tempSelected.remove(muscle.name);
                                  tempSelected.remove(muscle.shortName);
                                }
                              } else {
                                tempSelected.add(muscle.name);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.12)
                                  : colors.surfaceContainerHighest.withValues(
                                      alpha: 0.25,
                                    ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : colors.outlineVariant.withValues(
                                        alpha: 0.4,
                                      ),
                                width: isSelected ? 1.4 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                _buildMuscleThumbnail(
                                  muscle,
                                  isSelected: isSelected,
                                  size: 46,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            muscle.name,
                                            style: TextStyle(
                                              fontWeight: isSelected
                                                  ? FontWeight.w800
                                                  : FontWeight.w600,
                                              fontSize: 14,
                                              color: isSelected
                                                  ? AppColors.textPrimary
                                                  : colors.onSurface,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                              vertical: 1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colors
                                                  .surfaceContainerHighest,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              muscle.code,
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                                color: colors.onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        muscle.subtitle,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Checkbox(
                                  value: isSelected,
                                  activeColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  onChanged: (val) {
                                    setModalState(() {
                                      if (isSelected) {
                                        if (tempSelected.length > 1) {
                                          tempSelected.remove(muscle.name);
                                        }
                                      } else {
                                        tempSelected.add(muscle.name);
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom Action
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        setState(() {
                          _selectedMuscles.clear();
                          _selectedMuscles.addAll(tempSelected);
                        });
                        Navigator.pop(modalContext);
                      },
                      child: Text(
                        'Xác nhận (${tempSelected.length} nhóm cơ)',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showEquipmentPickerModal(BuildContext context) async {
    HapticFeedback.selectionClick();
    final tempSelected = Set<String>.from(_selectedEquipmentIds);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final colors = Theme.of(context).colorScheme;

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Chọn thiết bị luyện tập',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Đang chọn ${tempSelected.length}/${_equipmentList.length} thiết bị sẵn có',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(modalContext),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Divider(color: colors.outlineVariant.withValues(alpha: 0.5)),

                  // Quick presets in modal
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                tempSelected.clear();
                                tempSelected.addAll(
                                  _equipmentList.map((e) => e.id),
                                );
                              });
                            },
                            child: const Text('Tất cả (11)'),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                tempSelected.clear();
                                tempSelected.addAll([
                                  'db',
                                  'bench',
                                  'bw',
                                  'band',
                                ]);
                              });
                            },
                            child: const Text('Tạ đơn tại nhà'),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                tempSelected.clear();
                                tempSelected.addAll([
                                  'bw',
                                  'pullup_bar',
                                  'band',
                                ]);
                              });
                            },
                            child: const Text('Bodyweight'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // List of 11 equipments
                  Flexible(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      shrinkWrap: true,
                      itemCount: _equipmentList.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final eq = _equipmentList[index];
                        final isSelected = tempSelected.contains(eq.id);

                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setModalState(() {
                              if (isSelected) {
                                if (tempSelected.length > 1) {
                                  tempSelected.remove(eq.id);
                                }
                              } else {
                                tempSelected.add(eq.id);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest.withValues(
                                alpha: 0.25,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colors.outlineVariant.withValues(
                                  alpha: 0.4,
                                ),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    eq.icon,
                                    size: 18,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        eq.name,
                                        style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          fontSize: 13.5,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        eq.category,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Checkbox(
                                  value: isSelected,
                                  activeColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  onChanged: (val) {
                                    setModalState(() {
                                      if (isSelected) {
                                        if (tempSelected.length > 1) {
                                          tempSelected.remove(eq.id);
                                        }
                                      } else {
                                        tempSelected.add(eq.id);
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom Action
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        setState(() {
                          _selectedEquipmentIds.clear();
                          _selectedEquipmentIds.addAll(tempSelected);
                        });
                        Navigator.pop(modalContext);
                      },
                      child: Text(
                        'Xác nhận (${tempSelected.length} thiết bị)',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final selectedMuscleItems = _allMuscles
        .where((m) =>
            _selectedMuscles.contains(m.name) ||
            _selectedMuscles.contains(m.shortName) ||
            _selectedMuscles.contains(m.code))
        .toList();

    final selectedEquipmentItems = _equipmentList
        .where((e) => _selectedEquipmentIds.contains(e.id))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text(
          'AI Tạo buổi tập',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Đặt lại mặc định',
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedMuscles.clear();
                _selectedMuscles.addAll(['Cơ ngực', 'Cơ vai']);
                _applyEquipmentPreset('full_gym');
                _durationMinutes = 45;
                _generateWholeWeek = false;
                _goal = 'Tăng cơ nạc (Hypertrophy)';
                _generated = false;
                _generatedExercises.clear();
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── AI Hero Banner Card ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  width: 1.2,
                ),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.12),
                    colors.surfaceContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Workout Generator',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Tạo buổi tập chuẩn khoa học theo cơ địa, mục tiêu & thiết bị sẵn có',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── Section 1: Nhóm cơ mục tiêu ──────────────────────────────
            _buildSectionHeader(
              step: '1',
              title: '1. Chọn nhóm cơ mục tiêu',
              subtitle: 'Gạt sang trái để huỷ chọn, hoặc bấm thêm nhóm cơ',
              trailing: Text(
                '${_selectedMuscles.length}/${_allMuscles.length} nhóm cơ',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Quick Muscle Split Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _PresetChip(
                    label: 'Toàn thân (17)',
                    isSelected: _selectedMuscles.length == _allMuscles.length,
                    onTap: () => _applyMusclePreset('all'),
                  ),
                  const SizedBox(width: 8),
                  _PresetChip(
                    label: 'Thân trên',
                    isSelected:
                        (_selectedMuscles.contains('Cơ ngực') || _selectedMuscles.contains('Ngực')) &&
                        (_selectedMuscles.contains('Cơ lưng xô') || _selectedMuscles.contains('Lưng xô')) &&
                        _selectedMuscles.length == 9,
                    onTap: () => _applyMusclePreset('upper'),
                  ),
                  const SizedBox(width: 8),
                  _PresetChip(
                    label: 'Thân dưới & Core',
                    isSelected:
                        (_selectedMuscles.contains('Cơ đùi trước') || _selectedMuscles.contains('Đùi trước')) &&
                        (_selectedMuscles.contains('Cơ đùi sau') || _selectedMuscles.contains('Đùi sau')) &&
                        _selectedMuscles.length == 7,
                    onTap: () => _applyMusclePreset('lower'),
                  ),
                  const SizedBox(width: 8),
                  _PresetChip(
                    label: 'Đẩy (Push)',
                    isSelected:
                        (_selectedMuscles.contains('Cơ ngực') || _selectedMuscles.contains('Ngực')) &&
                        (_selectedMuscles.contains('Cơ vai') || _selectedMuscles.contains('Vai')) &&
                        _selectedMuscles.length == 3,
                    onTap: () => _applyMusclePreset('push'),
                  ),
                  const SizedBox(width: 8),
                  _PresetChip(
                    label: 'Kéo (Pull)',
                    isSelected:
                        (_selectedMuscles.contains('Cơ lưng xô') || _selectedMuscles.contains('Lưng xô')) &&
                        (_selectedMuscles.contains('Cơ tay trước') || _selectedMuscles.contains('Tay trước')) &&
                        _selectedMuscles.length == 5,
                    onTap: () => _applyMusclePreset('pull'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Muscle List Control Bar (Title + Add Button)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nhóm cơ đã chọn (${_selectedMuscles.length})',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _showMusclePickerModal(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Thêm nhóm cơ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Selected Muscles List with Swipe-to-Dismiss (Gạt trái để huỷ chọn)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: selectedMuscleItems.length,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final muscle = selectedMuscleItems[index];

                return Dismissible(
                  key: ValueKey('muscle_${muscle.name}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Hủy chọn',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    if (_selectedMuscles.length <= 1) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Vui lòng giữ lại ít nhất 1 nhóm cơ mục tiêu',
                          ),
                          duration: Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return false;
                    }
                    return true;
                  },
                  onDismissed: (direction) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedMuscles.remove(muscle.name);
                    });
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã hủy chọn: ${muscle.name}'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'Hoàn tác',
                          textColor: AppColors.primary,
                          onPressed: () {
                            setState(() {
                              _selectedMuscles.add(muscle.name);
                            });
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainer,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildMuscleThumbnail(
                          muscle,
                          isSelected: true,
                          size: 42,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                muscle.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                muscle.subtitle,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Gạt trái',
                              style: TextStyle(
                                fontSize: 10,
                                color: colors.onSurfaceVariant.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 10,
                              color: colors.onSurfaceVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                if (_selectedMuscles.length <= 1) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Vui lòng giữ lại ít nhất 1 nhóm cơ mục tiêu',
                                      ),
                                      duration: Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _selectedMuscles.remove(muscle.name);
                                  _selectedMuscles.remove(muscle.shortName);
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),

            // ── Section 2: Thiết bị tập luyện có sẵn ─────────────────────
            _buildSectionHeader(
              step: '2',
              title: '2. Thiết bị tập luyện có sẵn',
              subtitle: 'Gạt sang trái để huỷ chọn, hoặc bấm thêm thiết bị',
              trailing: Text(
                '${_selectedEquipmentIds.length}/${_equipmentList.length} thiết bị',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Equipment Presets
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _PresetChip(
                    label: 'Đầy đủ phòng Gym',
                    icon: Icons.fitness_center_rounded,
                    isSelected:
                        _selectedEquipmentIds.length == _equipmentList.length,
                    onTap: () => _applyEquipmentPreset('full_gym'),
                  ),
                  const SizedBox(width: 8),
                  _PresetChip(
                    label: 'Tạ đơn tại nhà',
                    icon: Icons.home_rounded,
                    isSelected:
                        _selectedEquipmentIds.contains('db') &&
                        _selectedEquipmentIds.contains('bench') &&
                        !_selectedEquipmentIds.contains('machine') &&
                        !_selectedEquipmentIds.contains('cable'),
                    onTap: () => _applyEquipmentPreset('home_dumbbell'),
                  ),
                  const SizedBox(width: 8),
                  _PresetChip(
                    label: 'Bodyweight (Không dụng cụ)',
                    icon: Icons.accessibility_new_rounded,
                    isSelected:
                        _selectedEquipmentIds.length <= 3 &&
                        _selectedEquipmentIds.contains('bw') &&
                        !_selectedEquipmentIds.contains('db') &&
                        !_selectedEquipmentIds.contains('bb'),
                    onTap: () => _applyEquipmentPreset('bodyweight'),
                  ),
                  const SizedBox(width: 8),
                  _PresetChip(
                    label: 'Từ hồ sơ đã lưu',
                    icon: Icons.sync_rounded,
                    isSelected: false,
                    onTap: () => _applyEquipmentPreset('saved_profile'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Equipment List Control Bar (Title + Add Button)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Thiết bị đã chọn (${_selectedEquipmentIds.length})',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _showEquipmentPickerModal(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Thêm thiết bị',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Selected Equipment List with Swipe-to-Dismiss (Gạt trái để huỷ chọn)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: selectedEquipmentItems.length,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final eq = selectedEquipmentItems[index];

                return Dismissible(
                  key: ValueKey('eq_${eq.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Hủy chọn',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    if (_selectedEquipmentIds.length <= 1) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Vui lòng giữ lại ít nhất 1 thiết bị hoặc thể trọng',
                          ),
                          duration: Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return false;
                    }
                    return true;
                  },
                  onDismissed: (direction) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedEquipmentIds.remove(eq.id);
                    });
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã hủy chọn: ${eq.name}'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'Hoàn tác',
                          textColor: AppColors.primary,
                          onPressed: () {
                            setState(() {
                              _selectedEquipmentIds.add(eq.id);
                            });
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainer,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            eq.icon,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                eq.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                eq.category,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Gạt trái',
                              style: TextStyle(
                                fontSize: 10,
                                color: colors.onSurfaceVariant.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 10,
                              color: colors.onSurfaceVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                if (_selectedEquipmentIds.length <= 1) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Vui lòng giữ lại ít nhất 1 thiết bị hoặc thể trọng',
                                      ),
                                      duration: Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _selectedEquipmentIds.remove(eq.id);
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),

            // ── Section 3: Thời lượng buổi tập & Scope ────────────────────
            _buildSectionHeader(
              step: '3',
              title: '3. Thời lượng buổi tập',
              subtitle:
                  'AI tự động tính toán số hiệp và bài tập phù hợp thời lượng',
              trailing: Text(
                '${_durationMinutes.round()} phút',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [30, 45, 60, 75, 90].map((mins) {
                      final isSel = _durationMinutes.round() == mins;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _durationMinutes = mins.toDouble());
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isSel
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSel
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            '$mins\'',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isSel
                                  ? FontWeight.w900
                                  : FontWeight.w600,
                              color: isSel
                                  ? AppColors.primary
                                  : colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 6),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: colors.surfaceContainerHighest,
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withValues(alpha: 0.15),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _durationMinutes,
                      min: 30,
                      max: 90,
                      divisions: 4,
                      label: '${_durationMinutes.round()} phút',
                      onChanged: (val) =>
                          setState(() => _durationMinutes = val),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Scope Selector
            _buildSectionHeader(
              step: '+',
              title: 'Phạm vi lịch tập',
              subtitle: 'Tạo một buổi hoặc phân bổ 3 buổi trong cùng một tuần',
            ),
            const SizedBox(height: 10),
            SegmentedButton<bool>(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                  states,
                ) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.primary.withValues(alpha: 0.15);
                  }
                  return colors.surfaceContainer;
                }),
                side: WidgetStateProperty.all(
                  BorderSide(
                    color: colors.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
              ),
              segments: const [
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.today_rounded, size: 18),
                  label: Text('Một ngày'),
                ),
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.date_range_rounded, size: 18),
                  label: Text('Cả tuần'),
                ),
              ],
              selected: {_generateWholeWeek},
              onSelectionChanged: (selection) {
                HapticFeedback.selectionClick();
                setState(() => _generateWholeWeek = selection.first);
              },
            ),
            const SizedBox(height: 18),

            // ── Section 4: Trọng tâm buổi tập ────────────────────────────
            _buildSectionHeader(
              step: '4',
              title: '4. Trọng tâm buổi tập',
              subtitle:
                  'AI thiết lập mức tạ, số hiệp & thời gian nghỉ tương ứng',
            ),
            const SizedBox(height: 10),

            // 2x2 Clean Goal Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _goals.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                mainAxisExtent: 68,
              ),
              itemBuilder: (context, index) {
                final item = _goals[index];
                final title = item.$1;
                final icon = item.$3;
                final repsHint = item.$4;
                final isSelected = _goal == title;

                return _GoalGridCard(
                  title: title,
                  icon: icon,
                  repsHint: repsHint,
                  isSelected: isSelected,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _goal = title);
                  },
                );
              },
            ),
            const SizedBox(height: 20),

            // ── Primary AI Generate Button ────────────────────────────────
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _isGenerating ? null : _generatePlan,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isGenerating)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        else
                          const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        const SizedBox(width: 10),
                        Text(
                          _isGenerating
                              ? 'AI Đang phân tích sinh trắc & giáo án...'
                              : 'AI Tạo giáo án tối ưu',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Generated Plan Preview Section ────────────────────────────
            if (_generated) ...[
              const SizedBox(height: 24),
              Divider(color: colors.outlineVariant.withValues(alpha: 0.6)),
              const SizedBox(height: 14),

              // Plan Summary Header Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Đề xuất: ${_selectedMuscles.join(' + ')} (${_generatedExercises.length} bài)',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            '${_durationMinutes.round()}p • ${_goal.split(' ').first}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Giáo án được tối ưu theo cơ chế lũy tiến (${_goal.split(' ').first}) với thời gian nghỉ và cường độ bài tập đã cân đối.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: colors.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Generated Exercise List
              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: _generatedExercises.asMap().entries.map((entry) {
                    final index = entry.key;
                    final ex = entry.value;
                    final isLast = index == _generatedExercises.length - 1;

                    return Column(
                      children: [
                        _ExercisePreviewRow(
                          number: index + 1,
                          exercise: ex,
                          sets: _getSetsRepsRecommendation(),
                        ),
                        if (!isLast)
                          Divider(
                            color: colors.outlineVariant.withValues(alpha: 0.5),
                            height: 14,
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Brand Primary CTA: Apply Plan to Schedule
              FilledButton.icon(
                onPressed: _applyPlan,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.add_task_rounded, size: 20),
                label: const Text(
                  'Áp dụng giáo án này vào lịch tập',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMuscleThumbnail(
    _MuscleVisualItem muscle, {
    bool isSelected = false,
    double size = 44,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.12),
          width: isSelected ? 1.4 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: BodyMuscleMap(
          bodySide: muscle.muscleGroup.primarySide,
          primaryMuscles: {muscle.muscleGroup},
          focusedMuscle: muscle.muscleGroup,
          isZoomed: true,
          autoZoom: true,
          interactive: false,
          showContainerFrame: false,
          height: size,
          width: size,
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String step,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    step,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            if (trailing != null) trailing,
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6.5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.14)
              : colors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : colors.outlineVariant.withValues(alpha: 0.6),
            width: isSelected ? 1.3 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13.5,
                color: isSelected
                    ? AppColors.primary
                    : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.primary : colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalGridCard extends StatelessWidget {
  const _GoalGridCard({
    required this.title,
    required this.icon,
    required this.repsHint,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final String repsHint;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final shortTitle = title.split(' (').first;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : colors.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : colors.outlineVariant.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : colors.surfaceContainerHighest.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.primary : colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    shortTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w900
                          : FontWeight.w700,
                      color: isSelected
                          ? AppColors.textPrimary
                          : colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    repsHint,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                size: 15,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _ExercisePreviewRow extends StatelessWidget {
  const _ExercisePreviewRow({
    required this.number,
    required this.exercise,
    required this.sets,
  });

  final int number;
  final ExerciseDefinition exercise;
  final String sets;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          ExerciseThumbnail(
            exerciseId: exercise.id,
            imageUrl: exercise.thumbnailUrl,
            size: 44,
            borderRadius: 10,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (exercise.nameVi.isNotEmpty &&
                    exercise.nameVi != exercise.name) ...[
                  const SizedBox(height: 1),
                  Text(
                    exercise.nameVi,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  sets,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ExerciseTagChip.muscle(label: exercise.primaryMuscle),
              const SizedBox(height: 4),
              ExerciseTagChip.equipment(label: exercise.equipment.label),
            ],
          ),
        ],
      ),
    );
  }
}
