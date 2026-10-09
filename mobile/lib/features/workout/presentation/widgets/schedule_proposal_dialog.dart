import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/workout_schedule_planning_repository.dart';

class ScheduleProposalDialogResult {
  const ScheduleProposalDialogResult({
    required this.confirmed,
    required this.items,
  });

  final bool confirmed;
  final List<ScheduleProposalItemView> items;
}

Future<ScheduleProposalDialogResult?> showScheduleProposalDialog(
  BuildContext context,
  ScheduleProposalView proposal,
) async {
  return showModalBottomSheet<ScheduleProposalDialogResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _ScheduleProposalSheet(proposal: proposal),
  );
}

class _ScheduleProposalSheet extends StatefulWidget {
  const _ScheduleProposalSheet({required this.proposal});

  final ScheduleProposalView proposal;

  @override
  State<_ScheduleProposalSheet> createState() => _ScheduleProposalSheetState();
}

class _ScheduleProposalSheetState extends State<_ScheduleProposalSheet> {
  late List<ScheduleProposalItemView> _items;

  @override
  void initState() {
    super.initState();
    _items = List<ScheduleProposalItemView>.from(widget.proposal.items);
  }

  String _formatDayOfWeek(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'T2';
      case DateTime.tuesday:
        return 'T3';
      case DateTime.wednesday:
        return 'T4';
      case DateTime.thursday:
        return 'T5';
      case DateTime.friday:
        return 'T6';
      case DateTime.saturday:
        return 'T7';
      case DateTime.sunday:
        return 'CN';
      default:
        return '';
    }
  }

  String _formatDateShort(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDateForItem(int index) async {
    final currentItem = _items[index];
    final now = DateTime.now();
    final first = now.subtract(const Duration(days: 1));
    final initial = currentItem.date.isBefore(first) ? now : currentItem.date;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2150, 12, 31),
      helpText: 'CHỌN NGÀY TẬP CHO "${currentItem.title}"',
      cancelText: 'HỦY',
      confirmText: 'CHỌN',
      builder: (pickerContext, child) {
        return Theme(
          data: Theme.of(pickerContext).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.cyan,
              onPrimary: Colors.black,
              surface: AppColors.surfaceElevated,
              onSurface: Colors.white,
            ),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _items[index] = _items[index].copyWith(date: picked);
      });
    }
  }

  Future<void> _pickTimeForItem(int index) async {
    final currentItem = _items[index];
    final parts = currentItem.time.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 18 : 18;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      helpText: 'CHỌN GIỜ TẬP CHO "${currentItem.title}"',
      cancelText: 'HỦY',
      confirmText: 'CHỌN',
      builder: (pickerContext, child) {
        return Theme(
          data: Theme.of(pickerContext).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.cyan,
              onPrimary: Colors.black,
              surface: AppColors.surfaceElevated,
              onSurface: Colors.white,
            ),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );

    if (picked != null && mounted) {
      final timeStr =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        _items[index] = _items[index].copyWith(time: timeStr);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Icon(Icons.fact_check_rounded, color: AppColors.cyan),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Xem trước lịch tập',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.proposal.sourceType == 'ADMIN_TEMPLATE'
                        ? 'VieGym Template'
                        : (widget.proposal.sourceType == 'AI'
                            ? 'VieGym AI'
                            : 'Giáo án'),
                    style: const TextStyle(
                      color: AppColors.cyan,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Kiểm tra ngày, giờ và nội dung trước khi thêm vào lịch.',
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.cyan.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.cyan.withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.touch_app_outlined,
                    color: AppColors.cyan,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Chạm vào ô ngày hoặc giờ để chỉnh sửa trước khi áp dụng.',
                      style: TextStyle(
                        color: AppColors.cyan,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final dayOfWeek = _formatDayOfWeek(item.date);
                  final dateFormatted = _formatDateShort(item.date);

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderDefault),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Interactive Date Picker Button
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _pickDateForItem(index),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.cyan.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.cyan.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_rounded,
                                        size: 14,
                                        color: AppColors.cyan,
                                      ),
                                      const SizedBox(width: 6),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            dayOfWeek,
                                            style: const TextStyle(
                                              color: AppColors.textTertiary,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            dateFormatted,
                                            style: const TextStyle(
                                              color: AppColors.cyan,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.edit_calendar_rounded,
                                        size: 13,
                                        color: AppColors.cyan,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      // Interactive Time Picker Button
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => _pickTimeForItem(index),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.surface,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: AppColors.borderDefault,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.access_time_rounded,
                                                  size: 12,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  item.time.length >= 5
                                                      ? item.time.substring(0, 5)
                                                      : item.time,
                                                  style: const TextStyle(
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                const SizedBox(width: 2),
                                                const Icon(
                                                  Icons.arrow_drop_down,
                                                  size: 14,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${item.exerciseCount} bài tập',
                                          style: TextStyle(
                                            color: colors.onSurfaceVariant,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(
                      context,
                      ScheduleProposalDialogResult(
                        confirmed: false,
                        items: _items,
                      ),
                    ),
                    child: const Text('Quay lại'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(
                      context,
                      ScheduleProposalDialogResult(
                        confirmed: true,
                        items: _items,
                      ),
                    ),
                    icon: const Icon(Icons.calendar_month_rounded),
                    label: const Text('Áp dụng lịch'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
