import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viegym/features/ai/data/ai_repository.dart';
import 'package:viegym/features/ai/presentation/widgets/ai_personalization_banner.dart';

void main() {
  Future<void> pumpBanner(WidgetTester tester, _ConsentRepository repo) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [aiRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(
          home: Scaffold(body: AiPersonalizationBanner(message: 'Bật đi')),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows when the server says personalization is off', (
    tester,
  ) async {
    await pumpBanner(tester, _ConsentRepository(enabled: false));
    expect(find.text('Bật đi'), findsOneWidget);
    expect(find.text('Bật'), findsOneWidget);
  });

  testWidgets('stays hidden when personalization is already on', (
    tester,
  ) async {
    await pumpBanner(tester, _ConsentRepository(enabled: true));
    expect(find.text('Bật đi'), findsNothing);
  });

  testWidgets('stays hidden when the consent state cannot be loaded', (
    tester,
  ) async {
    await pumpBanner(tester, _ConsentRepository(enabled: false, offline: true));
    expect(find.text('Bật đi'), findsNothing);
  });
}

class _ConsentRepository extends AiRepository {
  _ConsentRepository({required this.enabled, this.offline = false})
    : super(Dio());

  final bool enabled;
  final bool offline;

  @override
  Future<bool> getConsent() async {
    if (offline) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/ai/consent'),
        type: DioExceptionType.connectionError,
      );
    }
    return enabled;
  }
}
