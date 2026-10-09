import 'package:test/test.dart';
import 'package:viegym_api/viegym_api.dart';

/// tests for NutritionControllerApi
void main() {
  final instance = ViegymApi().getNutritionControllerApi();

  group(NutritionControllerApi, () {
    //Future<ApiResponseMealPlan> addEntry(DateTime planDate, MealEntryRequest mealEntryRequest) async
    test('test addEntry', () async {
      // TODO
    });

    //Future<ApiResponseVoid> addFavorite(int foodId) async
    test('test addFavorite', () async {
      // TODO
    });

    //Future<ApiResponseApplyTemplateResult> applyTemplate(int id, ApplyMealTemplateRequest applyMealTemplateRequest) async
    test('test applyTemplate', () async {
      // TODO
    });

    //Future<ApiResponseMealTemplate> createTemplate(CreateMealTemplateRequest createMealTemplateRequest) async
    test('test createTemplate', () async {
      // TODO
    });

    //Future deleteEntry(DateTime planDate, int entryId) async
    test('test deleteEntry', () async {
      // TODO
    });

    //Future deleteTemplate(int id) async
    test('test deleteTemplate', () async {
      // TODO
    });

    //Future<ApiResponsePageResponseFood> favorites({ String q, int page, int size }) async
    test('test favorites', () async {
      // TODO
    });

    //Future<ApiResponseFood> food(int id) async
    test('test food', () async {
      // TODO
    });

    //Future<ApiResponsePageResponseFood> foods({ String q, String category, int page, int size, String sort }) async
    test('test foods', () async {
      // TODO
    });

    //Future<ApiResponsePageResponseMealPlan> mealHistory({ int page, int size }) async
    test('test mealHistory', () async {
      // TODO
    });

    //Future<ApiResponseMealPlan> mealPlan(DateTime date) async
    test('test mealPlan', () async {
      // TODO
    });

    //Future<ApiResponseVoid> removeFavorite(int foodId) async
    test('test removeFavorite', () async {
      // TODO
    });

    //Future<ApiResponseMealTemplate> template(int id) async
    test('test template', () async {
      // TODO
    });

    //Future<ApiResponseListMealTemplate> templates() async
    test('test templates', () async {
      // TODO
    });

    //Future<ApiResponseMealPlan> updateEntry(DateTime planDate, int entryId, MealEntryRequest mealEntryRequest) async
    test('test updateEntry', () async {
      // TODO
    });

    //Future<ApiResponseMealTemplate> updateTemplate(int id, CreateMealTemplateRequest createMealTemplateRequest) async
    test('test updateTemplate', () async {
      // TODO
    });
  });
}
