import type { ExerciseItem } from './types'

export const initialExercises: ExerciseItem[] = [
  {
    id: '1',
    code: 'EX-0104',
    nameVn: 'Đẩy ngực tạ đòn',
    nameEn: 'Barbell Bench Press',
    primaryMuscle: 'chest',
    secondaryMuscles: ['Tay sau (Triceps)', 'Vai trước (Anterior Deltoid)'],
    equipment: ['Barbell', 'Ghế phẳng (Flat Bench)'],
    level: 'intermediate',
    status: 'active',
    updatedAt: '03/10/2026 09:15',
    thumbnailUrl:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAbtfJErj4nsPJix5wEXd3ThqDNcNwQxCj3-UqfcVOr8vE8ep0LRXx_gBbjdXzF3GXSFcItxS5uepWGNYdPFb8dbxu0FCKKDvOkoLSlsd3BYj65EflY7aJyGuhCscLP-UmJAnFA2Yc5X2A6IH06VNZ-OH0nBgjV2ND_ILwumY5b_5OzU-1UP6vFcE_s33fHLAo_RWcpiAILU37DrZLHvaDBSbFNsQEbDtbMa_nYDS8RO45cdBhTiQn0',
    description:
      'Bài tập phức hợp cơ bản giúp phát triển toàn diện độ dày lồng ngực, tăng sức mạnh thân trên và ổn định khớp vai. Tối ưu hoá lực phát triển cơ ngực lớn kết hợp hỗ trợ lực khóa tay sau.',
    steps: [
      {
        id: 's1',
        stepNumber: 1,
        title: 'Bước 1: Setup vị trí nằm',
        description: 'Mắt thẳng hàng dưới thanh đòn. Siết chặt 2 bả vai, đặt bàn chân vững trên sàn.',
      },
      {
        id: 's2',
        stepNumber: 2,
        title: 'Bước 2: Hạ tạ có kiểm soát',
        description: 'Hít sâu, hạ thanh đòn về điểm chạm giữa xương ức, khuỷu tay chếch 45–60 độ.',
      },
      {
        id: 's3',
        stepNumber: 3,
        title: 'Bước 3: Đẩy tạ bùng nổ',
        description: 'Thở ra mạnh, dùng lực cơ ngực đẩy thanh đòn về vị trí khóa khớp kiểm soát.',
      },
    ],
    media: [
      {
        id: 'm1',
        type: 'image',
        name: 'Cover 1:1 Bench Press',
        url: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBRnHSgBh8HsSxXUPg0ziT2KxeGEEsb0T2Jx9J2UZrXksgKXDxI9BSYOjAh6gOSVu7yCUTGU3yYS9qTM9n4hFeoJxtWyx1BTI2mYXIwW3KGJ2XWZbEliyLZyIMEvVPCNCGCgTxPS25WnOaR-aRQT9jSJia_sV7edKR34bDb0IRyxjU-uVbn2XmBjHINV1PCCPq84m8jzs6OUaJBWVL4bAqnPiPwuAH4XRQNsgokPVx3MQzJZLtwklKt',
        isCover: true,
        status: 'synced',
      },
      {
        id: 'm2',
        type: 'video',
        name: 'bench_press_1080p.mp4',
        url: '',
        sizeInfo: '48.2 MB · 60fps',
        status: 'synced',
      },
    ],
  },
  {
    id: '2',
    code: 'EX-0105',
    nameVn: 'Squat gánh tạ đòn',
    nameEn: 'Barbell Back Squat',
    primaryMuscle: 'legs',
    secondaryMuscles: ['Mông (Glutes)', 'Lưng dưới (Lower Back)'],
    equipment: ['Barbell', 'Khung squat (Power Rack)'],
    level: 'intermediate',
    status: 'active',
    updatedAt: '02/10/2026 14:20',
    thumbnailUrl:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCBiEi4_QBIbIXHu38U2rKn5QdtTm0Ke-wSwB2UXzIaK7bF8I7ODVUapTjKgEuyOpvUF7Ip4KuQUJA0FPlmoJ8Ke3OTsydhKnrEOs5CNUi8lEhKZejftlwCjvb8u4ZdLqauqSHygiL01AjtHupKisaOqKp174cqq52P8n9eMMfPrLomyVWaH8D6ClPXiIYcNucIZmsWisfVpADdMnSjXJKk5f7wdKU1KgjpVL9TKKaA7nn3YZz_TyOI',
    description:
      'Vua của các bài tập thân dưới, kích hoạt tối đa sợi cơ đùi trước, đùi sau và cơ mông đồng thời cải thiện sức mạnh lõi.',
    steps: [
      {
        id: 'sq1',
        stepNumber: 1,
        title: 'Bước 1: Đặt thanh đòn trên cầu vai',
        description: 'Vào tạ vững chãi, siết chặt lưng trên, bước lùi 2 bước mở rộng chân bằng vai.',
      },
      {
        id: 'sq2',
        stepNumber: 2,
        title: 'Bước 2: Ngồi xổm sâu',
        description: 'Gập gối và hông đồng thời, giữ lưng thẳng, hạ hông xuống dưới mức song song gối.',
      },
    ],
    media: [
      {
        id: 'm3',
        type: 'image',
        name: 'Squat Cover',
        url: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCBiEi4_QBIbIXHu38U2rKn5QdtTm0Ke-wSwB2UXzIaK7bF8I7ODVUapTjKgEuyOpvUF7Ip4KuQUJA0FPlmoJ8Ke3OTsydhKnrEOs5CNUi8lEhKZejftlwCjvb8u4ZdLqauqSHygiL01AjtHupKisaOqKp174cqq52P8n9eMMfPrLomyVWaH8D6ClPXiIYcNucIZmsWisfVpADdMnSjXJKk5f7wdKU1KgjpVL9TKKaA7nn3YZz_TyOI',
        isCover: true,
        status: 'synced',
      },
    ],
  },
  {
    id: '3',
    code: 'EX-0106',
    nameVn: 'Hít xà đơn biến thể',
    nameEn: 'Pull-up Variation',
    primaryMuscle: 'back',
    secondaryMuscles: ['Tay trước (Biceps)', 'Vai sau (Rear Deltoid)'],
    equipment: ['Xà đơn (Rig / Pull-up Bar)'],
    level: 'advanced',
    status: 'hidden',
    updatedAt: '01/10/2026 18:02',
    thumbnailUrl:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBxJBofr04i78MmREm6dHygJgLOm8AEEx5wtpHsxKgMNUnLHgLivJUDMxf4cmP7bTnVQB3bIMzbhwiqmqxK-rerVoPvz8mOC2vdzhmjbmqpqweuAh2U5naT8FV6rlnJ_Ui6Rxgd1YOcaQqa3Wh7_4-BzKO3tN5Kmb_sSJnPCoHH62VmMETHb6GVgGXIqnM-IBHUfJ6xjP59WFNQGgGGSlel5fGHwzOt-EewbYf0z3q0-wYU5uFAZiKD',
    description:
      'Bài tập trọng lượng cơ thể phát triển bề rộng lưng xô, tăng cường sức kéo và khả năng kiểm soát bả vai.',
    steps: [
      {
        id: 'pu1',
        stepNumber: 1,
        title: 'Bước 1: Nắm xà',
        description: 'Tay rộng hơn vai một chút, siết bả vai xuống trước khi kéo.',
      },
      {
        id: 'pu2',
        stepNumber: 2,
        title: 'Bước 2: Kéo cằm vượt xà',
        description: 'Kéo khuỷu tay hướng về phía túi quần sau, giữ thân người ổn định không đung đưa.',
      },
    ],
    media: [],
  },
  {
    id: '4',
    code: 'EX-0107',
    nameVn: 'Gập bụng con lăn',
    nameEn: 'Ab Wheel Rollout',
    primaryMuscle: 'abs',
    secondaryMuscles: ['Vai trước', 'Lưng xô'],
    equipment: ['Con lăn Ab Wheel'],
    level: 'advanced',
    status: 'active',
    updatedAt: '29/09/2026 11:30',
    thumbnailUrl:
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBrpnU4eYlV5jnb87sHhNR95JM5PF2qeljTawo_r942lSJoDLjua9HWmQJwkYZ6Orzsx0kjl5uVzRDRPMaj4LqOBENMyEn3QYLKG8Oh7ai2nvQj9uscsVtRgN3-N0nWMeS3njmhB9jtnV0Mol17KOKLRjUhPXOzzRcnheRGU5cODlqCU3xeALukjpD_9dJWRdFPRH4R5q8Cdc4nsvRSg9aOOjUG04v92xJq8TddzXUVdPdocrYR8S-S',
    description:
      'Kích hoạt cơ bụng thẳng và cơ lõi sâu với kháng lực chống ưỡn lưng cực đại.',
    steps: [
      {
        id: 'ab1',
        stepNumber: 1,
        title: 'Bước 1: Tư thế quỳ',
        description: 'Quỳ gối trên thảm mềm, giữ con lăn thẳng dưới ngực.',
      },
      {
        id: 'ab2',
        stepNumber: 2,
        title: 'Bước 2: Lăn người về trước',
        description: 'Gồng chặt bụng, từ từ lăn con lăn về phía trước đến khi thân người song song mặt sàn.',
      },
    ],
    media: [],
  },
]
