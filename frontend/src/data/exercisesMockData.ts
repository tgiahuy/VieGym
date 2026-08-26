export const exercises = [
  {
    id: 'ex1',
    name: 'Barbell Bench Press',
    primaryMuscle: 'Ngực',
    equipment: 'Tạ đòn',
    thumbnailUrl: 'https://via.placeholder.com/150/191921/FFFFFF?text=Bench',
    videoUrl: 'https://videos.pexels.com/video-files/3838708/3838708-hd.mp4',
    instructions: [
      'Nằm trên ghế phẳng, hai chân đặt chắc chắn trên sàn.',
      'Nắm thanh đòn rộng hơn vai một chút, nhấc ra khỏi giá đỡ.',
      'Hạ thanh đòn xuống ngực một cách có kiểm soát.',
      'Đẩy mạnh thanh đòn trở lại vị trí ban đầu.',
    ],
  },
  {
    id: 'ex2',
    name: 'Incline Dumbbell Press',
    primaryMuscle: 'Ngực',
    equipment: 'Tạ đơn',
    thumbnailUrl: 'https://via.placeholder.com/150/191921/FFFFFF?text=Incline',
    videoUrl: 'https://videos.pexels.com/video-files/3838708/3838708-hd.mp4',
    instructions: [],
  },
  {
    id: 'ex3',
    name: 'Overhead Press',
    primaryMuscle: 'Vai',
    equipment: 'Tạ đòn',
    thumbnailUrl: 'https://via.placeholder.com/150/191921/FFFFFF?text=OHP',
    videoUrl: 'https://videos.pexels.com/video-files/3838708/3838708-hd.mp4',
    instructions: [],
  },
  {
    id: 'ex4',
    name: 'Tricep Pushdown',
    primaryMuscle: 'Tay sau',
    equipment: 'Máy kéo cáp',
    thumbnailUrl: 'https://via.placeholder.com/150/191921/FFFFFF?text=Pushdown',
    videoUrl: 'https://videos.pexels.com/video-files/3838708/3838708-hd.mp4',
    instructions: [],
  },
  {
    id: 'ex5',
    name: 'Squat',
    primaryMuscle: 'Chân',
    equipment: 'Tạ đòn',
    thumbnailUrl: 'https://via.placeholder.com/150/191921/FFFFFF?text=Squat',
    videoUrl: 'https://videos.pexels.com/video-files/3838708/3838708-hd.mp4',
    instructions: [],
  },
];

export const findExerciseById = (id: string) => exercises.find(ex => ex.id === id);