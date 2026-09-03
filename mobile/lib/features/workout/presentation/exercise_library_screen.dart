import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/exercise_tag_chip.dart';
import '../../../shared/widgets/loading_view.dart';
import '../application/exercise_catalog_controller.dart';
import '../application/favorite_exercises_controller.dart';
import '../domain/workout_models.dart';
import 'widgets/exercise_filter_modal.dart';

class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({
    super.key,
    this.isPicker = false,
    this.isMultiSelect = false,
    this.title = 'Thư viện bài tập',
    this.onSelect,
    this.onMultiSelect,
  });

  final bool isPicker;
  final bool isMultiSelect;
  final String title;
  final ValueChanged<ExerciseDefinition>? onSelect;
  final ValueChanged<List<ExerciseDefinition>>? onMultiSelect;

  @override
  ConsumerState<ExerciseLibraryScreen> createState() =>
      _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen> {
  String _searchQuery = '';
  Set<String> _selectedMuscles = {};
  Set<int> _selectedEquipmentIds = {};
  bool _onlyFavorites = false;
  final Set<String> _selectedExerciseIds = {};
  final Map<String, ExerciseDefinition> _selectedExercisesMap = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exerciseCatalogControllerProvider.notifier).loadInitial();
    });
  }

  Future<void> _openFilterModal(int initialTab) async {
    final result = await ExerciseFilterModal.show(
      context,
      initialTab: initialTab,
      selectedMuscles: _selectedMuscles,
      selectedEquipmentIds: _selectedEquipmentIds,
    );

    if (result != null) {
      setState(() {
        _selectedMuscles = result.selectedMuscles;
        _selectedEquipmentIds = result.selectedEquipmentIds;
      });
    }
  }

  void _resetAllFilters() {
    setState(() {
      _searchQuery = '';
      _selectedMuscles.clear();
      _selectedEquipmentIds.clear();
      _onlyFavorites = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final favoriteIds = ref.watch(favoriteExercisesProvider);
    final catalogState = ref.watch(exerciseCatalogControllerProvider);
    final normalized = _searchQuery.toLowerCase().trim();

    final displayExercises = catalogState.exercises;

    final filtered = displayExercises.where((exercise) {
      // 0. Favorite Filter
      if (_onlyFavorites && !favoriteIds.contains(exercise.id)) {
        return false;
      }

      // 1. Text Query Search
      final matchesQuery =
          normalized.isEmpty ||
          exercise.name.toLowerCase().contains(normalized) ||
          exercise.nameVi.toLowerCase().contains(normalized) ||
          exercise.primaryMuscle.toLowerCase().contains(normalized) ||
          exercise.equipment.label.toLowerCase().contains(normalized);

      // 2. Muscle Filter
      final matchesMuscle =
          _selectedMuscles.isEmpty ||
          _selectedMuscles.any(
            (m) =>
                exercise.primaryMuscle.toLowerCase().contains(
                  m.toLowerCase(),
                ) ||
                exercise.secondaryMuscles.any(
                  (sm) => sm.toLowerCase().contains(m.toLowerCase()),
                ),
          );

      // 3. Equipment Filter
      final matchesEquipment =
          _selectedEquipmentIds.isEmpty ||
          exercise.equipmentIds.any(_selectedEquipmentIds.contains);

      return matchesQuery && matchesMuscle && matchesEquipment;
    }).toList();

    final hasActiveFilters =
        _selectedMuscles.isNotEmpty ||
        _selectedEquipmentIds.isNotEmpty ||
        _onlyFavorites;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(widget.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Tìm theo tên bài tập, nhóm cơ, thiết bị',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                isDense: true,
                filled: true,
                fillColor: const Color(0xFF141724),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: colors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),

          // 2. Filter Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Favorite Filter Button
                  _FilterActionButton(
                    icon: _onlyFavorites
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    label: 'Yêu thích',
                    count: favoriteIds.length,
                    isActive: _onlyFavorites,
                    onTap: () =>
                        setState(() => _onlyFavorites = !_onlyFavorites),
                  ),
                  const SizedBox(width: 8),

                  // Muscle Filter Button
                  _FilterActionButton(
                    icon: Icons.filter_alt_outlined,
                    label: 'Nhóm cơ',
                    count: _selectedMuscles.length,
                    isActive: _selectedMuscles.isNotEmpty,
                    onTap: () => _openFilterModal(1),
                  ),
                  const SizedBox(width: 8),

                  // Equipment Filter Button
                  _FilterActionButton(
                    icon: Icons.filter_alt_outlined,
                    label: 'Thiết bị',
                    count: _selectedEquipmentIds.length,
                    isActive: _selectedEquipmentIds.isNotEmpty,
                    onTap: () => _openFilterModal(2),
                  ),
                  const SizedBox(width: 12),

                  // All Filters text button
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _openFilterModal(0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                      child: Text(
                        'Tất cả bộ lọc',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: hasActiveFilters
                              ? colors.primary
                              : const Color(0xFF7E849E),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Section Title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DANH SÁCH BÀI TẬP (${filtered.length})',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7E849E),
                    letterSpacing: 0.8,
                  ),
                ),
                if (hasActiveFilters || _searchQuery.isNotEmpty)
                  InkWell(
                    onTap: _resetAllFilters,
                    child: Text(
                      'Xóa bộ lọc',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 4. Exercise List
          Expanded(
            child: (catalogState.isLoading && catalogState.exercises.isEmpty)
                ? const LoadingView(message: 'Đang tải danh sách bài tập...')
                : (catalogState.error != null && catalogState.exercises.isEmpty)
                ? ErrorView(
                    message:
                        'Không thể tải danh sách bài tập. Vui lòng kiểm tra kết nối đến máy chủ.',
                    onRetry: () => ref
                        .read(exerciseCatalogControllerProvider.notifier)
                        .loadInitial(),
                  )
                : filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: colors.surfaceContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.search_off_rounded,
                              size: 32,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Không tìm thấy bài tập phù hợp',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Hãy thử thay đổi từ khóa, nhóm cơ hoặc thiết bị.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 20),
                          FilledButton.tonal(
                            onPressed: _resetAllFilters,
                            child: const Text('Đặt lại bộ lọc'),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await ref
                          .read(exerciseCatalogControllerProvider.notifier)
                          .loadInitial();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final exercise = filtered[index];
                        final isSelected = _selectedExerciseIds.contains(
                          exercise.id,
                        );

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          color: (widget.isMultiSelect && isSelected)
                              ? colors.primary.withValues(alpha: 0.08)
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                              color: (widget.isMultiSelect && isSelected)
                                  ? colors.primary
                                  : colors.outlineVariant.withValues(
                                      alpha: 0.4,
                                    ),
                              width: (widget.isMultiSelect && isSelected)
                                  ? 1.8
                                  : 1.0,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              if (widget.isPicker) {
                                if (widget.isMultiSelect) {
                                  setState(() {
                                    if (_selectedExerciseIds.contains(
                                      exercise.id,
                                    )) {
                                      _selectedExerciseIds.remove(exercise.id);
                                      _selectedExercisesMap.remove(exercise.id);
                                    } else {
                                      _selectedExerciseIds.add(exercise.id);
                                      _selectedExercisesMap[exercise.id] =
                                          exercise;
                                    }
                                  });
                                } else {
                                  if (widget.onSelect != null) {
                                    widget.onSelect!(exercise);
                                  }
                                  if (GoRouter.maybeOf(context) != null &&
                                      context.canPop()) {
                                    context.pop(exercise);
                                  } else if (Navigator.of(context).canPop()) {
                                    Navigator.of(context).pop(exercise);
                                  }
                                }
                              } else {
                                context.push('/exercise/${exercise.id}');
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Thumbnail Image
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: const Color(0xFF1B1E2E),
                                      border: Border.all(
                                        color: colors.outlineVariant.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(13),
                                      child: Image.network(
                                        exercise.thumbnailUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (
                                              context,
                                              error,
                                              stackTrace,
                                            ) => Center(
                                              child: Icon(
                                                Icons.fitness_center_rounded,
                                                color: colors.primary,
                                                size: 26,
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Exercise Info & Reusable Tags
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exercise.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          exercise.nameVi,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: colors.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 8),

                                        // Reusable Tags Row
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: [
                                            ExerciseTagChip.muscle(
                                              label: exercise.primaryMuscle,
                                            ),
                                            ExerciseTagChip.equipment(
                                              label: exercise.equipment.label,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 8),
                                  // Favorite button
                                  InkWell(
                                    borderRadius: BorderRadius.circular(99),
                                    onTap: () {
                                      ref
                                          .read(
                                            favoriteExercisesProvider.notifier,
                                          )
                                          .toggleFavorite(exercise.id);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: Icon(
                                        favoriteIds.contains(exercise.id)
                                            ? Icons.favorite_rounded
                                            : Icons.favorite_border_rounded,
                                        color: favoriteIds.contains(exercise.id)
                                            ? colors.primary
                                            : colors.onSurfaceVariant
                                                  .withValues(alpha: 0.6),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),

                                  // Picker radio / checkbox / chevron action
                                  if (widget.isPicker && widget.isMultiSelect)
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? colors.primary
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected
                                              ? colors.primary
                                              : colors.outlineVariant
                                                    .withValues(alpha: 0.6),
                                          width: 1.8,
                                        ),
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check_rounded,
                                              color: Colors.white,
                                              size: 18,
                                            )
                                          : null,
                                    )
                                  else if (widget.isPicker)
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: colors.primary,
                                          width: 1.8,
                                        ),
                                      ),
                                    )
                                  else
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: colors.onSurfaceVariant.withValues(
                                        alpha: 0.5,
                                      ),
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: widget.isMultiSelect
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  border: Border(
                    top: BorderSide(
                      color: colors.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đã chọn ${_selectedExerciseIds.length} bài tập',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            _selectedExerciseIds.isEmpty
                                ? 'Chạm vào bài tập để chọn'
                                : 'Sẵn sàng thêm vào buổi tập',
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _selectedExerciseIds.isEmpty
                          ? null
                          : () {
                              final selectedList = _selectedExercisesMap.values
                                  .toList();
                              if (widget.onMultiSelect != null) {
                                widget.onMultiSelect!(selectedList);
                              }
                              if (GoRouter.maybeOf(context) != null &&
                                  context.canPop()) {
                                context.pop(selectedList);
                              } else if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop(selectedList);
                              }
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        // The app-wide FilledButton theme uses an infinite
                        // minimum width for full-width actions. This button
                        // lives inside a Row, where horizontal constraints are
                        // unbounded while children are measured, so it must
                        // opt out of that global width.
                        minimumSize: const Size(0, 52),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.add_task_rounded, size: 18),
                      label: Text(
                        'Thêm (${_selectedExerciseIds.length})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

class _FilterActionButton extends StatelessWidget {
  const _FilterActionButton({
    required this.icon,
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? colors.primary.withValues(alpha: 0.12)
              : const Color(0xFF141724),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive
                ? colors.primary.withValues(alpha: 0.6)
                : colors.outlineVariant.withValues(alpha: 0.6),
            width: isActive ? 1.2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive
                  ? colors.primary
                  : colors.primary.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 6),
            Text(
              count > 0 ? '$label · $count' : label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isActive ? Colors.white : const Color(0xFFD4D8E8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
