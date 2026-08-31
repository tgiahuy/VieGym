import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/muscle_models.dart';
import '../../domain/workout_models.dart';
import 'body_muscle_map.dart';

class ExerciseFilterResult {
  const ExerciseFilterResult({
    required this.selectedMuscles,
    required this.selectedEquipment,
  });

  final Set<String> selectedMuscles;
  final Set<EquipmentType> selectedEquipment;

  bool get isEmpty => selectedMuscles.isEmpty && selectedEquipment.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

class ExerciseFilterModal extends StatefulWidget {
  const ExerciseFilterModal({
    super.key,
    required this.initialTab,
    required this.selectedMuscles,
    required this.selectedEquipment,
  });

  final int initialTab; // 0 = Tất cả, 1 = Nhóm cơ, 2 = Thiết bị
  final Set<String> selectedMuscles;
  final Set<EquipmentType> selectedEquipment;

  static Future<ExerciseFilterResult?> show(
    BuildContext context, {
    int initialTab = 1,
    Set<String> selectedMuscles = const {},
    Set<EquipmentType> selectedEquipment = const {},
  }) {
    return showModalBottomSheet<ExerciseFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExerciseFilterModal(
        initialTab: initialTab,
        selectedMuscles: selectedMuscles,
        selectedEquipment: selectedEquipment,
      ),
    );
  }

  @override
  State<ExerciseFilterModal> createState() => _ExerciseFilterModalState();
}

