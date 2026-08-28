import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../workout/application/workout_session_controller.dart';
import '../../workout/data/exercise_catalog.dart';
import '../domain/ai_models.dart';

final mealCaloriesAddedProvider = NotifierProvider<MealCaloriesController, int>(
  MealCaloriesController.new,
);

class MealCaloriesController extends Notifier<int> {
  @override
  int build() => 0;

  void add(int calories) => state += calories;
}

final aiCoachProvider = NotifierProvider<AiCoachController, AiCoachState>(
  AiCoachController.new,
);

class AiCoachController extends Notifier<AiCoachState> {
  @override
  AiCoachState build() {
    return const AiCoachState(
      messages: [
        AiChatMessage(
          id: 'welcome',
          sender: AiMessageSender.assistant,
          text:
              'Chào bạn! Mình là AI Coach của VieGym. Mình có thể hỗ trợ dinh dưỡng hoặc điều chỉnh bài tập khi bạn gặp khó chịu trong buổi tập.',
        ),
      ],
    );
  }

  Future<void> send(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || state.isGenerating) return;

    final userMessage = AiChatMessage(
      id: 'user_${DateTime.now().microsecondsSinceEpoch}',
      sender: AiMessageSender.user,
      text: text,
    );
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isGenerating: true,
    );

    await Future<void>.delayed(const Duration(milliseconds: 350));
    final response = _buildResponse(text);
    state = state.copyWith(
      messages: [...state.messages, response],
      isGenerating: false,
    );
  }

  AiChatMessage _buildResponse(String rawText) {
    final text = _normalize(rawText);
    final now = DateTime.now().microsecondsSinceEpoch;
    final hasPain = _containsAny(text, [
      'dau',
      'kho chiu',
      'nhuc',
      'khong thoai mai',
    ]);
    final isSevere = _containsAny(text, [
      'dau du doi',
      'sung',
      'te ',
      'yeu ro ret',
      'mat kha nang van dong',
      'khong cu dong',
      'dau keo dai',
      'dau tang dan',
    ]);

    if (hasPain && isSevere) {
      return AiChatMessage(
        id: 'assistant_safety_$now',
        sender: AiMessageSender.assistant,
        text:
            'Bạn nên dừng bài đang gây đau và nghỉ vùng liên quan. Những dấu hiệu này cần được ưu tiên đánh giá bởi bác sĩ hoặc chuyên gia y tế phù hợp. Mình sẽ không đề xuất tiếp tục tập bằng một bài thay thế trong tình huống này.',
      );
    }

    final wantsReplacement = _containsAny(text, [
      'thay ',
      'thay the',
      'doi bai',
      'bai nao khac',
      'bai khac',
    ]);
    if (hasPain && wantsReplacement) {
      return _buildReplacementMessage(text, now);
    }

    if (hasPain) {
      return AiChatMessage(
        id: 'assistant_pain_$now',
        sender: AiMessageSender.assistant,
        text:
            'Bạn không nên cố tập qua cơn đau. Hãy dừng bài đang gây khó chịu và cho mình biết tên bài nếu bạn muốn xem lựa chọn thay thế theo thiết bị hiện có.',
      );
    }

    if (_containsAny(text, ['thuc don', 'bua an', 'an gi', 'bua trua'])) {
      const proposal = MealProposal(
        id: 'meal_lunch_proposal',
        status: ProposalStatus.pending,
        mealName: 'Bữa trưa',
        items: [
          MealProposalItem(
            name: 'Ức gà áp chảo',
            serving: '150g',
            calories: 248,
            protein: 46.5,
          ),
          MealProposalItem(
            name: 'Cơm gạo lứt',
            serving: '1 chén',
            calories: 216,
            protein: 5,
          ),
          MealProposalItem(
            name: 'Bông cải xanh',
            serving: '150g',
            calories: 52,
            protein: 4.2,
          ),
        ],
        reason:
            'Bữa ăn giàu protein, có carbohydrate và rau để hỗ trợ phục hồi.',
      );
      return AiChatMessage(
        id: 'assistant_meal_$now',
        sender: AiMessageSender.assistant,
        text:
            'Mình đã tạo đề xuất bữa trưa. Thực đơn chỉ được thêm sau khi bạn xác nhận.',
        proposal: proposal,
      );
    }

    return AiChatMessage(
      id: 'assistant_general_$now',
      sender: AiMessageSender.assistant,
      text:
          'Mình có thể hỗ trợ bạn lên thực đơn hoặc điều chỉnh một bài cụ thể trong Workout Session. Hãy mô tả mục tiêu hoặc bài đang gây khó chịu.',
    );
  }

  AiChatMessage _buildReplacementMessage(String normalizedText, int now) {
    final session = ref.read(workoutSessionProvider);
    var original = session.currentExercise;
    if (normalizedText.contains('bench press')) {
      original = session.exercises.firstWhere(
        (item) => item.exerciseId == 'ex1',
        orElse: () => session.currentExercise,
      );
    }

    final equipment = ref.read(equipmentPreferencesProvider);
    final candidates = replacementCandidates(
      originalExerciseId: original.exerciseId,
      availableEquipment: equipment,
    );
    if (candidates.isEmpty) {
      return AiChatMessage(
        id: 'assistant_no_alternative_$now',
        sender: AiMessageSender.assistant,
        text:
            'Mình chưa tìm thấy bài thay thế phù hợp với thiết bị bạn đã chọn. Hãy dừng bài nếu còn đau và không cố tập qua cơn đau.',
      );
    }

    final originalDefinition = findExercise(original.exerciseId);
    final proposal = AlternativeExerciseProposal(
      id: 'replace_$now',
      status: ProposalStatus.pending,
      originalExerciseId: original.exerciseId,
      originalExerciseName: original.name,
      targetMuscles: [
        original.primaryMuscle,
        ...?originalDefinition?.secondaryMuscles,
      ],
      alternatives: candidates.map((candidate) {
        return AlternativeExerciseItem(
          exerciseId: candidate.id,
          name: candidate.name,
          targetMuscles: [candidate.primaryMuscle],
          equipment: candidate.equipment.label,
          equipmentMatch: true,
          reason: _replacementReason(candidate.id, candidate.primaryMuscle),
        );
      }).toList(),
      warning:
          'Đây là gợi ý điều chỉnh bài tập, không phải chẩn đoán y khoa. Dừng lại nếu cơn đau tăng hoặc động tác vẫn gây khó chịu.',
    );

    return AiChatMessage(
      id: 'assistant_replace_$now',
      sender: AiMessageSender.assistant,
      text:
          'Mình đã tìm các bài vẫn tập trung vào ${original.primaryMuscle.toLowerCase()} và phù hợp thiết bị hiện có. Workout chỉ thay ${original.name} sau khi bạn chọn và xác nhận.',
      proposal: proposal,
    );
  }

  void applyReplacement(String proposalId, String alternativeId) {
    final messages = [...state.messages];
    final index = messages.indexWhere(
      (message) => message.proposal?.id == proposalId,
    );
    if (index == -1) return;
    final proposal = messages[index].proposal;
    if (proposal is! AlternativeExerciseProposal ||
        proposal.status != ProposalStatus.pending) {
      return;
    }

    final alternative = proposal.alternatives
        .where(
          (item) => item.exerciseId == alternativeId && item.equipmentMatch,
        )
        .firstOrNull;
    if (alternative == null) return;

    ref
        .read(workoutSessionProvider.notifier)
        .replaceExercise(
          originalExerciseId: proposal.originalExerciseId,
          replacementExerciseId: alternative.exerciseId,
        );
    messages[index] = messages[index].copyWith(
      proposal: proposal.copyWith(
        status: ProposalStatus.applied,
        selectedExerciseId: alternative.exerciseId,
      ),
    );
    messages.add(
      AiChatMessage(
        id: 'assistant_applied_${DateTime.now().microsecondsSinceEpoch}',
        sender: AiMessageSender.assistant,
        text:
            'Đã thay ${proposal.originalExerciseName} bằng ${alternative.name}. Các bài tập khác và tiến độ của chúng được giữ nguyên.',
      ),
    );
    state = state.copyWith(messages: messages);
  }

  void applyMeal(String proposalId) {
    _updateProposal(proposalId, (proposal) {
      if (proposal is! MealProposal ||
          proposal.status != ProposalStatus.pending) {
        return proposal;
      }
      ref.read(mealCaloriesAddedProvider.notifier).add(proposal.totalCalories);
      return proposal.copyWith(status: ProposalStatus.applied);
    });
  }

  void dismissProposal(String proposalId) {
    _updateProposal(proposalId, (proposal) {
      return switch (proposal) {
        AlternativeExerciseProposal() => proposal.copyWith(
          status: ProposalStatus.dismissed,
        ),
        MealProposal() => proposal.copyWith(status: ProposalStatus.dismissed),
      };
    });
  }

  void _updateProposal(String id, AiProposal Function(AiProposal) update) {
    final messages = state.messages.map((message) {
      final proposal = message.proposal;
      if (proposal == null || proposal.id != id) return message;
      return message.copyWith(proposal: update(proposal));
    }).toList();
    state = state.copyWith(messages: messages);
  }

  static bool _containsAny(String text, List<String> terms) {
    return terms.any(text.contains);
  }

  static String _replacementReason(String id, String muscle) {
    return switch (id) {
      'ex_neutral_db_press' =>
        'Vẫn tập trung vào ngực và dùng tay cầm trung tính, có thể giảm yêu cầu ở vị trí cổ tay so với barbell press.',
      'ex_chest_press_machine' =>
        'Quỹ đạo máy ổn định hơn; hãy chọn tay cầm không làm tăng khó chịu.',
      'ex_pec_deck_fly' =>
        'Vẫn cô lập cơ ngực nhưng không cần đỡ thanh đòn; dừng nếu cơn đau tăng.',
      _ => 'Tập trung vào ${muscle.toLowerCase()} và phù hợp thiết bị hiện có.',
    };
  }

  static String _normalize(String input) {
    const source =
        'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
    const target =
        'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
    var output = input.toLowerCase();
    for (var i = 0; i < source.length; i++) {
      output = output.replaceAll(source[i], target[i]);
    }
    return output;
  }
}
