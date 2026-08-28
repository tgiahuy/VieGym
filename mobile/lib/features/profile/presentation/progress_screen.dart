import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/progress_controller.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 1RM Calculator state
  double _calcWeight = 80.0;
  int _calcReps = 8;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showLogWeightDialog(BuildContext context) {
    final weightController = TextEditingController(text: '67.0');
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
    final state = ref.watch(progressProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Tiến độ & Thống kê'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colors.primary,
          labelColor: colors.primary,
          unselectedLabelColor: colors.onSurfaceVariant,
          tabs: const [
            Tab(text: 'Tổng quan'),
            Tab(text: 'Cân nặng'),
            Tab(text: 'Kỷ lục & 1RM'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: OVERVIEW
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              // Weekly Goal Card
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: colors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Mục tiêu tuần này',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${state.completedWorkoutsThisWeek}/${state.targetWorkoutsPerWeek} Buổi (${(state.weeklyCompletionRatio * 100).round()}%)',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.greenAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: state.weeklyCompletionRatio,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Bạn chỉ còn 1 buổi nữa để hoàn thành mục tiêu tuần!',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Highlight Metrics (2x2 Grid)
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: Colors.amber,
                      label: 'CHUỖI TẬP (STREAK)',
                      value: '${state.currentStreakDays} ngày',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.fitness_center_rounded,
                      iconColor: Colors.greenAccent,
                      label: 'TỔNG VOLUME',
                      value:
                          '${(state.totalVolumeKg / 1000).toStringAsFixed(1)} tấn',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.timer_outlined,
                      iconColor: Colors.blueAccent,
                      label: 'THỜI GIAN TẬP',
                      value: '${state.totalWorkoutMinutes} phút',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.emoji_events_rounded,
                      iconColor: Colors.purpleAccent,
                      label: 'KỶ LỤC MỚI',
                      value: '${state.personalRecords.length} PRs',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Quick Actions
              FilledButton.icon(
                onPressed: () => context.push('/workout/history'),
                icon: const Icon(Icons.history_rounded),
                label: const Text('Xem toàn bộ lịch sử buổi tập'),
              ),
            ],
          ),

          // TAB 2: BODY WEIGHT TREND
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              // Current Weight Card
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cân nặng gần nhất',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.weightLogs.isNotEmpty
                                ? '${state.weightLogs.first.weightKg} kg'
                                : '67.0 kg',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      FilledButton.icon(
                        onPressed: () => _showLogWeightDialog(context),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Ghi nhận'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Lịch sử theo dõi cân nặng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),

              ...state.weightLogs.map((log) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.monitor_weight_outlined, size: 20),
                    ),
                    title: Text(
                      '${log.weightKg} kg',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    trailing: Text(
                      log.date,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),

          // TAB 3: RECORDS & 1RM CALCULATOR
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              // 1RM Calculator Card
              Card(
                margin: EdgeInsets.zero,
                color: colors.primary.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: colors.primary.withValues(alpha: 0.4),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calculate_rounded, color: colors.primary),
                          const SizedBox(width: 8),
                          const Text(
                            'Máy tính 1RM (One Rep Max)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _calcWeight.toStringAsFixed(0),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Mức tạ (kg)',
                                isDense: true,
                              ),
                              onChanged: (val) {
                                final parsed = double.tryParse(val);
                                if (parsed != null) {
                                  setState(() => _calcWeight = parsed);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: '$_calcReps',
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Số reps',
                                isDense: true,
                              ),
                              onChanged: (val) {
                                final parsed = int.tryParse(val);
                                if (parsed != null) {
                                  setState(() => _calcReps = parsed);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'ƯỚC TÍNH 1RM:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '${ProgressController.calculate1Rm(_calcWeight, _calcReps).toStringAsFixed(1)} kg',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Kỷ lục cá nhân (PR)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),

              ...state.personalRecords.map((pr) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.emoji_events_rounded, color: Colors.amber),
                    ),
                    title: Text(
                      pr.exerciseName,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      '${pr.weightKg.toStringAsFixed(0)} kg × ${pr.reps} reps • 1RM ≈ ${pr.calculated1Rm.toStringAsFixed(1)} kg',
                    ),
                    trailing: Text(
                      pr.date,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: colors.onSurfaceVariant,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
