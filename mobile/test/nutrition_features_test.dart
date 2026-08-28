import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viegym/features/nutrition/application/nutrition_controller.dart';
import 'package:viegym/features/nutrition/data/food_catalog.dart';
import 'package:viegym/features/nutrition/domain/food_models.dart';
import 'package:viegym/features/nutrition/presentation/food_detail_screen.dart';
import 'package:viegym/features/nutrition/presentation/food_search_screen.dart';
import 'package:viegym/features/nutrition/presentation/meal_builder_screen.dart';

final _transparentPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
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
  void addCredentials(Uri url, String realm, HttpClientCredentials credentials) {}

  @override
  void addProxyCredentials(String host, int port, String realm, HttpClientCredentials credentials) {}

  @override
  void close({bool force = false}) {}

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async => _MockHttpClientRequest();

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

class _MockHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
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
      final initialEntries =
          container.read(nutritionProvider).currentDayEntries.length;

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
      expect(
        updatedState.currentDayEntries.length,
        equals(initialEntries + 1),
      );

      final snackEntries = updatedState.getEntriesByMeal(MealType.snack);
      expect(snackEntries.any((e) => e.foodId == 'food_whey'), isTrue);

      final addedEntry =
          snackEntries.firstWhere((e) => e.foodId == 'food_whey');
      notifier.removeFoodEntry(addedEntry.id);

      expect(
        container
            .read(nutritionProvider)
            .getEntriesByMeal(MealType.snack)
            .any((e) => e.id == addedEntry.id),
        isFalse,
      );
    });
  });

  group('Nutrition UI Widget tests', () {
    testWidgets('FoodSearchScreen renders categories and food items',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FoodSearchScreen(),
          ),
        ),
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
          child: MaterialApp(
            home: FoodDetailScreen(foodId: 'food_pho_bo'),
          ),
        ),
      );

      expect(find.text('Phở bò tái nạm'), findsAtLeast(1));
      expect(find.text('Năng lượng'), findsOneWidget);
      expect(find.text('Protein'), findsOneWidget);
      expect(find.text('1. Chọn khẩu phần'), findsOneWidget);
      expect(find.text('2. Số lượng phần ăn'), findsOneWidget);
      expect(find.textContaining('Thêm vào Bữa trưa'), findsOneWidget);
    });

    testWidgets('MealBuilderScreen renders meal items and totals',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MealBuilderScreen(),
          ),
        ),
      );

      expect(find.text('Xây dựng bữa ăn'), findsOneWidget);
      expect(find.text('TỔNG DINH DƯỠNG BỮA ĂN'), findsOneWidget);
      expect(find.textContaining('Danh sách món ăn'), findsOneWidget);
      expect(find.textContaining('Lưu vào'), findsOneWidget);
    });
  });
}
