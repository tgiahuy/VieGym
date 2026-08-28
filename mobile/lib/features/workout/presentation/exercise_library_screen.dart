import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/exercise_catalog.dart';
import '../domain/workout_models.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  String query = '';
  EquipmentType? equipment;

  @override
  Widget build(BuildContext context) {
    final normalized = query.toLowerCase();
    final filtered = exerciseCatalog.where((exercise) {
      final matchesQuery =
          exercise.name.toLowerCase().contains(normalized) ||
          exercise.nameVi.toLowerCase().contains(normalized) ||
          exercise.primaryMuscle.toLowerCase().contains(normalized);
      return matchesQuery &&
          (equipment == null || exercise.equipment == equipment);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Thư viện bài tập')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: TextField(
              onChanged: (value) => setState(() => query = value),
              decoration: const InputDecoration(
                hintText: 'Tìm theo tên hoặc nhóm cơ',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                ChoiceChip(
                  label: const Text('Tất cả'),
                  selected: equipment == null,
                  onSelected: (_) => setState(() => equipment = null),
                ),
                const SizedBox(width: 8),
                ...EquipmentType.values.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(item.label),
                      selected: equipment == item,
                      onSelected: (_) => setState(() => equipment = item),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final exercise = filtered[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.fitness_center_rounded),
                    ),
                    title: Text(
                      exercise.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${exercise.nameVi}\n${exercise.primaryMuscle} • ${exercise.equipment.label}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/exercise/${exercise.id}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
