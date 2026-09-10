import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../onboarding/application/health_profile_controller.dart';
import '../../application/progress_controller.dart';

Future<void> showLogWeightModal(BuildContext context, WidgetRef ref) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => const LogWeightDialog(),
  );
}

class LogWeightDialog extends ConsumerStatefulWidget {
  const LogWeightDialog({super.key});

  @override
  ConsumerState<LogWeightDialog> createState() => _LogWeightDialogState();
}

class _LogWeightDialogState extends ConsumerState<LogWeightDialog> {
  late final TextEditingController _controller;
  double _currentValue = 70.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final healthProfile = ref.read(healthProfileProvider);
    final progress = ref.read(progressProvider);

    final initialWeight = progress.weightLogs.isNotEmpty
        ? progress.weightLogs.first.weightKg
        : (healthProfile.weightKg > 0
              ? healthProfile.weightKg.toDouble()
              : 68.5);

    _currentValue = initialWeight;
    _controller = TextEditingController(text: initialWeight.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _adjustWeight(double delta) {
    setState(() {
      final newVal = (_currentValue + delta).clamp(30.0, 300.0);
      _currentValue = (newVal * 10).roundToDouble() / 10;
      _controller.text = _currentValue.toStringAsFixed(1);
      _errorMessage = null;
    });
  }

  void _onTextChanged(String text) {
    final parsed = double.tryParse(text.replaceAll(',', '.').trim());
    setState(() {
      if (parsed != null && parsed >= 30.0 && parsed <= 300.0) {
        _currentValue = parsed;
        _errorMessage = null;
      } else if (text.trim().isEmpty) {
        _errorMessage = 'Vui lòng nhập cân nặng';
      } else {
        _errorMessage = 'Cân nặng hợp lệ từ 30 đến 300 kg';
      }
    });
  }

  void _save() {
    final parsed = double.tryParse(
      _controller.text.replaceAll(',', '.').trim(),
    );
    if (parsed == null || parsed < 30.0 || parsed > 300.0) {
      setState(() {
        _errorMessage = 'Vui lòng nhập cân nặng hợp lệ (30 - 300 kg)';
      });
      return;
    }

    ref.read(progressProvider.notifier).logWeight(parsed);
    ref.read(healthProfileProvider.notifier).updateWeight(parsed.toInt());

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Đã ghi nhận cân nặng: ${parsed.toStringAsFixed(1)} kg',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderDefault),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final healthProfile = ref.watch(healthProfileProvider);
    final targetWeight = healthProfile.targetWeightKg > 0
        ? healthProfile.targetWeightKg.toDouble()
        : 68.0;

    final diff = _currentValue - targetWeight;
    final diffText = diff.abs() < 0.05
        ? 'Đã đạt mục tiêu ($targetWeight kg) 🎉'
        : (diff > 0
              ? 'Cách mục tiêu +${diff.toStringAsFixed(1)} kg ($targetWeight kg)'
              : 'Dưới mục tiêu ${diff.abs().toStringAsFixed(1)} kg ($targetWeight kg)');

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: colors.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      backgroundColor: AppColors.surface,
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 16, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.monitor_weight_outlined,
                  color: AppColors.cyan,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ghi nhận cân nặng',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 1),
                  Text(
                    'Hôm nay • Cập nhật tiến độ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            tooltip: 'Đóng',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main Input Container
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _errorMessage != null
                      ? AppColors.error
                      : AppColors.borderDefault,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      IntrinsicWidth(
                        child: TextField(
                          controller: _controller,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                            color: AppColors.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: _onTextChanged,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'kg',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.cyan,
                        ),
                      ),
                    ],
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Quick adjustment chips (-1.0, -0.5, -0.1, +0.1, +0.5, +1.0)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                _AdjustmentChip(
                  label: '-0.5',
                  onTap: () => _adjustWeight(-0.5),
                ),
                _AdjustmentChip(
                  label: '-0.1',
                  onTap: () => _adjustWeight(-0.1),
                ),
                _AdjustmentChip(
                  label: '+0.1',
                  onTap: () => _adjustWeight(0.1),
                  isPositive: true,
                ),
                _AdjustmentChip(
                  label: '+0.5',
                  onTap: () => _adjustWeight(0.5),
                  isPositive: true,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Target comparison info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.surfaceNested,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.flag_outlined,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      diffText,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.borderDefault),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Hủy',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Lưu',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AdjustmentChip extends StatelessWidget {
  const _AdjustmentChip({
    required this.label,
    required this.onTap,
    this.isPositive = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surfaceNested,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.borderDefault.withValues(alpha: 0.6),
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isPositive ? AppColors.cyan : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
