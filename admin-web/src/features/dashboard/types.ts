export interface DayActivityData {
  day: string
  label: string
  workoutCount: number
  nutritionCount: number
  aiCount: number
  workoutHeight: string
  nutritionHeight: string
  aiHeight: string
  isPeak?: boolean
  tooltip: string
}

export interface DashboardAlertItem {
  id: string
  type: 'warning' | 'error' | 'info'
  title: string
  description: string
  actionText: string
  actionLink: string
  icon: string
  count?: number
}

export interface MuscleGroupStat {
  name: string
  count: number
  percentage: number
  color: string
}

export interface MacroDistributionStat {
  avgCalories: number
  avgProtein: number
  avgCarbs: number
  avgFat: number
  proteinPercentage: number
  carbsPercentage: number
  fatPercentage: number
  highProteinPercentage: number
}

export interface DashboardData {
  totalExercises: number
  activeExercises: number
  hiddenExercises: number
  beginnerExercises: number
  intermediateExercises: number
  advancedExercises: number

  totalFoods: number
  activeFoods: number
  hiddenFoods: number
  standardizedFoods: number
  missingNutritionFoods: number

  totalEquipments: number
  commonEquipments: number

  totalAuditLogs: number
  successfulAudits: number
  failedAudits: number
  recentActivitiesCount: number

  activityDays: DayActivityData[]
  alerts: DashboardAlertItem[]
  muscleDistribution: MuscleGroupStat[]
  macroDistribution: MacroDistributionStat
}
