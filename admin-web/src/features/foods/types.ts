export type FoodCategory =
  | 'meat'
  | 'seafood'
  | 'dairy'
  | 'carbs'
  | 'vegetable'
  | 'fruit'
  | 'spice'

export type FoodSource = 'usda' | 'vn_nin' | 'viegym' | 'custom'

export type FoodStatus = 'active' | 'incomplete' | 'hidden'

export interface FoodNutrients {
  calories: number // kcal per 100g
  protein: number // g per 100g
  carbs: number // g per 100g
  fat: number // g per 100g
  fiber?: number // g
  sugar?: number // g
  sodium?: number // mg
}

export interface FoodItem {
  id: string
  code: string // e.g. "FD-0284"
  nameVi: string
  nameEn: string
  category: FoodCategory
  servingSize: number // standard reference weight in grams, default 100
  servingUnit: string // e.g. "100 g", "1 quả (55 g)", "1 tô vừa (650 g)"
  nutrients: FoodNutrients
  source: FoodSource
  sourceLabel: string
  status: FoodStatus
  image: string
  aiNotes?: string
  hasWarning?: boolean
  warningText?: string
  updatedAt: string
  version?: number
  slug?: string
  servingAmount?: number
  servingUnitRaw?: string
}

export interface FoodFilterState {
  search: string
  category: string
  source: string
  status: string
}
