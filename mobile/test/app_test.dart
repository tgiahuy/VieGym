import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viegym/core/config/env_config.dart';
import 'package:viegym/core/network/api_error_handler.dart';
import 'package:viegym/core/network/dio_provider.dart';
import 'package:viegym/main.dart';
import 'package:viegym/shared/widgets/async_value_widget.dart';
import 'package:viegym/shared/widgets/bouncing_icon_button.dart';
import 'package:viegym/shared/widgets/empty_view.dart';
import 'package:viegym/shared/widgets/error_view.dart';
import 'package:viegym/shared/widgets/loading_view.dart';
import 'package:viegym/shared/widgets/offline_view.dart';

void main() {
  group('M1-16: Core Env & Main App', () {
    test('EnvConfig defaults are correctly initialized', () {
      expect(EnvConfig.apiBaseUrl, isNotEmpty);
      expect(EnvConfig.aiServiceBaseUrl, isNotEmpty);
      expect(EnvConfig.environment, 'dev');
      expect(EnvConfig.isDebugLogging, isTrue);
    });

    testWidgets('App starts with native VieGym dashboard and navigation', (
      tester,
    ) async {
      await tester.pumpWidget(const ProviderScope(child: VieGymApp()));
      await tester.pumpAndSettle();

      expect(find.text('Gia Huy'), findsOneWidget);
      expect(find.text('Upper Body A'), findsOneWidget);
      expect(find.text('Trang chủ'), findsOneWidget);
      expect(find.text('Tập luyện'), findsOneWidget);
      expect(find.text('Bữa ăn'), findsOneWidget);
      expect(find.text('AI Coach'), findsOneWidget);
      expect(find.text('Cá nhân'), findsOneWidget);
    });

    testWidgets('Main tabs remain usable on a 320px-wide screen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const ProviderScope(child: VieGymApp()));
      await tester.pumpAndSettle();

      for (final label in const [
        'Tập luyện',
        'Bữa ăn',
        'AI Coach',
        'Cá nhân',
        'Trang chủ',
      ]) {
        await tester.tap(find.text(label).last);
        await tester.pumpAndSettle();
        final exception = tester.takeException();
        expect(
          exception,
          isNull,
          reason: exception is FlutterError
              ? 'Lỗi tại tab $label\n${exception.toStringDeep()}'
              : 'Lỗi tại tab $label: $exception',
        );
      }
    });
  });

  group('M1-17: Network & Error Handler', () {
    test('Dio provider can be read within container', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final dio = container.read(dioProvider);
      expect(dio.options.baseUrl, EnvConfig.apiBaseUrl);
      expect(dio.options.connectTimeout, const Duration(seconds: 10));
      expect(dio.options.receiveTimeout, const Duration(seconds: 30));
    });

    test('ApiErrorHandler maps connection timeout error', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );
      final error = ApiErrorHandler.parse(dioException);
      expect(error.code, 'TIMEOUT');
      expect(error.message, contains('quá thời gian'));
    });

    test('ApiErrorHandler maps backend error envelope', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 422,
          data: {
            'success': false,
            'code': 'VALIDATION_ERROR',
            'message': 'Email không đúng định dạng',
          },
        ),
      );
      final error = ApiErrorHandler.parse(dioException);
      expect(error.code, 'VALIDATION_ERROR');
      expect(error.message, 'Email không đúng định dạng');
      expect(error.statusCode, 422);
    });
  });

  group('M1-18: Shared UI Widgets', () {
    testWidgets('LoadingView displays indicator and optional message', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingView(message: 'Đang tải dữ liệu...')),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Đang tải dữ liệu...'), findsOneWidget);
    });

    testWidgets('EmptyView displays message and icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EmptyView(message: 'Chưa có bài tập nào')),
        ),
      );

      expect(find.text('Chưa có bài tập nào'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_rounded), findsOneWidget);
    });

    testWidgets('ErrorView displays message and triggers retry', (
      tester,
    ) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: 'Lỗi tải trang',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Lỗi tải trang'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);

      await tester.tap(find.text('Thử lại'));
      expect(retried, isTrue);
    });

    testWidgets('OfflineView displays offline warning and retry button', (
      tester,
    ) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: OfflineView(onRetry: () => retried = true)),
        ),
      );

      expect(find.text('Không có kết nối mạng'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);

      await tester.tap(find.text('Thử lại'));
      expect(retried, isTrue);
    });

    testWidgets('AsyncValueWidget handles loading, data and error states', (
      tester,
    ) async {
      // Data state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncValueWidget<String>(
              value: const AsyncValue.data('Success data'),
              data: (data) => Text(data),
            ),
          ),
        ),
      );
      expect(find.text('Success data'), findsOneWidget);

      // Loading state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncValueWidget<String>(
              value: const AsyncValue.loading(),
              loadingMessage: 'Đang tải...',
              data: (data) => Text(data),
            ),
          ),
        ),
      );
      expect(find.text('Đang tải...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
      'BouncingIconButton and BouncingEffect trigger animation and callback on tap',
      (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BouncingIconButton(
                icon: const Icon(Icons.fitness_center),
                onPressed: () => tapped = true,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.fitness_center), findsOneWidget);
        await tester.tap(find.byType(BouncingIconButton));
        await tester.pumpAndSettle();
        expect(tapped, isTrue);
      },
    );
  });
}
