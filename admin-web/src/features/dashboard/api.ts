import { auditApi } from '../audit-logs/api'
import { equipmentApi } from '../equipments/api'
import { exerciseApi } from '../exercises/api'
import { getMuscleLabel } from '../exercises/catalogConstants'
import { foodApi } from '../foods/api'
import type {
  DashboardAlertItem,
  DashboardData,
  DayActivityData,
  MacroDistributionStat,
  MuscleGroupStat,
} from './types'

export const dashboardApi = {
  async getDashboardData(): Promise<DashboardData> {
    const [exercises, foods, audits, equipments] = await Promise.all([
      exerciseApi.list(),
      foodApi.list(),
      auditApi.list(),
      equipmentApi.list(),
    ])

    // Exercise metrics
    const totalExercises = exercises.length
    const activeExercises = exercises.filter((e) => e.status === 'active').length
    const hiddenExercises = exercises.filter((e) => e.status === 'hidden').length
    const beginnerExercises = exercises.filter((e) => e.level === 'beginner').length
    const intermediateExercises = exercises.filter((e) => e.level === 'intermediate').length
    const advancedExercises = exercises.filter((e) => e.level === 'advanced').length

    // Food metrics
    const totalFoods = foods.length
    const activeFoods = foods.filter((f) => f.status === 'active').length
    const hiddenFoods = foods.filter((f) => f.status === 'hidden').length
    const standardizedFoods = foods.filter(
      (f) => f.nutrients.calories > 0 && f.nutrients.protein >= 0
    ).length
    const missingNutritionFoods = foods.filter(
      (f) => f.nutrients.calories === 0 || (f.nutrients.protein === 0 && f.nutrients.carbs === 0 && f.nutrients.fat === 0)
    ).length

    // Equipment metrics
    const totalEquipments = equipments.length
    const commonEquipments = equipments.filter((e) => e.isCommon).length

    // Audit logs metrics
    const totalAuditLogs = audits.length
    const successfulAudits = audits.filter((a) => a.resultStatus === 'SUCCESS').length
    const failedAudits = audits.filter((a) => a.resultStatus === 'FAILED').length
    const recentActivitiesCount = audits.length

    // Muscle group distribution calculated from real exercise catalog
    const muscleCounts: Record<string, number> = {}
    exercises.forEach((ex) => {
      const label = getMuscleLabel(ex.primaryMuscle)
      muscleCounts[label] = (muscleCounts[label] || 0) + 1
    })

    const muscleColors = ['#f2305a', '#ff506d', '#f4b740', '#35c76f', '#9b7bff', '#2cc7b5', '#4d8dff']
    const sortedMuscles = Object.entries(muscleCounts)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)

    const totalMuscleAssigned = exercises.length || 1
    const muscleDistribution: MuscleGroupStat[] = sortedMuscles.map(([name, count], idx) => ({
      name,
      count,
      percentage: Math.round((count / totalMuscleAssigned) * 100),
      color: muscleColors[idx % muscleColors.length] || '#f2305a',
    }))

    // Macro distribution calculated from real foods
    let totalCalories = 0
    let totalProtein = 0
    let totalCarbs = 0
    let totalFat = 0
    let highProteinCount = 0

    foods.forEach((f) => {
      totalCalories += f.nutrients.calories || 0
      totalProtein += f.nutrients.protein || 0
      totalCarbs += f.nutrients.carbs || 0
      totalFat += f.nutrients.fat || 0
      if (f.nutrients.protein >= 15) {
        highProteinCount += 1
      }
    })

    const foodCount = foods.length
    const avgCalories = foodCount === 0 ? 0 : Math.round(totalCalories / foodCount)
    const avgProtein = foodCount === 0 ? 0 : Math.round((totalProtein / foodCount) * 10) / 10
    const avgCarbs = foodCount === 0 ? 0 : Math.round((totalCarbs / foodCount) * 10) / 10
    const avgFat = foodCount === 0 ? 0 : Math.round((totalFat / foodCount) * 10) / 10

    const sumMacros = avgProtein * 4 + avgCarbs * 4 + avgFat * 9
    const proteinPercentage = sumMacros === 0 ? 0 : Math.round(((avgProtein * 4) / sumMacros) * 100)
    const carbsPercentage = sumMacros === 0 ? 0 : Math.round(((avgCarbs * 4) / sumMacros) * 100)
    const fatPercentage = sumMacros === 0 ? 0 : Math.max(0, 100 - proteinPercentage - carbsPercentage)
    const highProteinPercentage = foodCount === 0 ? 0 : Math.round((highProteinCount / foodCount) * 100)

    const macroDistribution: MacroDistributionStat = {
      avgCalories,
      avgProtein,
      avgCarbs,
      avgFat,
      proteinPercentage,
      carbsPercentage,
      fatPercentage,
      highProteinPercentage,
    }

    // Dynamic alerts from actual data
    const alerts: DashboardAlertItem[] = []

    if (missingNutritionFoods > 0) {
      alerts.push({
        id: 'missing-food-nutrition',
        type: 'warning',
        title: `${missingNutritionFoods} thực phẩm cần cập nhật chỉ số dinh dưỡng`,
        description: 'Chưa có đầy đủ thông tin Calo/Protein/Carbs/Fat chuẩn hóa theo khẩu phần.',
        actionText: 'Xem danh sách thực phẩm',
        actionLink: '/foods',
        icon: 'error_outline',
        count: missingNutritionFoods,
      })
    }

    if (hiddenExercises > 0) {
      alerts.push({
        id: 'hidden-exercises-notice',
        type: 'info',
        title: `${hiddenExercises} bài tập đang ở trạng thái tạm ẩn`,
        description: 'Các bài tập này hiện chưa xuất hiện trên ứng dụng người dùng.',
        actionText: 'Quản lý bài tập',
        actionLink: '/exercises',
        icon: 'visibility_off',
        count: hiddenExercises,
      })
    }

    if (failedAudits > 0) {
      alerts.push({
        id: 'failed-audit-events',
        type: 'error',
        title: `${failedAudits} sự kiện vận hành ghi nhận thất bại`,
        description: 'Kiểm tra nhật ký hệ thống để xác minh chi tiết lỗi và bảo mật.',
        actionText: 'Mở Audit Logs',
        actionLink: '/audit-logs',
        icon: 'warning',
        count: failedAudits,
      })
    }

    if (alerts.length === 0) {
      alerts.push({
        id: 'all-clear',
        type: 'info',
        title: 'Hệ thống vận hành tối ưu',
        description: 'Dữ liệu danh mục bài tập, thực phẩm và thiết bị đã được đồng bộ chuẩn hóa.',
        actionText: 'Xem nhật ký vận hành',
        actionLink: '/audit-logs',
        icon: 'verified_user',
      })
    }

    // 7 days activity computation
    // The catalog APIs do not expose time-series activity. Keep this empty instead of
    // manufacturing telemetry from catalog totals.
    const activityDays: DayActivityData[] = []

    return {
      totalExercises,
      activeExercises,
      hiddenExercises,
      beginnerExercises,
      intermediateExercises,
      advancedExercises,
      totalFoods,
      activeFoods,
      hiddenFoods,
      standardizedFoods,
      missingNutritionFoods,
      totalEquipments,
      commonEquipments,
      totalAuditLogs,
      successfulAudits,
      failedAudits,
      recentActivitiesCount,
      activityDays,
      alerts,
      muscleDistribution,
      macroDistribution,
    }
  },
}