class _ExerciseFilterModalState extends State<ExerciseFilterModal> {
  late int _currentTab; // 0 = Tất cả, 1 = Nhóm cơ, 2 = Thiết bị
  late Set<String> _selectedMuscles;
  late Set<EquipmentType> _selectedEquipment;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    _selectedMuscles = Set.from(widget.selectedMuscles);
    _selectedEquipment = Set.from(widget.selectedEquipment);
  }

  void _toggleMuscle(String muscle) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedMuscles.contains(muscle)) {
        _selectedMuscles.remove(muscle);
      } else {
        _selectedMuscles.add(muscle);
      }
    });
  }

  void _toggleEquipment(EquipmentType equip) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedEquipment.contains(equip)) {
        _selectedEquipment.remove(equip);
      } else {
        _selectedEquipment.add(equip);
      }
    });
  }

  void _resetFilters() {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedMuscles.clear();
      _selectedEquipment.clear();
    });
  }

  void _applyFilters() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(
      ExerciseFilterResult(
        selectedMuscles: _selectedMuscles,
        selectedEquipment: _selectedEquipment,
      ),
    );
  }

  String _getHeaderTitle() {
    if (_currentTab == 1) return 'Theo nhóm cơ';
    if (_currentTab == 2) return 'Theo thiết bị';
    return 'Bộ lọc bài tập';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.88,
      decoration: BoxDecoration(
        color: const Color(0xFF0F121C),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: colors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getHeaderTitle(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Chọn nhóm cơ & thiết bị để lọc',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF1E2232),
                    foregroundColor: Colors.white70,
                  ),
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
              ],
            ),
          ),

          // Top Segmented Tab: [ Tất cả ] [ Nhóm cơ ] [ Thiết bị ]
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF161926),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                _buildSegmentTab(
                  0,
                  'Tất cả',
                  count: _selectedMuscles.length + _selectedEquipment.length,
                ),
                _buildSegmentTab(1, 'Nhóm cơ', count: _selectedMuscles.length),
                _buildSegmentTab(
                  2,
                  'Thiết bị',
                  count: _selectedEquipment.length,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Scrollable Filter Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              children: [
                if (_currentTab == 0 || _currentTab == 1) ...[
                  _buildSectionHeader('TORSO (THÂN TRÊN)'),
                  _buildMuscleGroupCard(
                    title: 'Chest',
                    titleVi: 'Cơ ngực',
                    muscleKey: 'Ngực',
                    muscleGroup: MuscleGroup.chest,
                  ),
                  _buildMuscleGroupCard(
                    title: 'Abs',
                    titleVi: 'Cơ bụng / Core',
                    muscleKey: 'Bụng',
                    muscleGroup: MuscleGroup.abs,
                  ),
                  _buildMuscleGroupCard(
                    title: 'Back',
                    titleVi: 'Cơ lưng xô',
                    muscleKey: 'Lưng',
                    muscleGroup: MuscleGroup.lats,
                  ),
                  _buildMuscleGroupCard(
                    title: 'Lower Back',
                    titleVi: 'Lưng dưới',
                    muscleKey: 'Lưng dưới',
                    muscleGroup: MuscleGroup.lowerBack,
                  ),
                  _buildMuscleGroupCard(
                    title: 'Trapezius',
                    titleVi: 'Cơ cầu vai',
                    muscleKey: 'Cầu vai',
                    muscleGroup: MuscleGroup.traps,
                  ),
                  const SizedBox(height: 12),

                  _buildSectionHeader('ARMS & SHOULDERS (TAY & VAI)'),
                  _buildMuscleGroupCard(
                    title: 'Shoulders',
                    titleVi: 'Cơ vai',
                    muscleKey: 'Vai',
                    muscleGroup: MuscleGroup.frontDelts,
                  ),
                  _buildMuscleGroupCard(
                    title: 'Biceps',
                    titleVi: 'Tay trước',
                    muscleKey: 'Tay trước',
                    muscleGroup: MuscleGroup.biceps,
                  ),
                  _buildMuscleGroupCard(
                    title: 'Triceps',
                    titleVi: 'Tay sau',
                    muscleKey: 'Tay sau',
                    muscleGroup: MuscleGroup.triceps,
                  ),
                  _buildMuscleGroupCard(
                    title: 'Forearms',
                    titleVi: 'Cẳng tay',
                    muscleKey: 'Cẳng tay',
                    muscleGroup: MuscleGroup.forearms,
                  ),
                  const SizedBox(height: 12),

                  _buildSectionHeader('LEGS & GLUTES (CHÂN & MÔNG)'),
                  _buildMuscleGroupCard(
                    title: 'Glutes',
                    titleVi: 'Cơ mông',
                    muscleKey: 'Mông',
                    muscleGroup: MuscleGroup.glutes,
                  ),
                  _buildMuscleGroupCard(
                    title: 'Quads',
                    titleVi: 'Đùi trước',
                    muscleKey: 'Đùi trước',
                    muscleGroup: MuscleGroup.quads,
                  ),
                  _buildMuscleGroupCard(
                    title: 'Hamstrings',
                    titleVi: 'Đùi sau',
                    muscleKey: 'Đùi sau',
                    muscleGroup: MuscleGroup.hamstrings,
                  ),
                  _buildMuscleGroupCard(
                    title: 'Calves',
                    titleVi: 'Bắp chân',
                    muscleKey: 'Bắp chân',
                    muscleGroup: MuscleGroup.calves,
                  ),
                ],

                if (_currentTab == 0 || _currentTab == 2) ...[
                  const SizedBox(height: 14),
                  _buildSectionHeader('TẠ TỰ DO (FREE WEIGHTS)'),
                  _buildEquipmentCard(
                    title: 'Tạ đơn (Dumbbell)',
                    subtitle: 'Dumbbell',
                    type: EquipmentType.dumbbell,
                    icon: Icons.fitness_center_rounded,
                  ),
                  _buildEquipmentCard(
                    title: 'Tạ đòn (Barbell)',
                    subtitle: 'Barbell',
                    type: EquipmentType.barbell,
                    icon: Icons.sports_gymnastics_rounded,
                  ),

                  const SizedBox(height: 12),
                  _buildSectionHeader('TỰ THÂN (BODYWEIGHT)'),
                  _buildEquipmentCard(
                    title: 'Trọng lượng cơ thể',
                    subtitle: 'Bodyweight',
                    type: EquipmentType.bodyweight,
                    icon: Icons.directions_run_rounded,
                  ),

                  const SizedBox(height: 12),
                  _buildSectionHeader('MÁY TẬP & CÁP (MACHINES & CABLES)'),
                  _buildEquipmentCard(
                    title: 'Máy tập (Machine)',
                    subtitle: 'Machine',
                    type: EquipmentType.machine,
                    icon: Icons.precision_manufacturing_rounded,
                  ),
                  _buildEquipmentCard(
                    title: 'Máy kéo cáp (Cable)',
                    subtitle: 'Cable Machine',
                    type: EquipmentType.cable,
                    icon: Icons.cable_rounded,
                  ),
                  _buildEquipmentCard(
                    title: 'Ghế tập (Bench)',
                    subtitle: 'Bench',
                    type: EquipmentType.bench,
                    icon: Icons.event_seat_rounded,
                  ),
                ],
              ],
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: const Color(0xFF141724),
              border: Border(
                top: BorderSide(
                  color: colors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search inside filter
                  TextField(
                    onChanged: (val) =>
                        setState(() => _searchQuery = val.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm nhóm cơ hoặc thiết bị...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      fillColor: const Color(0xFF1B1E2E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Actions row
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: OutlinedButton(
                          onPressed: _resetFilters,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            backgroundColor: const Color(0xFF1A1D2C),
                            side: BorderSide(
                              color: colors.outlineVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Đặt lại',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 5,
                        child: FilledButton(
                          onPressed: _applyFilters,
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.primary,
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Áp dụng bộ lọc',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentTab(int tabIndex, String label, {int count = 0}) {
    final isSelected = _currentTab == tabIndex;
    final colors = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _currentTab = tabIndex),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF282D42) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : colors.onSurfaceVariant,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF7E849E),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildMuscleGroupCard({
    required String title,
    required String titleVi,
    required String muscleKey,
    required MuscleGroup muscleGroup,
  }) {
    if (_searchQuery.isNotEmpty &&
        !title.toLowerCase().contains(_searchQuery) &&
        !titleVi.toLowerCase().contains(_searchQuery)) {
      return const SizedBox.shrink();
    }

    final isSelected = _selectedMuscles.contains(muscleKey);
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? colors.primary.withValues(alpha: 0.12)
            : const Color(0xFF151824),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.6)
              : colors.outlineVariant.withValues(alpha: 0.3),
          width: isSelected ? 1.2 : 0.8,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _toggleMuscle(muscleKey),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              // Zoomed Muscle Thumbnail Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D2130),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? colors.primary.withValues(alpha: 0.5)
                        : colors.outlineVariant.withValues(alpha: 0.25),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: BodyMuscleMap(
                    bodySide: muscleGroup.primarySide,
                    primaryMuscles: {muscleGroup},
                    focusedMuscle: muscleGroup,
                    isZoomed: true,
                    autoZoom: true,
                    interactive: false,
                    showContainerFrame: false,
                    height: 48,
                    width: 48,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title and status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$title ',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: '($titleVi)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '100% sẵn sàng',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Selection radio / checkmark
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: colors.primary,
                  size: 22,
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEquipmentCard({
    required String title,
    required String subtitle,
    required EquipmentType type,
    required IconData icon,
  }) {
    if (_searchQuery.isNotEmpty &&
        !title.toLowerCase().contains(_searchQuery) &&
        !subtitle.toLowerCase().contains(_searchQuery)) {
      return const SizedBox.shrink();
    }

    final isSelected = _selectedEquipment.contains(type);
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? colors.primary.withValues(alpha: 0.12)
            : const Color(0xFF151824),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.6)
              : colors.outlineVariant.withValues(alpha: 0.3),
          width: isSelected ? 1.2 : 0.8,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _toggleEquipment(type),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primary.withValues(alpha: 0.2)
                      : const Color(0xFF1D2130),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? colors.primary : Colors.white70,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? colors.primary : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: colors.primary,
                  size: 22,
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
