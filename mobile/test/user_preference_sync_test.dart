import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viegym/features/profile/application/user_preference_controller.dart';
import 'package:viegym/features/profile/data/preference_repository.dart';

void main() {
  test(
    'loads server preferences and saves injuries without losing other fields',
    () async {
      final repository = _FakePreferenceRepository({
        'dislikedFoods': ['Khổ qua'],
        'allergies': ['Hải sản'],
        'dietaryConstraints': ['NO_PORK'],
        'injuries': ['KNEE'],
        'preferredTrainingTime': '18:30:00',
        'mealPreferences': {'preferredCuisine': 'VIETNAMESE', 'mealsPerDay': 3},
        'trainingPreferences': {'daysPerWeek': 4},
      });
      final container = ProviderContainer(
        overrides: [preferenceRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      container.read(userPreferencesProvider);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      var prefs = container.read(userPreferencesProvider);
      expect(prefs.allergies, ['Hải sản']);
      expect(prefs.mealsPerDay, 3);
      expect(prefs.injuries, {InjuryArea.knee});

      final notifier = container.read(userPreferencesProvider.notifier);
      notifier.toggleInjury(InjuryArea.lowerBack);
      notifier.toggleInjury(InjuryArea.knee);
      notifier.addAllergy('Đậu phộng');
      await notifier.save();

      final sent = repository.saved!;
      expect(sent['injuries'], ['LOWER_BACK']);
      expect(sent['allergies'], ['Hải sản', 'Đậu phộng']);
      expect(sent['dietaryConstraints'], ['NO_PORK']);
      expect(sent['preferredTrainingTime'], '18:30:00');
      expect(
        (sent['mealPreferences'] as Map)['preferredCuisine'],
        'VIETNAMESE',
      );
      expect((sent['trainingPreferences'] as Map)['daysPerWeek'], 4);
      prefs = container.read(userPreferencesProvider);
      expect(prefs.injuries, {InjuryArea.lowerBack});
    },
  );

  test('starts empty instead of with made-up allergies', () {
    const prefs = UserPreferences();
    expect(prefs.allergies, isEmpty);
    expect(prefs.dislikedFoods, isEmpty);
  });
}

class _FakePreferenceRepository extends PreferenceRepository {
  _FakePreferenceRepository(this._document) : super(Dio());

  Map<String, dynamic> _document;
  Map<String, dynamic>? saved;

  @override
  Future<Map<String, dynamic>> get() async => _document;

  @override
  Future<Map<String, dynamic>> replace(Map<String, dynamic> document) async {
    saved = document;
    _document = document;
    return document;
  }
}
