import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../data/nutrition_repository.dart';

class MealTemplatesState {
  const MealTemplatesState({
    this.templates = const [],
    this.isLoading = false,
    this.error,
  });
  final List<MealTemplateApi> templates;
  final bool isLoading;
  final String? error;
}

class MealTemplatesController extends Notifier<MealTemplatesState> {
  @override
  MealTemplatesState build() {
    final authenticated = ref.read(authProvider).isAuthenticated;
    if (authenticated) Future.microtask(refresh);
    return MealTemplatesState(isLoading: authenticated);
  }

  Future<void> refresh() async {
    state = MealTemplatesState(templates: state.templates, isLoading: true);
    try {
      final templates = await ref
          .read(nutritionRepositoryProvider)
          .getTemplates();
      if (!ref.mounted) return;
      state = MealTemplatesState(templates: templates);
    } catch (error) {
      if (!ref.mounted) return;
      state = MealTemplatesState(templates: state.templates, error: '$error');
    }
  }

  Future<void> saveCurrentPlan(String name, int sourceMealPlanId) async {
    await ref
        .read(nutritionRepositoryProvider)
        .saveCurrentPlanAsTemplate(
          name: name,
          sourceMealPlanId: sourceMealPlanId,
        );
    await refresh();
  }

  Future<TemplateApplyApi> apply(int id, String targetDate) {
    return ref.read(nutritionRepositoryProvider).applyTemplate(id, targetDate);
  }
}

final mealTemplatesProvider =
    NotifierProvider<MealTemplatesController, MealTemplatesState>(
      MealTemplatesController.new,
    );
