import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_controller.dart';
import '../../onboarding/application/health_profile_controller.dart';
import '../../workout/domain/muscle_models.dart';
import '../../workout/presentation/widgets/body_muscle_map.dart';
import '../application/progress_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  BodySide _bodySide = BodySide.front;

  void _showLogWeightDialog(BuildContext context) {
    final healthProfile = ref.read(healthProfileProvider);
    final weightController = TextEditingController(
      text: healthProfile.weightKg > 0
          ? healthProfile.weightKg.toStringAsFixed(1)
          : '70.2',
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Ghi nhận cân nặng hôm nay'),
          content: TextField(
            controller: weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Cân nặng',
              suffixText: 'kg',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                final val = double.tryParse(weightController.text);
                if (val != null) {
                  ref.read(progressProvider.notifier).logWeight(val);
                }
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã ghi nhận cân nặng mới!')),
                );
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final healthProfile = ref.watch(healthProfileProvider);
    final progressState = ref.watch(progressProvider);

    final userName = healthProfile.nickname.isNotEmpty
        ? healthProfile.nickname
        : (authState.user?.displayName ?? 'Gia Huy');
    final userEmail = authState.user?.email ?? 'viegym.user@gmail.com';

    final double currentWeight =
        (healthProfile.weightKg > 0 ? healthProfile.weightKg : 70.2).toDouble();
    final double targetWeight =
        (healthProfile.targetWeightKg > 0 ? healthProfile.targetWeightKg : 68.0)
            .toDouble();
    final double heightCm =
        (healthProfile.heightCm > 0 ? healthProfile.heightCm : 172.0)
            .toDouble();
    final double bmi = (healthProfile.bmi > 0 ? healthProfile.bmi : 23.73)
        .toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cá nhân',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Cài đặt',
            onPressed: () => context.push('/profile/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          // ==========================================
          // 1. User Information Card
          // ==========================================
          _UserInformationCard(
            userName: userName,
            userEmail: userEmail,
            streakDays: progressState.currentStreakDays,
            completedWorkouts: progressState.completedWorkoutsThisWeek,
            onTap: () => context.push('/profile/user'),
          ),
          const SizedBox(height: 16),

          // ==========================================
          // 2. Physical Metrics Section (CHỈ SỐ THỂ CHẤT - 1 Ô NGANG)
          // ==========================================
          _PhysicalMetricsSection(
            weightKg: currentWeight,
            heightCm: heightCm,
            bmi: bmi,
            onEdit: () => context.push('/profile/health'),
          ),
          const SizedBox(height: 18),

          // ==========================================
          // 3. Muscle Group Distribution (ĐẶT BÊN DƯỚI CHỈ SỐ THỂ CHẤT)
          // ==========================================
          _PersonalMuscleDistributionCard(
            bodySide: _bodySide,
            onBodySideChanged: (side) => setState(() => _bodySide = side),
          ),
          const SizedBox(height: 20),

          // ==========================================
          // 4. Weekly Summary Metric Cards (THỐNG KÊ TUẦN NÀY - THỜI LƯỢNG & NĂNG LƯỢNG)
          // ==========================================
          _WeeklySummarySection(
            totalMinutes: progressState.totalWorkoutMinutes,
            completedWorkouts: progressState.completedWorkoutsThisWeek,
          ),
          const SizedBox(height: 20),

          // ==========================================
          // 5. Daily Workout Volume Chart (CÓ TỔNG KHỐI LƯỢNG CẢ TUẦN)
          // ==========================================
          _PersonalDailyVolumeCard(totalVolumeKg: progressState.totalVolumeKg),
          const SizedBox(height: 20),

          // ==========================================
          // 6. Weight Trend (XU HƯỚNG CÂN NẶNG - 30 Ngày)
          // ==========================================
          _PersonalWeightTrendCard(
            currentWeightKg: currentWeight,
            targetWeightKg: targetWeight,
            bmi: bmi,
            weightLogs: progressState.weightLogs,
            onLogWeight: () => _showLogWeightDialog(context),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. User Information Card
// ─────────────────────────────────────────────────────────────────────────────
class _UserInformationCard extends StatelessWidget {
  const _UserInformationCard({
    required this.userName,
    required this.userEmail,
    required this.streakDays,
    required this.completedWorkouts,
    required this.onTap,
  });

  final String userName;
  final String userEmail;
  final int streakDays;
  final int completedWorkouts;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with Gradient Ring
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [colors.primary, const Color(0xFFFF5277)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(2.5),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF161922),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'G',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // User Details with 2 compact rounded pill chips below name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 2 Compact rounded pill chips below name
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: colors.primary.withValues(alpha: 0.35),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 11)),
                              const SizedBox(width: 3),
                              Text(
                                '$streakDays ngày',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: colors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: colors.outlineVariant.withValues(
                                alpha: 0.4,
                              ),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('💪', style: TextStyle(fontSize: 11)),
                              const SizedBox(width: 3),
                              Text(
                                '$completedWorkouts buổi/tuần',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Physical Metrics Section (1 Ô Ngang)
// ─────────────────────────────────────────────────────────────────────────────
class _PhysicalMetricsSection extends StatelessWidget {
  const _PhysicalMetricsSection({
    required this.weightKg,
    required this.heightCm,
    required this.bmi,
    required this.onEdit,
  });

  final double weightKg;
  final double heightCm;
  final double bmi;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'CHỈ SỐ THỂ CHẤT',
                maxLines: 2,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: colors.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onEdit,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 14, color: colors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Chỉnh sửa',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Single Horizontal Card (1 Ô Ngang) for 3 Metrics
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _PhysicalMetricHorizontalItem(
                  label: 'CÂN NẶNG',
                  value: '${weightKg.toStringAsFixed(1)} kg',
                  subtitle: '↓ 1.3 kg',
                  subtitleColor: Colors.greenAccent,
                  icon: Icons.monitor_weight_outlined,
                ),
              ),
              Container(
                width: 1,
                height: 38,
                color: colors.outlineVariant.withValues(alpha: 0.4),
              ),
              Expanded(
                child: _PhysicalMetricHorizontalItem(
                  label: 'CHIỀU CAO',
                  value: '${heightCm.toInt()} cm',
                  subtitle: 'Chuẩn thể trạng',
                  subtitleColor: colors.onSurfaceVariant,
                  icon: Icons.height_rounded,
                ),
              ),
              Container(
                width: 1,
                height: 38,
                color: colors.outlineVariant.withValues(alpha: 0.4),
              ),
              Expanded(
                child: _PhysicalMetricHorizontalItem(
                  label: 'BMI',
                  value: bmi.toStringAsFixed(1),
                  subtitle: 'Bình thường',
                  subtitleColor: Colors.greenAccent,
                  valueColor: Colors.greenAccent,
                  icon: Icons.speed_rounded,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhysicalMetricHorizontalItem extends StatelessWidget {
  const _PhysicalMetricHorizontalItem({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.subtitleColor,
    this.valueColor,
    required this.icon,
  });

  final String label;
  final String value;
  final String subtitle;
  final Color subtitleColor;
  final Color? valueColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: colors.onSurfaceVariant),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurfaceVariant,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w900,
              color: valueColor ?? colors.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: subtitleColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Weekly Summary Section (Chỉ còn Thời lượng tập & Năng lượng tiêu thụ)
// ─────────────────────────────────────────────────────────────────────────────
class _WeeklySummarySection extends StatelessWidget {
  const _WeeklySummarySection({
    required this.totalMinutes,
    required this.completedWorkouts,
  });

  final int totalMinutes;
  final int completedWorkouts;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THỐNG KÊ TUẦN NÀY',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: colors.onSurface.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8),
        // 2-card row for Training Duration & Energy Burned
        Row(
          children: [
            Expanded(
              child: _PersonalMetricTile(
                title: 'THỜI LƯỢNG TẬP',
                value: '${totalMinutes > 0 ? totalMinutes : 105} phút',
                subtitle: 'Trung bình ~53 phút/buổi',
                subtitleColor: colors.onSurfaceVariant,
                icon: Icons.access_time_filled_rounded,
                iconColor: colors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PersonalMetricTile(
                title: 'NĂNG LƯỢNG TIÊU THỤ',
                value: '~788 kcal',
                subtitle: 'Từ $completedWorkouts buổi hoàn thành',
                subtitleColor: colors.onSurfaceVariant,
                icon: Icons.bolt_rounded,
                iconColor: Colors.orangeAccent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PersonalMetricTile extends StatelessWidget {
  const _PersonalMetricTile({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.subtitleColor,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color subtitleColor;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurfaceVariant,
                  letterSpacing: 0.4,
                  height: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: subtitleColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. Muscle Group Distribution Card
// ─────────────────────────────────────────────────────────────────────────────
class _PersonalMuscleDistributionCard extends StatelessWidget {
  const _PersonalMuscleDistributionCard({
    required this.bodySide,
    required this.onBodySideChanged,
  });

  final BodySide bodySide;
  final ValueChanged<BodySide> onBodySideChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final primaryMuscles = {
      MuscleGroup.chest,
      MuscleGroup.upperChest,
      MuscleGroup.quads,
      MuscleGroup.glutes,
      MuscleGroup.lats,
    };
    final secondaryMuscles = {
      MuscleGroup.frontDelts,
      MuscleGroup.sideDelts,
      MuscleGroup.triceps,
      MuscleGroup.biceps,
      MuscleGroup.hamstrings,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Title & Smart Front/Back Switcher
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.pie_chart_outline_rounded,
                  size: 17,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'PHÂN BỐ NHÓM CƠ',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Mục tiêu tập luyện',
                      style: TextStyle(
                        fontSize: 10,
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: const Color(0xFF161922),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _PersonalSideBtn(
                    label: 'Mặt trước',
                    isSelected: bodySide == BodySide.front,
                    onTap: () => onBodySideChanged(BodySide.front),
                  ),
                ),
                Expanded(
                  child: _PersonalSideBtn(
                    label: 'Mặt sau',
                    isSelected: bodySide == BodySide.back,
                    onTap: () => onBodySideChanged(BodySide.back),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Reusable Body Muscle Map (Centered, complete full body view from head to toes)
          Center(
            child: BodyMuscleMap(
              bodySide: bodySide,
              primaryMuscles: primaryMuscles,
              secondaryMuscles: secondaryMuscles,
              autoZoom: false,
              isZoomed: false,
              height: 340,
            ),
          ),
          const SizedBox(height: 12),

          // Muscle Percentage List
          Text(
            'NHÓM CƠ TRỌNG TÂM:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          const _PersonalMusclePercentRow(
            name: 'Ngực',
            percent: 19,
            color: Color(0xFFFF2E54),
          ),
          const SizedBox(height: 6),
          const _PersonalMusclePercentRow(
            name: 'Chân & Mông',
            percent: 36,
            color: Color(0xFFFF2E54),
          ),
          const SizedBox(height: 6),
          const _PersonalMusclePercentRow(
            name: 'Lưng',
            percent: 29,
            color: Color(0xFFFF2E54),
          ),
          const SizedBox(height: 6),
          const _PersonalMusclePercentRow(
            name: 'Vai',
            percent: 8,
            color: Color(0xFFFF6B8B),
          ),
          const SizedBox(height: 6),
          const _PersonalMusclePercentRow(
            name: 'Tay & Khác',
            percent: 8,
            color: Color(0xFFFF6B8B),
          ),
        ],
      ),
    );
  }
}

class _PersonalSideBtn extends StatelessWidget {
  const _PersonalSideBtn({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? colors.primary.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isSelected ? colors.primary : colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _PersonalMusclePercentRow extends StatelessWidget {
  const _PersonalMusclePercentRow({
    required this.name,
    required this.percent,
    required this.color,
  });

  final String name;
  final int percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final ratio = (percent / 100.0).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 5,
            backgroundColor: colors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. Daily Training Volume Chart Card (Thêm tổng khối lượng cả tuần)
// ─────────────────────────────────────────────────────────────────────────────
class _PersonalDailyVolumeCard extends StatelessWidget {
  const _PersonalDailyVolumeCard({required this.totalVolumeKg});

  final double totalVolumeKg;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final volumeText = totalVolumeKg > 0
        ? '${totalVolumeKg.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} kg'
        : '8.280 kg';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.bar_chart_rounded,
                      size: 16,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KHỐI LƯỢNG TẬP THEO NGÀY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            volumeText,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Tổng cả tuần',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '+8.5% tuần trước',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Bar Chart
          SizedBox(
            height: 145,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _PersonalVolumeBar(
                  label: 'T2',
                  valueKg: 4900,
                  maxKg: 5000,
                  valueLabel: '4.9k',
                  isToday: false,
                ),
                _PersonalVolumeBar(
                  label: 'T3',
                  valueKg: 0,
                  maxKg: 5000,
                  isToday: false,
                ),
                _PersonalVolumeBar(
                  label: 'T4',
                  valueKg: 3400,
                  maxKg: 5000,
                  valueLabel: '3.4k',
                  isToday: false,
                ),
                _PersonalVolumeBar(
                  label: 'T5',
                  valueKg: 0,
                  maxKg: 5000,
                  isToday: false,
                ),
                _PersonalVolumeBar(
                  label: 'T6',
                  valueKg: 0,
                  maxKg: 5000,
                  isToday: true,
                ),
                _PersonalVolumeBar(
                  label: 'T7',
                  valueKg: 0,
                  maxKg: 5000,
                  isToday: false,
                ),
                _PersonalVolumeBar(
                  label: 'CN',
                  valueKg: 0,
                  maxKg: 5000,
                  isToday: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalVolumeBar extends StatelessWidget {
  const _PersonalVolumeBar({
    required this.label,
    required this.valueKg,
    required this.maxKg,
    this.valueLabel,
    required this.isToday,
  });

  final String label;
  final double valueKg;
  final double maxKg;
  final String? valueLabel;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final ratio = (valueKg / maxKg).clamp(0.0, 1.0);
    const maxBarHeight = 96.0;
    final filledHeight = ratio * maxBarHeight;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (valueLabel != null)
          Text(
            valueLabel!,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
          )
        else
          const SizedBox(height: 14),
        const SizedBox(height: 5),
        Container(
          width: 32,
          height: maxBarHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF1E222F),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.bottomCenter,
          child: filledHeight > 0
              ? Container(
                  width: 32,
                  height: filledHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors.primary, const Color(0xFFFF5277)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
            color: isToday ? colors.primary : colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. Weight Trend Card (30 Days)
// ─────────────────────────────────────────────────────────────────────────────
class _PersonalWeightTrendCard extends StatelessWidget {
  const _PersonalWeightTrendCard({
    required this.currentWeightKg,
    required this.targetWeightKg,
    required this.bmi,
    required this.weightLogs,
    required this.onLogWeight,
  });

  final double currentWeightKg;
  final double targetWeightKg;
  final double bmi;
  final List<WeightLogItem> weightLogs;
  final VoidCallback onLogWeight;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Metric, BMI and Change Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.trending_down_rounded,
                      size: 16,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'XU HƯỚNG CÂN NẶNG',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '${currentWeightKg.toStringAsFixed(1)} kg',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'BMI: ${bmi.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '↓ 1.3 kg',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Line Chart with custom painter
          if (weightLogs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'Chưa đủ dữ liệu để hiển thị xu hướng cân nặng.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.tonal(
                      onPressed: onLogWeight,
                      child: const Text('Cập nhật cân nặng'),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 130,
              width: double.infinity,
              child: CustomPaint(
                painter: _PersonalWeightLineChartPainter(
                  logs: weightLogs,
                  targetWeight: targetWeightKg,
                  lineColor: colors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Date Range & Target Label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '01/08',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Mục tiêu: ${targetWeightKg.toStringAsFixed(0)} kg',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                  ),
                ),
                Text(
                  'Hôm nay',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PersonalWeightLineChartPainter extends CustomPainter {
  _PersonalWeightLineChartPainter({
    required this.logs,
    required this.targetWeight,
    required this.lineColor,
  });

  final List<WeightLogItem> logs;
  final double targetWeight;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (logs.isEmpty) return;

    final weights = [69.5, 68.9, 68.3, 67.8, 67.2];
    final minW = targetWeight - 1.0;
    final maxW = 70.5;
    final range = maxW - minW;

    final points = <Offset>[];
    final stepX = size.width / (weights.length - 1);

    for (int i = 0; i < weights.length; i++) {
      final x = i * stepX;
      final yRatio = 1.0 - ((weights[i] - minW) / range).clamp(0.0, 1.0);
      final y = yRatio * (size.height - 20) + 10;
      points.add(Offset(x, y));
    }

    // Draw Target Dashed Line
    final targetYRatio = 1.0 - ((targetWeight - minW) / range).clamp(0.0, 1.0);
    final targetY = targetYRatio * (size.height - 20) + 10;

    final targetPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.35)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, targetY),
        Offset(math.min(startX + 6, size.width), targetY),
        targetPaint,
      );
      startX += 10;
    }

    // Draw Gradient Area under Line
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          lineColor.withValues(alpha: 0.25),
          lineColor.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Draw Line Chart
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final cx = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(linePath, linePaint);

    // Draw Dots on points
    final dotPaint = Paint()..color = Colors.white;
    final dotRingPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (final p in points) {
      canvas.drawCircle(p, 4.0, dotPaint);
      canvas.drawCircle(p, 4.0, dotRingPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
