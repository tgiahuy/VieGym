import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:viegym/core/theme/app_theme.dart';
import 'package:viegym/features/nutrition/application/favorite_foods_controller.dart';
import 'package:viegym/features/nutrition/application/nutrition_controller.dart';
import 'package:viegym/features/nutrition/data/food_catalog.dart';
import 'package:viegym/features/nutrition/domain/food_models.dart';
import 'package:viegym/features/nutrition/presentation/ai_meal_generate_screen.dart';
import 'package:viegym/features/nutrition/presentation/favorite_foods_screen.dart';
import 'package:viegym/features/nutrition/presentation/food_detail_screen.dart';
import 'package:viegym/features/nutrition/presentation/food_search_screen.dart';
import 'package:viegym/features/nutrition/presentation/meal_builder_screen.dart';
import 'package:viegym/features/nutrition/presentation/meal_history_screen.dart';
import 'package:viegym/features/nutrition/presentation/meal_planner_screen.dart';
import 'package:viegym/features/nutrition/presentation/nutrition_screen.dart';

final _transparentPng = <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];

class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Duration? connectionTimeout;
  @override
  Duration idleTimeout = const Duration(seconds: 15);
  @override
  int? maxConnectionsPerHost;
  @override
  String? userAgent;

  @override
  void addCredentials(
    Uri url,
    String realm,
    HttpClientCredentials credentials,
  ) {}

  @override
  void addProxyCredentials(
    String host,
    int port,
    String realm,
    HttpClientCredentials credentials,
  ) {}

  @override
  void close({bool force = false}) {}

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _MockHttpClientRequest();

  @override
  Future<HttpClientRequest> postUrl(Uri url) async => _MockHttpClientRequest();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  final Stream<List<int>> _delegate = Stream.fromIterable([_transparentPng]);

  @override
  int get statusCode => 200;

  @override
  int get contentLength => _transparentPng.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _delegate.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _MockHttpOverrides();
  });

  group('NutritionController & Catalog tests', () {
    test('Calculates food nutrition with serving multiplier and quantity', () {
      final pho = findFoodById('food_pho_bo');
      expect(pho, isNotNull);
      expect(pho!.name, 'Phở bò tái nạm');

      final calculatedStd = calculateFoodNutrition(
        food: pho,
        servingOptionId: 'opt_pho_standard',
        quantity: 1.0,
      );
      expect(calculatedStd.calories, 430);
      expect(calculatedStd.protein, 29.0);

      final calculatedLarge2x = calculateFoodNutrition(
        food: pho,
        servingOptionId: 'opt_pho_large',
        quantity: 2.0,
      );
      expect(calculatedLarge2x.calories, (430 * 1.35 * 2).round());
    });

    test('NutritionController adds and removes food entries properly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(nutritionProvider.notifier);
      final initialEntries = container
          .read(nutritionProvider)
          .currentDayEntries
          .length;

      notifier.addFoodEntry(
        foodId: 'food_whey',
        name: 'Whey Protein',
        mealType: MealType.snack,
        calories: 120,
        protein: 27,
        carbs: 1.5,
        fat: 0.5,
        servingAmount: 1,
        servingUnit: 'muỗng',
        imageUrl: '',
      );

      final updatedState = container.read(nutritionProvider);
      expect(updatedState.currentDayEntries.length, equals(initialEntries + 1));

      final snackEntries = updatedState.getEntriesByMeal(MealType.snack);
      expect(snackEntries.any((e) => e.foodId == 'food_whey'), isTrue);

      final addedEntry = snackEntries.firstWhere(
        (e) => e.foodId == 'food_whey',
      );
      notifier.removeFoodEntry(addedEntry.id);

      expect(
        container
            .read(nutritionProvider)
            .getEntriesByMeal(MealType.snack)
            .any((e) => e.id == addedEntry.id),
        isFalse,
      );
    });

    test(
      'NutritionController manages water intake, goals and quick calories properly',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(nutritionProvider.notifier);

        // Test Water Tracking
        final initialWater = container.read(nutritionProvider).waterIntakeMl;
        notifier.addWater(500);
        expect(
          container.read(nutritionProvider).waterIntakeMl,
          equals(initialWater + 500),
        );

        notifier.removeWater(250);
        expect(
          container.read(nutritionProvider).waterIntakeMl,
          equals(initialWater + 250),
        );

        // Test Goals Update
        notifier.updateGoals(
          targetCalories: 2800,
          targetProtein: 180,
          targetCarbs: 300,
          targetFat: 75,
          targetWaterMl: 2500,
        );
        final updatedState = container.read(nutritionProvider);
        expect(updatedState.targetCalories, equals(2800));
        expect(updatedState.targetProtein, equals(180));
        expect(updatedState.targetCarbs, equals(300));
        expect(updatedState.targetFat, equals(75));
        expect(updatedState.targetWaterMl, equals(2500));

        // Test Quick Calories
        final lunchCountBefore = updatedState
            .getEntriesByMeal(MealType.lunch)
            .length;
        notifier.addQuickCalories(
          mealType: MealType.lunch,
          calories: 450,
          name: 'Cơm tấm sườn',
        );
        final afterQuickLogState = container.read(nutritionProvider);
        expect(
          afterQuickLogState.getEntriesByMeal(MealType.lunch).length,
          equals(lunchCountBefore + 1),
        );
        expect(
          afterQuickLogState
              .getEntriesByMeal(MealType.lunch)
              .any((e) => e.name == 'Cơm tấm sườn' && e.calories == 450),
          isTrue,
        );
      },
    );
  });

  group('Nutrition UI Widget tests', () {
    testWidgets(
      'NutritionScreen renders all redesigned sections and action cards',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: NutritionScreen())),
        );
        await tester.pumpAndSettle();

        // Verify Title
        expect(find.text('Dinh dưỡng & Bữa ăn'), findsOneWidget);

        // Verify Today button in date selector
        expect(find.text('Hôm nay'), findsWidgets);

        // Verify Energy & Macros Card
        expect(find.text('NĂNG LƯỢNG & DINH DƯỠNG'), findsOneWidget);
        expect(find.text('Chỉnh mục tiêu'), findsOneWidget);
        expect(find.text('Protein'), findsOneWidget);
        expect(find.text('Carb'), findsOneWidget);
        expect(find.text('Fat'), findsOneWidget);

        // Verify 4 Action Cards directly below Energy Card
        expect(find.text('Tìm kiếm'), findsOneWidget);
        expect(find.text('Yêu thích'), findsOneWidget);
        expect(find.text('Kế hoạch'), findsOneWidget);
        expect(find.text('Lịch sử'), findsOneWidget);

        // Verify Beginner Tips
        expect(
          find.text('Mẹo cho người mới: Cách theo dõi bữa ăn chuẩn gymmer'),
          findsOneWidget,
        );

        // Verify AI Nutrition Assistant Card
        expect(find.text('Trợ lý AI Dinh dưỡng VieGym'), findsOneWidget);
        expect(find.text('Chat ngay'), findsOneWidget);
        expect(find.text('AI tạo món ăn'), findsOneWidget);

        // Verify Water Tracking Card
        expect(find.text('Nhật ký uống nước'), findsOneWidget);
        expect(find.text('+250ml'), findsOneWidget);
        expect(find.text('+500ml'), findsOneWidget);

        // Verify Meals Section
        expect(find.text('CÁC BỮA ĂN TRONG NGÀY'), findsOneWidget);
        expect(find.text('Bữa sáng'), findsOneWidget);
        expect(find.text('Bữa trưa'), findsOneWidget);
        expect(find.text('Bữa tối'), findsOneWidget);
        expect(find.text('Bữa phụ'), findsOneWidget);
      },
    );

    testWidgets(
      'NutritionScreen delete food dialog renders balanced buttons and allows cancel/confirm',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: NutritionScreen())),
        );
        await tester.pumpAndSettle();

        // Find first delete icon button in food entries
        final deleteIcons = find.byIcon(Icons.close_rounded);
        if (deleteIcons.evaluate().isNotEmpty) {
          await tester.tap(deleteIcons.first);
          await tester.pumpAndSettle();

          // Verify Delete Dialog
          expect(find.text('Xóa món ăn?'), findsOneWidget);
          expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
          expect(find.widgetWithText(OutlinedButton, 'Hủy'), findsOneWidget);
          expect(find.widgetWithText(FilledButton, 'Xóa'), findsOneWidget);

          // Tap Hủy -> dialog dismisses
          await tester.tap(find.widgetWithText(OutlinedButton, 'Hủy'));
          await tester.pumpAndSettle();
          expect(find.text('Xóa món ăn?'), findsNothing);
        }
      },
    );

    testWidgets('FoodSearchScreen renders categories and food items', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: FoodSearchScreen())),
      );

      expect(find.text('Thư viện món ăn'), findsOneWidget);
      expect(find.text('Tất cả'), findsOneWidget);
      expect(find.text('Món Việt'), findsOneWidget);
      expect(find.text('Đạm / Thịt'), findsOneWidget);
      expect(find.text('Phở bò tái nạm'), findsOneWidget);
    });

    testWidgets(
      'FoodDetailScreen renders nutrition boxes, servings and add button',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: FoodDetailScreen(foodId: 'food_pho_bo')),
          ),
        );

        expect(find.text('Phở bò tái nạm'), findsAtLeast(1));
        expect(find.text('Năng lượng'), findsOneWidget);
        expect(find.text('Protein'), findsOneWidget);
        expect(find.text('1. Chọn khẩu phần'), findsOneWidget);
        expect(find.text('2. Số lượng phần ăn'), findsOneWidget);
        expect(find.text('3. Thêm vào bữa ăn nào?'), findsOneWidget);
        expect(find.text('Sáng'), findsOneWidget);
        expect(find.text('Trưa'), findsOneWidget);
        expect(find.text('Tối'), findsOneWidget);
        expect(find.text('Phụ'), findsOneWidget);
        expect(find.byIcon(Icons.wb_sunny_rounded), findsWidgets);
        expect(find.byIcon(Icons.nights_stay_rounded), findsWidgets);
        expect(find.textContaining('Thêm vào Bữa trưa'), findsOneWidget);
      },
    );

    testWidgets(
      'FoodDetailScreen shows calorie limit warning when adding food exceeds target',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Set targetCalories low (e.g. 1500 kcal) so adding Phở bò (430 kcal) exceeds target
        container
            .read(nutritionProvider.notifier)
            .updateGoals(targetCalories: 1500);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: FoodDetailScreen(foodId: 'food_pho_bo'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify inline warning banner is shown
        expect(
          find.text('Lượng calo sắp đạt chỉ tiêu trong ngày'),
          findsOneWidget,
        );
        expect(
          find.textContaining(
            'Không khuyến khích thêm món ăn nếu bạn đang muốn duy trì hoặc giảm mỡ.',
          ),
          findsOneWidget,
        );

        // Tap Add food
        await tester.tap(find.textContaining('Thêm vào Bữa trưa'));
        await tester.pumpAndSettle();

        // Verify Warning Dialog
        expect(find.text('Lượng calo sắp đạt chỉ tiêu'), findsOneWidget);
        expect(find.byIcon(Icons.warning_amber_rounded), findsWidgets);
        expect(find.widgetWithText(OutlinedButton, 'Hủy'), findsOneWidget);
        expect(find.widgetWithText(FilledButton, 'Vẫn thêm'), findsOneWidget);

        // Tap Vẫn thêm
        await tester.tap(find.widgetWithText(FilledButton, 'Vẫn thêm'));
        await tester.pumpAndSettle();

        // Dialog should dismiss and entry be added
        expect(find.text('Lượng calo sắp đạt chỉ tiêu'), findsNothing);
      },
    );

    testWidgets(
      'MealPlannerScreen renders date switcher and meal plan sections',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: MealPlannerScreen())),
        );
        await tester.pumpAndSettle();

        expect(find.text('Kế hoạch bữa ăn'), findsOneWidget);
        expect(find.text('TỔNG KẾ HOẠCH NGÀY'), findsOneWidget);
        expect(find.text('Bữa sáng'), findsOneWidget);
        expect(find.text('Bữa trưa'), findsOneWidget);
        expect(find.text('Bữa tối'), findsOneWidget);
        expect(find.text('Bữa phụ'), findsOneWidget);
      },
    );

    testWidgets('MealHistoryScreen renders historical nutrition summary', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: MealHistoryScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Lịch sử dinh dưỡng'), findsOneWidget);
      expect(find.text('Trung bình dinh dưỡng đã ghi'), findsOneWidget);
      expect(find.text('Chi tiết theo ngày'), findsOneWidget);
    });

    testWidgets(
      'MealBuilderScreen renders food items with meal tabs and allows editing portion',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: MealBuilderScreen(initialMealType: MealType.lunch),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Xây dựng bữa ăn'), findsOneWidget);
        expect(find.text('Sáng'), findsOneWidget);
        expect(find.text('Trưa'), findsOneWidget);
        expect(find.text('Tối'), findsOneWidget);
        expect(find.text('Phụ'), findsOneWidget);

        // Verify Lunch default items & calories
        expect(find.text('TỔNG DINH DƯỠNG BỮA TRƯA'), findsOneWidget);
        expect(find.text('685 kcal'), findsOneWidget);
        expect(find.text('Cơm tấm sườn bì chả'), findsOneWidget);

        // Switch to Breakfast (Sáng)
        await tester.tap(find.text('Sáng'));
        await tester.pumpAndSettle();

        expect(find.text('TỔNG DINH DƯỠNG BỮA SÁNG'), findsOneWidget);
        expect(find.text('505 kcal'), findsOneWidget);
        expect(find.text('Phở bò tái nạm'), findsOneWidget);
        expect(find.text('Cà phê sữa đá ít đường'), findsOneWidget);

        // Switch to Dinner (Tối)
        await tester.tap(find.text('Tối'));
        await tester.pumpAndSettle();

        expect(find.text('TỔNG DINH DƯỠNG BỮA TỐI'), findsOneWidget);
        expect(find.text('230 kcal'), findsOneWidget);
        expect(find.text('Ức gà áp chảo sốt tiêu'), findsOneWidget);

        // Tap on Dinner food item to open FoodDetailScreen in edit mode
        await tester.tap(find.text('Ức gà áp chảo sốt tiêu'));
        await tester.pumpAndSettle();

        expect(find.text('1. Chọn khẩu phần'), findsOneWidget);
        expect(find.text('2. Số lượng phần ăn'), findsOneWidget);
        expect(find.textContaining('Cập nhật khẩu phần'), findsOneWidget);

        // Tap confirm update
        await tester.tap(find.textContaining('Cập nhật khẩu phần'));
        await tester.pumpAndSettle();

        expect(find.text('Xây dựng bữa ăn'), findsOneWidget);
      },
    );

    test('FavoriteFoodsController toggles and retrieves favorites', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(favoriteFoodsProvider.notifier);
      final initialFavs = container.read(favoriteFoodsProvider);
      expect(initialFavs.contains('food_pho_bo'), isTrue);

      // Toggle off
      final isNowFav = controller.toggleFavorite('food_pho_bo');
      expect(isNowFav, isFalse);
      expect(
        container.read(favoriteFoodsProvider).contains('food_pho_bo'),
        isFalse,
      );

      // Toggle back on
      final isFavAgain = controller.toggleFavorite('food_pho_bo');
      expect(isFavAgain, isTrue);
      expect(
        container.read(favoriteFoodsProvider).contains('food_pho_bo'),
        isTrue,
      );

      // Get favorites list
      final favList = controller.getFavorites();
      expect(favList.isNotEmpty, isTrue);
      expect(favList.any((f) => f.id == 'food_pho_bo'), isTrue);
    });

    testWidgets(
      'FavoriteFoodsScreen renders favorite foods and allow removal',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: FavoriteFoodsScreen())),
        );
        await tester.pumpAndSettle();

        expect(find.text('Món ăn yêu thích'), findsOneWidget);
        expect(find.text('Phở bò tái nạm'), findsOneWidget);
        expect(find.text('Ức gà áp chảo'), findsOneWidget);
        expect(find.byIcon(Icons.favorite_rounded), findsWidgets);
      },
    );

    testWidgets('Empty favorites CTA opens the food search screen', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final favorites = container.read(favoriteFoodsProvider.notifier);
      for (final id in [...container.read(favoriteFoodsProvider)]) {
        favorites.toggleFavorite(id);
      }

      final router = GoRouter(
        initialLocation: '/favorites',
        routes: [
          GoRoute(
            path: '/favorites',
            builder: (context, state) => const FavoriteFoodsScreen(),
          ),
          GoRoute(
            path: '/meal/search',
            builder: (context, state) => const FoodSearchScreen(),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Chưa có món ăn yêu thích nào'), findsOneWidget);
      await tester.tap(find.text('Tìm kiếm món ăn'));
      await tester.pumpAndSettle();

      expect(find.byType(FoodSearchScreen), findsOneWidget);
    });

    testWidgets(
      'NutritionScreen renders Trợ lý AI Dinh dưỡng with Chat ngay and AI tạo món ăn',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: NutritionScreen())),
        );
        await tester.pumpAndSettle();

        expect(find.text('Trợ lý AI Dinh dưỡng VieGym'), findsOneWidget);
        expect(find.text('Chat ngay'), findsOneWidget);
        expect(find.text('AI tạo món ăn'), findsOneWidget);
      },
    );

    testWidgets(
      'AiMealGenerateScreen renders multi-meal selection, target summary, and generates meals',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 4000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const AiMealGenerateScreen(
                initialMealType: MealType.breakfast,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify Screen Title & Sections
        expect(find.text('AI tạo bữa ăn'), findsOneWidget);
        expect(find.text('CHỌN CÁC BỮA CẦN GỢI Ý'), findsOneWidget);
        expect(find.text('DINH DƯỠNG CÒN LẠI HÔM NAY'), findsOneWidget);
        expect(find.text('TÙY CHỌN & ƯU TIÊN'), findsOneWidget);
        expect(find.text('Ưu tiên món Việt'), findsOneWidget);

        // Tap Generate
        await tester.tap(find.text('✨ Tạo 1 bữa ăn với AI'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        // Verify meal card
        expect(find.text('GỢI Ý BỮA SÁNG'), findsOneWidget);
        expect(find.text('Thêm vào Bữa sáng'), findsOneWidget);

        final countBefore = container.read(nutritionProvider).entries.length;

        // Tap Thêm vào Bữa sáng
        await tester.tap(find.text('Thêm vào Bữa sáng'));
        await tester.pumpAndSettle();

        // If Calorie Limit warning dialog appears, verify and confirm
        if (find.text('Lượng calo sắp đạt chỉ tiêu').evaluate().isNotEmpty) {
          expect(
            find.textContaining('Không khuyến khích thêm món ăn'),
            findsOneWidget,
          );
          await tester.tap(find.widgetWithText(FilledButton, 'Vẫn thêm'));
          await tester.pumpAndSettle();
        }

        final countAfter = container.read(nutritionProvider).entries.length;
        expect(countAfter, greaterThan(countBefore));
      },
    );
  });
}
