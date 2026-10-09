export interface CatalogOption {
  id: number
  code: string
  name: string
}

export const MUSCLE_GROUPS: CatalogOption[] = [
  { id: 1, code: 'ABS', name: 'Cơ bụng' },
  { id: 2, code: 'ABDUCTORS', name: 'Cơ dạng hông' },
  { id: 3, code: 'ADDUCTORS', name: 'Cơ khép hông' },
  { id: 4, code: 'BICEPS', name: 'Cơ tay trước' },
  { id: 5, code: 'CALVES', name: 'Cơ bắp chân' },
  { id: 6, code: 'CHEST', name: 'Cơ ngực' },
  { id: 7, code: 'FOREARMS', name: 'Cơ cẳng tay' },
  { id: 8, code: 'GLUTES', name: 'Cơ mông' },
  { id: 9, code: 'HAMSTRINGS', name: 'Cơ đùi sau' },
  { id: 10, code: 'LATS', name: 'Cơ lưng xô' },
  { id: 11, code: 'LOWER_BACK', name: 'Cơ lưng dưới' },
  { id: 12, code: 'NECK', name: 'Cơ cổ' },
  { id: 13, code: 'QUADRICEPS', name: 'Cơ đùi trước' },
  { id: 14, code: 'SHOULDERS', name: 'Cơ vai' },
  { id: 15, code: 'TRAPS', name: 'Cơ cầu vai' },
  { id: 16, code: 'TRICEPS', name: 'Cơ tay sau' },
  { id: 17, code: 'UPPER_BACK', name: 'Cơ lưng trên' },
]

export const EQUIPMENTS: CatalogOption[] = [
  { id: 1, code: 'BODYWEIGHT', name: 'Trọng lượng cơ thể' },
  { id: 2, code: 'DUMBBELL', name: 'Tạ đơn' },
  { id: 3, code: 'BARBELL', name: 'Tạ đòn' },
  { id: 4, code: 'BENCH', name: 'Ghế tập' },
  { id: 5, code: 'CABLE_MACHINE', name: 'Máy cáp' },
  { id: 6, code: 'MACHINE', name: 'Máy tập' },
  { id: 7, code: 'RESISTANCE_BAND', name: 'Dây kháng lực' },
  { id: 8, code: 'KETTLEBELL', name: 'Tạ ấm' },
  { id: 9, code: 'PULL_UP_BAR', name: 'Xà đơn' },
  { id: 10, code: 'TREADMILL', name: 'Máy chạy bộ' },
  { id: 11, code: 'ADJUSTABLE_BENCH', name: 'Ghế tập điều chỉnh' },
]

const muscleLookup: Record<string, string> = {
  '1': 'Cơ bụng',
  '2': 'Cơ dạng hông',
  '3': 'Cơ khép hông',
  '4': 'Cơ tay trước',
  '5': 'Cơ bắp chân',
  '6': 'Cơ ngực',
  '7': 'Cơ cẳng tay',
  '8': 'Cơ mông',
  '9': 'Cơ đùi sau',
  '10': 'Cơ lưng xô',
  '11': 'Cơ lưng dưới',
  '12': 'Cơ cổ',
  '13': 'Cơ đùi trước',
  '14': 'Cơ vai',
  '15': 'Cơ cầu vai',
  '16': 'Cơ tay sau',
  '17': 'Cơ lưng trên',
  abs: 'Cơ bụng',
  abductors: 'Cơ dạng hông',
  adductors: 'Cơ khép hông',
  biceps: 'Cơ tay trước',
  calves: 'Cơ bắp chân',
  chest: 'Cơ ngực',
  forearms: 'Cơ cẳng tay',
  glutes: 'Cơ mông',
  hamstrings: 'Cơ đùi sau',
  lats: 'Cơ lưng xô',
  lower_back: 'Cơ lưng dưới',
  neck: 'Cơ cổ',
  quadriceps: 'Cơ đùi trước',
  quads: 'Cơ đùi trước',
  shoulders: 'Cơ vai',
  traps: 'Cơ cầu vai',
  triceps: 'Cơ tay sau',
  upper_back: 'Cơ lưng trên',
  back: 'Cơ lưng xô',
  legs: 'Cơ đùi & Mông',
  arms: 'Cơ tay',
}

const equipmentLookup: Record<string, string> = {
  '1': 'Trọng lượng cơ thể',
  '2': 'Tạ đơn',
  '3': 'Tạ đòn',
  '4': 'Ghế tập',
  '5': 'Máy cáp',
  '6': 'Máy tập',
  '7': 'Dây kháng lực',
  '8': 'Tạ ấm',
  '9': 'Xà đơn',
  '10': 'Máy chạy bộ',
  '11': 'Ghế tập điều chỉnh',
  bodyweight: 'Trọng lượng cơ thể',
  dumbbell: 'Tạ đơn',
  barbell: 'Tạ đòn',
  bench: 'Ghế tập',
  cable_machine: 'Máy cáp',
  cable: 'Máy cáp',
  machine: 'Máy tập',
  resistance_band: 'Dây kháng lực',
  band: 'Dây kháng lực',
  kettlebell: 'Tạ ấm',
  pull_up_bar: 'Xà đơn',
  pullup_bar: 'Xà đơn',
  treadmill: 'Máy chạy bộ',
  adjustable_bench: 'Ghế tập điều chỉnh',
}

export function getMuscleLabel(value: string | number): string {
  if (!value) return 'Chưa phân loại'
  const key = String(value).trim().toLowerCase()
  return muscleLookup[key] || String(value)
}

export function getEquipmentLabel(value: string | number): string {
  if (!value) return 'Không có'
  const key = String(value).trim().toLowerCase()
  return equipmentLookup[key] || String(value)
}
