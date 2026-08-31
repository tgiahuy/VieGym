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
              'Chào bạn! Mình là AI Coach của VieGym. Mình liên tục phân tích dữ liệu tập luyện, phục hồi và dinh dưỡng để đưa ra các đề xuất tối ưu hóa thể hình cho bạn.',
        ),
      ],
      recommendations: [
        AiRecommendation(
          id: 'rec_upper_push_today',
          type: RecommendationType.workout,
          title: 'Tập trung thân trên (Upper Push)',
          description:
              'Đề xuất buổi tập 45 phút tối ưu cho ngực và vai với mức phục hồi 82%.',
          reason:
              'Nhóm cơ ngực và vai đã qua 48h nghỉ ngơi và sẵn sàng cho chu kỳ tăng cơ tiếp theo.',
          actionType: RecommendationActionType.startWorkout,
          targetMuscles: ['Ngực', 'Vai', 'Tay sau'],
          recoveryPercent: 82,
          durationMinutes: 45,
        ),
        AiRecommendation(
          id: 'rec_legs_recovered_today',
          type: RecommendationType.recovery,
          title: 'Cơ chân đã phục hồi hoàn toàn (100%)',
          description:
              'Bạn có thể sẵn sàng cho buổi Squat hoặc Legs Day với mức tải cao trong 1–2 ngày tới.',
          reason:
              'Dựa trên thời gian phục hồi 72h từ buổi tập chân trước và tổng khối lượng tuần đạt 10.800 kg.',
          actionType: RecommendationActionType.applySchedule,
          targetMuscles: ['Đùi trước', 'Mông', 'Đùi sau'],
          recoveryPercent: 100,
        ),
      ],
    );
  }

  void applyRecommendation(String id) {
    final updated = state.recommendations.map((r) {
      if (r.id != id) return r;
      return r.copyWith(status: ProposalStatus.applied);
    }).toList();
    state = state.copyWith(recommendations: updated);
  }

  void dismissRecommendation(String id) {
    final updated = state.recommendations.map((r) {
      if (r.id != id) return r;
      return r.copyWith(status: ProposalStatus.dismissed);
    }).toList();
    state = state.copyWith(recommendations: updated);
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

    if (_containsAny(text, [
      'thuc don',
      'bua an',
      'an gi',
      'bua trua',
      'bua sang',
      'bua toi',
      'bua phu',
      'tang co',
      'giam mo',
      'protein',
    ])) {
      return _buildMealSuggestionMessage(text, now);
    }

    if (_containsAny(text, [
      'buoi tap',
      'lich tap',
      'tap gi',
      'goi y tap',
      'nguc',
      'lung',
      'chan',
      'mong',
      'vai',
      'tay',
      'full body',
      'cardio',
    ])) {
      return _buildWorkoutSuggestionMessage(text, now);
    }

    return AiChatMessage(
      id: 'assistant_general_$now',
      sender: AiMessageSender.assistant,
      text:
          'Mình có thể hỗ trợ bạn gợi ý thực đơn bữa ăn dinh dưỡng, lên lịch buổi tập thông minh hoặc điều chỉnh bài tập khi bị đau/khó chịu. Bạn muốn xem gợi ý bữa ăn hay buổi tập nào?',
    );
  }

  AiChatMessage _buildMealSuggestionMessage(String normalizedText, int now) {
    if (normalizedText.contains('bua sang')) {
      const proposal = MealProposal(
        id: 'meal_breakfast_proposal',
        status: ProposalStatus.pending,
        mealName: 'Bữa sáng giàu năng lượng',
        items: [
          MealProposalItem(
            name: 'Trứng ốp la (2 quả) & Bánh mì đen',
            serving: '2 quả + 2 lát',
            calories: 280,
            protein: 18.0,
          ),
          MealProposalItem(
            name: 'Yến mạch ngâm sữa chua Hy Lạp',
            serving: '1 hũ (150g)',
            calories: 190,
            protein: 14.5,
          ),
          MealProposalItem(
            name: 'Chuối tiêu chín',
            serving: '1 quả (100g)',
            calories: 89,
            protein: 1.1,
          ),
        ],
        reason:
            'Cung cấp carb tiêu hóa chậm và protein cao để nạp năng lượng cho cả buổi sáng.',
      );
      return AiChatMessage(
        id: 'assistant_meal_$now',
        sender: AiMessageSender.assistant,
        text:
            'Gợi ý thực đơn Bữa sáng dinh dưỡng, chuẩn bị nhanh gọn dưới 10 phút:',
        proposal: proposal,
      );
    } else if (normalizedText.contains('bua toi') ||
        normalizedText.contains('nhe bung')) {
      const proposal = MealProposal(
        id: 'meal_dinner_proposal',
        status: ProposalStatus.pending,
        mealName: 'Bữa tối thanh nhẹ & Phục hồi',
        items: [
          MealProposalItem(
            name: 'Cá hồi áp chảo sốt chanh',
            serving: '150g',
            calories: 280,
            protein: 34.0,
          ),
          MealProposalItem(
            name: 'Khoai lang luộc',
            serving: '1 củ vừa (120g)',
            calories: 110,
            protein: 2.0,
          ),
          MealProposalItem(
            name: 'Salad xà lách & Cà chua bi dầu ô liu',
            serving: '1 đĩa lớn',
            calories: 75,
            protein: 1.5,
          ),
        ],
        reason:
            'Dồi dào Omega-3 chống viêm, protein nạc và chất xơ giúp tiêu hóa nhẹ nhàng trước khi ngủ.',
      );
      return AiChatMessage(
        id: 'assistant_meal_$now',
        sender: AiMessageSender.assistant,
        text: 'Gợi ý Bữa tối lành mạnh, hỗ trợ tổng hợp cơ bắp ban đêm:',
        proposal: proposal,
      );
    } else if (normalizedText.contains('bua phu') ||
        normalizedText.contains('truoc tap') ||
        normalizedText.contains('sau tap')) {
      const proposal = MealProposal(
        id: 'meal_snack_proposal',
        status: ProposalStatus.pending,
        mealName: 'Bữa phụ nạp năng lượng',
        items: [
          MealProposalItem(
            name: 'Whey Protein Isolate (1 muỗng)',
            serving: '1 scoop (30g)',
            calories: 120,
            protein: 25.0,
          ),
          MealProposalItem(
            name: 'Táo tươi & Bơ đậu phộng nguyên chất',
            serving: '1 quả + 1 thìa cafe',
            calories: 145,
            protein: 4.5,
          ),
        ],
        reason: 'Hấp thu nhanh, chống dị hóa cơ và nạp glycogen tức thì.',
      );
      return AiChatMessage(
        id: 'assistant_meal_$now',
        sender: AiMessageSender.assistant,
        text: 'Gợi ý Bữa phụ tiện lợi nạp năng lượng trước hoặc sau khi tập:',
        proposal: proposal,
      );
    }

    // Default Lunch / High protein lunch
    const proposal = MealProposal(
      id: 'meal_lunch_proposal',
      status: ProposalStatus.pending,
      mealName: 'Bữa trưa tăng cơ (High-Protein Lunch)',
      items: [
        MealProposalItem(
          name: 'Ức gà áp chảo sốt tiêu đen',
          serving: '180g',
          calories: 285,
          protein: 52.0,
        ),
        MealProposalItem(
          name: 'Cơm gạo lứt huyết rồng',
          serving: '1 chén (150g)',
          calories: 180,
          protein: 4.5,
        ),
        MealProposalItem(
          name: 'Bông cải xanh & Măng tây hấp',
          serving: '150g',
          calories: 55,
          protein: 4.2,
        ),
      ],
      reason:
          'Cung cấp trên 60g protein chất lượng cao cùng carbohydrate phức hợp tối ưu hồi phục glycogen.',
    );
    return AiChatMessage(
      id: 'assistant_meal_$now',
      sender: AiMessageSender.assistant,
      text:
          'Gợi ý thực đơn Bữa trưa tăng cơ tối ưu theo chỉ số cá nhân của bạn:',
      proposal: proposal,
    );
  }

  AiChatMessage _buildWorkoutSuggestionMessage(String normalizedText, int now) {
    if (normalizedText.contains('nguc') ||
        normalizedText.contains('tay sau') ||
        normalizedText.contains('day') ||
        normalizedText.contains('push')) {
      const proposal = WorkoutProposal(
        id: 'workout_push_proposal',
        status: ProposalStatus.pending,
        workoutTitle: 'Buổi tập Đẩy: Ngực & Tay sau (Push Day)',
        focusArea: 'Cơ ngực, Vai trước & Tay sau',
        durationMinutes: 45,
        items: [
          WorkoutProposalItem(
            name: 'Incline Dumbbell Bench Press',
            targetMuscle: 'Ngực trên',
            setsReps: '4 hiệp × 8-10 reps',
            restSeconds: 90,
          ),
          WorkoutProposalItem(
            name: 'Barbell Flat Bench Press',
            targetMuscle: 'Ngực giữa',
            setsReps: '3 hiệp × 8-12 reps',
            restSeconds: 90,
          ),
          WorkoutProposalItem(
            name: 'Dumbbell Lateral Raise',
            targetMuscle: 'Vai giữa',
            setsReps: '4 hiệp × 12-15 reps',
            restSeconds: 60,
          ),
          WorkoutProposalItem(
            name: 'Cable Triceps Pushdown',
            targetMuscle: 'Tay sau',
            setsReps: '3 hiệp × 12-15 reps',
            restSeconds: 60,
          ),
        ],
        reason:
            'Tập trung phát triển độ dày cơ ngực trên và cắt nét vai, tay sau theo cấu trúc Push tối ưu.',
      );
      return AiChatMessage(
        id: 'assistant_workout_$now',
        sender: AiMessageSender.assistant,
        text:
            'Gợi ý Buổi tập Ngực & Tay sau (Push Day) được cá nhân hóa theo thiết bị hiện có:',
        proposal: proposal,
      );
    } else if (normalizedText.contains('lung') ||
        normalizedText.contains('keo') ||
        normalizedText.contains('tay truoc') ||
        normalizedText.contains('pull')) {
      const proposal = WorkoutProposal(
        id: 'workout_pull_proposal',
        status: ProposalStatus.pending,
        workoutTitle: 'Buổi tập Kéo: Lưng xô & Tay trước (Pull Day)',
        focusArea: 'Cơ lưng xô, Lưng giữa & Tay trước',
        durationMinutes: 45,
        items: [
          WorkoutProposalItem(
            name: 'Lat Pulldown (Kéo xô rộng tay)',
            targetMuscle: 'Lưng xô (Lats)',
            setsReps: '4 hiệp × 10-12 reps',
            restSeconds: 90,
          ),
          WorkoutProposalItem(
            name: 'Barbell Bent-Over Row',
            targetMuscle: 'Lưng giữa & Cầu vai',
            setsReps: '4 hiệp × 8-10 reps',
            restSeconds: 90,
          ),
          WorkoutProposalItem(
            name: 'Face Pulls (Kéo cáp vào mặt)',
            targetMuscle: 'Vai sau & Trâm cơ lưng',
            setsReps: '3 hiệp × 15 reps',
            restSeconds: 60,
          ),
          WorkoutProposalItem(
            name: 'Incline Dumbbell Bicep Curl',
            targetMuscle: 'Tay trước (Biceps)',
            setsReps: '3 hiệp × 10-12 reps',
            restSeconds: 60,
          ),
        ],
        reason:
            'Tạo hình vóc dáng chữ V (V-taper) nở rộng bờ lưng và dày cơ lưng giữa.',
      );
      return AiChatMessage(
        id: 'assistant_workout_$now',
        sender: AiMessageSender.assistant,
        text: 'Gợi ý Buổi tập Lưng xô & Tay trước (Pull Day) hiệu quả cao:',
        proposal: proposal,
      );
    } else if (normalizedText.contains('chan') ||
        normalizedText.contains('mong') ||
        normalizedText.contains('legs') ||
        normalizedText.contains('squat')) {
      const proposal = WorkoutProposal(
        id: 'workout_legs_proposal',
        status: ProposalStatus.pending,
        workoutTitle: 'Buổi tập Chân & Mông Toàn Diện (Leg Day)',
        focusArea: 'Đùi trước, Đùi sau, Mông & Bắp chân',
        durationMinutes: 50,
        items: [
          WorkoutProposalItem(
            name: 'Barbell Back Squat',
            targetMuscle: 'Đùi trước & Mông',
            setsReps: '4 hiệp × 6-8 reps',
            restSeconds: 120,
          ),
          WorkoutProposalItem(
            name: 'Romanian Deadlift (RDL)',
            targetMuscle: 'Đùi sau & Mông',
            setsReps: '3 hiệp × 8-10 reps',
            restSeconds: 90,
          ),
          WorkoutProposalItem(
            name: 'Bulgarian Split Squat',
            targetMuscle: 'Cơ đùi đơn & Mông',
            setsReps: '3 hiệp × 10 reps/bên',
            restSeconds: 90,
          ),
          WorkoutProposalItem(
            name: 'Standing Calf Raise',
            targetMuscle: 'Bắp chân',
            setsReps: '4 hiệp × 15 reps',
            restSeconds: 60,
          ),
        ],
        reason:
            'Kích thích hormone tăng trưởng, xây dựng nền tảng sức mạnh và săn chắc thân dưới.',
      );
      return AiChatMessage(
        id: 'assistant_workout_$now',
        sender: AiMessageSender.assistant,
        text:
            'Gợi ý Buổi tập Chân & Mông (Leg Day) đốt calo và tăng cơ mạnh mẽ:',
        proposal: proposal,
      );
    }

    // Default Full Body / 45-minute general workout
    const proposal = WorkoutProposal(
      id: 'workout_fullbody_proposal',
      status: ProposalStatus.pending,
      workoutTitle: 'Buổi tập Toàn Thân Tinh Gọn 45 Phút (Full Body)',
      focusArea: 'Ngực, Lưng, Chân & Core',
      durationMinutes: 45,
      items: [
        WorkoutProposalItem(
          name: 'Goblet Squat (Tạ ấm hoặc Tạ đơn)',
          targetMuscle: 'Chân & Core',
          setsReps: '3 hiệp × 10-12 reps',
          restSeconds: 90,
        ),
        WorkoutProposalItem(
          name: 'Dumbbell Bench Press',
          targetMuscle: 'Ngực & Tay sau',
          setsReps: '3 hiệp × 10 reps',
          restSeconds: 90,
        ),
        WorkoutProposalItem(
          name: 'Dumbbell Single Arm Row',
          targetMuscle: 'Lưng xô',
          setsReps: '3 hiệp × 10-12 reps/bên',
          restSeconds: 60,
        ),
        WorkoutProposalItem(
          name: 'Dumbbell Overhead Shoulder Press',
          targetMuscle: 'Vai toàn diện',
          setsReps: '3 hiệp × 10-12 reps',
          restSeconds: 60,
        ),
      ],
      reason:
          'Kích hoạt toàn bộ nhóm cơ chính trong thời gian ngắn, thích hợp duy trì thể lực ngày bận rộn.',
    );
    return AiChatMessage(
      id: 'assistant_workout_$now',
      sender: AiMessageSender.assistant,
      text: 'Gợi ý Buổi tập Toàn thân (Full Body) 45 phút tinh gọn:',
      proposal: proposal,
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

  void applyWorkout(String proposalId) {
    _updateProposal(proposalId, (proposal) {
      if (proposal is! WorkoutProposal ||
          proposal.status != ProposalStatus.pending) {
        return proposal;
      }
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
        WorkoutProposal() => proposal.copyWith(
          status: ProposalStatus.dismissed,
        ),
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
