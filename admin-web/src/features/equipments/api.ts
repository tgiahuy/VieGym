import { apiClient } from '../../core/api/client'
import { INITIAL_EQUIPMENTS } from './mockData'
import type { EquipmentCategory, EquipmentItem } from './types'

interface BackendEquipmentDto {
  id: number
  code: string
  name: string
  description: string | null
}

const metadataMap: Record<string, Partial<EquipmentItem>> = {
  BODYWEIGHT: {
    category: 'bodyweight',
    categoryLabel: 'Thể trọng & Calisthenics',
    nameEn: 'Bodyweight',
    iconName: 'accessibility_new',
    suitableFor: 'Mọi cấp độ, tập tại nhà hoặc ngoài trời',
    safetyNotes: 'Chú ý kiểm soát khớp và giữ tư thế cột sống trung tính.',
    exerciseCount: 28,
    isCommon: true,
  },
  DUMBBELL: {
    category: 'free_weights',
    categoryLabel: 'Tạ tự do (Free Weights)',
    nameEn: 'Dumbbell',
    iconName: 'fitness_center',
    suitableFor: 'Tăng cơ cô lập, sửa bất đối xứng cơ bắp',
    safetyNotes: 'Khóa chặt cổ tay, không thả tạ rơi tự do.',
    exerciseCount: 36,
    isCommon: true,
  },
  BARBELL: {
    category: 'free_weights',
    categoryLabel: 'Tạ tự do (Free Weights)',
    nameEn: 'Barbell',
    iconName: 'sports_gymnastics',
    suitableFor: 'Xây dựng sức mạnh tối đa, Bench Press, Squat, Deadlift',
    safetyNotes: 'Cần kẹp khóa tạ (collars) và dùng giá an toàn (safety pins).',
    exerciseCount: 42,
    isCommon: true,
  },
  BENCH: {
    category: 'accessories',
    categoryLabel: 'Ghế & Giá đỡ',
    nameEn: 'Flat Bench',
    iconName: 'event_seat',
    suitableFor: 'Hỗ trợ các bài đẩy ngực, tập cẳng tay, tập mông đùi',
    safetyNotes: 'Kiểm tra bề mặt đệm và ốc cố định trước khi chịu tải nặng.',
    exerciseCount: 18,
    isCommon: true,
  },
  CABLE_MACHINE: {
    category: 'machines',
    categoryLabel: 'Máy khối & Cáp lực',
    nameEn: 'Cable Machine',
    iconName: 'cable',
    suitableFor: 'Kéo xô, ép ngực cáp, kéo tay sau, giữ áp lực liên tục',
    safetyNotes: 'Kiểm tra chốt tạ đã ngậm sâu trước khi kéo.',
    exerciseCount: 25,
    isCommon: true,
  },
  MACHINE: {
    category: 'machines',
    categoryLabel: 'Máy khối & Cáp lực',
    nameEn: 'Selectorized Machine',
    iconName: 'precision_manufacturing',
    suitableFor: 'Leg Press, Leg Extension, Chest Press Machine',
    safetyNotes: 'Điều chỉnh vị trí yên ngồi và khớp quay đúng vị trí giải phẫu.',
    exerciseCount: 20,
    isCommon: true,
  },
  RESISTANCE_BAND: {
    category: 'accessories',
    categoryLabel: 'Dụng cụ bổ trợ',
    nameEn: 'Resistance Band',
    iconName: 'gesture',
    suitableFor: 'Khởi động khớp vai, kích hoạt cơ mông, hỗ trợ hít xà',
    safetyNotes: 'Kiểm tra bề mặt dây không bị xước rách trước khi kéo căng.',
    exerciseCount: 12,
    isCommon: false,
  },
  KETTLEBELL: {
    category: 'free_weights',
    categoryLabel: 'Tạ tự do (Free Weights)',
    nameEn: 'Kettlebell',
    iconName: 'sports_volleyball',
    suitableFor: 'Kettlebell Swing, Turkish Get Up, Goblet Squat',
    safetyNotes: 'Yêu cầu kỹ thuật gập hông (hip hinge) chuẩn để bảo vệ cột sống.',
    exerciseCount: 14,
    isCommon: false,
  },
  PULL_UP_BAR: {
    category: 'bodyweight',
    categoryLabel: 'Thể trọng & Calisthenics',
    nameEn: 'Pull-up Bar',
    iconName: 'straighten',
    suitableFor: 'Phát triển cơ lưng xô, cơ tay trước và sức mạnh bám nắm',
    safetyNotes: 'Đảm bảo xà được gắn chắc chắn, không đu giật mất kiểm soát.',
    exerciseCount: 16,
    isCommon: true,
  },
  TREADMILL: {
    category: 'cardio',
    categoryLabel: 'Thiết bị Cardio',
    nameEn: 'Treadmill',
    iconName: 'directions_run',
    suitableFor: 'Cardio HIIT, chạy bộ duy trì nhịp tim Zone 2',
    safetyNotes: 'Luôn kẹp khóa an toàn (safety key) vào áo khi chạy.',
    exerciseCount: 6,
    isCommon: false,
  },
  ADJUSTABLE_BENCH: {
    category: 'accessories',
    categoryLabel: 'Ghế & Giá đỡ',
    nameEn: 'Adjustable Bench',
    iconName: 'airline_seat_recline_extra',
    suitableFor: 'Đẩy ngực trên, vai dốc, cô lập từng góc cơ ngực',
    safetyNotes: 'Gài chốt răng cưa khớp hoàn toàn trước khi đặt lưng.',
    exerciseCount: 22,
    isCommon: true,
  },
}

function mapDto(dto: BackendEquipmentDto): EquipmentItem {
  const meta = metadataMap[dto.code] || {}
  return {
    id: dto.id,
    code: dto.code,
    name: dto.name,
    nameEn: meta.nameEn || dto.code,
    category: (meta.category || 'accessories') as EquipmentCategory,
    categoryLabel: meta.categoryLabel || 'Dụng cụ tập luyện',
    description: dto.description || meta.description || 'Dụng cụ / Thiết bị phục vụ các bài tập thể hình và rèn luyện thể lực.',
    iconName: meta.iconName || 'fitness_center',
    status: 'active',
    suitableFor: meta.suitableFor || 'Tập luyện thể hình và rèn luyện sức bền',
    safetyNotes: meta.safetyNotes || 'Tuân thủ đúng kỹ thuật động tác để bảo đảm an toàn.',
    exerciseCount: meta.exerciseCount || 10,
    isCommon: meta.isCommon ?? true,
    updatedAt: new Date().toLocaleDateString('vi-VN'),
  }
}

export const equipmentApi = {
  async list(): Promise<EquipmentItem[]> {
    try {
      const list = await apiClient<BackendEquipmentDto[]>('/equipment')
      if (Array.isArray(list) && list.length > 0) {
        return list.map(mapDto)
      }
      return INITIAL_EQUIPMENTS
    } catch {
      return INITIAL_EQUIPMENTS
    }
  },
}
