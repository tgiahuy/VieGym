import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viegym/features/ai/application/ai_coach_controller.dart';
import 'package:viegym/features/ai/domain/ai_models.dart';
import 'package:viegym/features/ai/presentation/ai_coach_chat_screen.dart';
import 'package:viegym/features/ai/presentation/ai_tab_screen.dart';
import 'package:viegym/features/ai/presentation/widgets/ai_recommendation_card.dart';

void main() {
  group('AI Recommendation State & Model tests', () {
    test('Initial AiCoachState contains active recommendations', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(aiCoachProvider);
      expect(state.recommendations.length, 2);
      expect(state.activeRecommendations.length, 2);
      expect(state.newRecommendationsCount, 2);
      expect(
        state.activeRecommendations.first.title,
        'Tập trung thân trên (Upper Push)',
      );
    });

    test(
      'applyRecommendation updates status to applied and removes from active',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        container
            .read(aiCoachProvider.notifier)
            .applyRecommendation('rec_upper_push_today');

        final state = container.read(aiCoachProvider);
        expect(state.activeRecommendations.length, 1);
        expect(state.newRecommendationsCount, 1);
        expect(
          state.activeRecommendations.first.id,
          'rec_legs_recovered_today',
        );
      },
    );

    test(
      'dismissRecommendation updates status to dismissed and removes from active',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        container
            .read(aiCoachProvider.notifier)
            .dismissRecommendation('rec_legs_recovered_today');

        final state = container.read(aiCoachProvider);
        expect(state.activeRecommendations.length, 1);
        expect(state.activeRecommendations.first.id, 'rec_upper_push_today');
      },
    );
  });

  group('AIRecommendationCard UI Widget tests', () {
    testWidgets(
      'AIRecommendationCard renders title, description, reason, and triggers callbacks',
      (tester) async {
        bool applied = false;
        bool dismissed = false;

        const rec = AiRecommendation(
          id: 'test_rec',
          type: RecommendationType.workout,
          title: 'Tập trung thân trên (Upper Push)',
          description: 'Đề xuất buổi tập 45 phút tối ưu cho ngực và vai.',
          reason: 'Nhóm cơ ngực và vai đã qua 48h nghỉ ngơi.',
          actionType: RecommendationActionType.startWorkout,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AIRecommendationCard(
                recommendation: rec,
                onApply: () => applied = true,
                onDismiss: () => dismissed = true,
              ),
            ),
          ),
        );

        expect(find.text('Tập trung thân trên (Upper Push)'), findsOneWidget);
        expect(
          find.text('Đề xuất buổi tập 45 phút tối ưu cho ngực và vai.'),
          findsOneWidget,
        );
        expect(find.textContaining('Lý do:'), findsOneWidget);
        expect(find.text('Áp dụng'), findsOneWidget);

        await tester.tap(find.text('Áp dụng'));
        await tester.pump();
        expect(applied, isTrue);

        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pump();
        expect(dismissed, isTrue);
      },
    );

    testWidgets('AiCoachChatScreen renders chat interface and prompt chips', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AiCoachChatScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text('AI Coach Chat'), findsOneWidget);
      expect(find.text('Hỏi đáp & Hỗ trợ thông minh'), findsOneWidget);
      expect(find.textContaining('Gợi ý thực đơn tăng cơ'), findsOneWidget);
      expect(find.textContaining('Gợi ý buổi tập Ngực & Tay'), findsOneWidget);
    });

    testWidgets(
      'AiTabScreen renders AI Coach banner and ĐỀ XUẤT HÔM NAY cards',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: AiTabScreen())),
        );
        await tester.pumpAndSettle();

        expect(find.text('VieGym AI Coach'), findsOneWidget);
        expect(find.text('AI Coach Chat'), findsOneWidget);
        expect(find.text('Mở cuộc trò chuyện'), findsOneWidget);
        expect(find.text('ĐỀ XUẤT HÔM NAY'), findsOneWidget);
        expect(find.textContaining('đề xuất mới'), findsOneWidget);
        expect(find.text('Tập trung thân trên (Upper Push)'), findsOneWidget);
        expect(
          find.text('Cơ chân đã phục hồi hoàn toàn (100%)'),
          findsOneWidget,
        );
        expect(find.text('Áp dụng'), findsNWidgets(2));
      },
    );
  });
}
