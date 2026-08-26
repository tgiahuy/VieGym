export const homeMockData = {
  user: {
    name: 'Huy',
    avatarUrl: 'https://i.pravatar.cc/150?u=huy',
  },
  todayWorkout: {
    name: 'Upper Body A',
    muscleGroups: ['Ngực', 'Vai', 'Tay sau'],
    exerciseCount: 6,
    durationMinutes: 55,
  },
  nutrition: {
    calories: {
      consumed: 1640,
      target: 2500,
    },
    protein: {
      consumed: 126,
      target: 160,
    },
    carbs: {
      consumed: 180,
      target: 250,
    },
    fat: {
      consumed: 52,
      target: 70,
    },
  },
  aiInsight: {
    title: 'Gợi ý từ VieGym AI',
    message: 'Cơ ngực của bạn chưa phục hồi hoàn toàn. Tôi đã giảm volume các bài đẩy trong buổi tập hôm nay.',
  },
  recovery: [
    { muscle: 'Ngực', percentage: 82 },
    { muscle: 'Lưng', percentage: 100 },
    { muscle: 'Chân', percentage: 91 },
  ],
  weeklyProgress: {
    completed: 3,
    target: 4,
    streak: 3,
  },
};