import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viegym/features/ai/data/ai_repository.dart';
import 'package:viegym/features/ai/domain/ai_models.dart';

void main() {
  test('consent state is loaded and updated through backend API', () async {
    final interceptor = _QueueInterceptor([
      {'mode': 'DISABLED'},
      {'mode': 'ENABLED'},
    ]);
    final repository = AiRepository(_dio(interceptor));

    expect(await repository.getConsent(), isFalse);
    expect(await repository.updateConsent(true), isTrue);
    expect(interceptor.requests.last.data, {
      'mode': 'ENABLED',
      'consentVersion': 'v1.0',
      'source': 'SETTINGS',
    });
  });

  test('daily recommendation maps server state and action preview', () async {
    final interceptor = _QueueInterceptor([
      {
        'recommendations': [
          {
            'id': 601,
            'type': 'NUTRITION',
            'title': 'Bổ sung protein',
            'content': 'Thêm một khẩu phần.',
            'reason': 'Protein còn thiếu.',
            'status': 'PENDING',
            'allowedAction': 'ADD_MEAL_ENTRY_PROPOSAL',
            'actionPreview': {'foodId': 205},
            'version': 2,
          },
        ],
      },
      {},
    ]);
    final repository = AiRepository(_dio(interceptor));

    final items = await repository.getDailyRecommendations();
    expect(items, hasLength(1));
    expect(items.single.type, RecommendationType.nutrition);
    expect(items.single.actionType, RecommendationActionType.adjustNutrition);
    expect(items.single.version, 2);
    expect(items.single.metadata?['foodId'], 205);

    await repository.apply(items.single);
    expect(interceptor.requests.last.headers['Idempotency-Key'], 'apply-601');
    expect(interceptor.requests.last.data, {'expectedVersion': 2});
  });

  test('chat response exposes effective general knowledge mode', () async {
    final interceptor = _QueueInterceptor([
      {
        'mode': 'GENERAL_KNOWLEDGE',
        'userMessage': {'id': 1, 'role': 'USER', 'content': 'Xin chào'},
        'assistantMessage': {
          'id': 2,
          'role': 'ASSISTANT',
          'content': 'Chào bạn',
        },
      },
    ]);
    final repository = AiRepository(_dio(interceptor));

    final exchange = await repository.sendMessage(10, 'Xin chào');
    expect(exchange.mode, 'GENERAL_KNOWLEDGE');
    expect(exchange.assistant.sender, AiMessageSender.assistant);
    expect(exchange.assistant.text, 'Chào bạn');
  });
}

Dio _dio(_QueueInterceptor interceptor) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
  dio.interceptors.add(interceptor);
  return dio;
}

class _QueueInterceptor extends Interceptor {
  _QueueInterceptor(this.responses);

  final List<Map<String, dynamic>> responses;
  final List<RequestOptions> requests = [];
  var _index = 0;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    requests.add(options);
    final data = responses[_index++];
    handler.resolve(
      Response<Map<String, dynamic>>(
        requestOptions: options,
        statusCode: 200,
        data: {'success': true, 'data': data},
      ),
    );
  }
}
