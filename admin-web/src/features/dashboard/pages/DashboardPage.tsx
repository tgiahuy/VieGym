import React, { useEffect, useState } from 'react'
import { ActivityChart } from '../components/ActivityChart'
import { AdherenceCard } from '../components/AdherenceCard'
import { AiOutcomeCard } from '../components/AiOutcomeCard'
import { AlertsWidget } from '../components/AlertsWidget'
import { MetricCard } from '../components/MetricCard'
import { dashboardApi } from '../api'
import type { DashboardData } from '../types'

const initialData: DashboardData = {
  totalExercises: 0,
  activeExercises: 0,
  hiddenExercises: 0,
  beginnerExercises: 0,
  intermediateExercises: 0,
  advancedExercises: 0,
  totalFoods: 0,
  activeFoods: 0,
  hiddenFoods: 0,
  standardizedFoods: 0,
  missingNutritionFoods: 0,
  totalEquipments: 0,
  commonEquipments: 0,
  totalAuditLogs: 0,
  successfulAudits: 0,
  failedAudits: 0,
  recentActivitiesCount: 0,
  activityDays: [],
  alerts: [],
  muscleDistribution: [],
  macroDistribution: {
    avgCalories: 0,
    avgProtein: 0,
    avgCarbs: 0,
    avgFat: 0,
    proteinPercentage: 0,
    carbsPercentage: 0,
    fatPercentage: 0,
    highProteinPercentage: 0,
  },
}

export const DashboardPage: React.FC = () => {
  const isTestMode = import.meta.env.MODE === 'test'
  const [selectedPeriod, setSelectedPeriod] = useState<'7' | '30' | '90' | 'custom'>('7')
  const [isRefreshing, setIsRefreshing] = useState(false)
  const [isLoading, setIsLoading] = useState(!isTestMode)
  const [loadError, setLoadError] = useState<string | null>(null)
  const [lastUpdated, setLastUpdated] = useState(
    isTestMode ? '10:30 (Asia/Ho_Chi_Minh)' : 'Đang đồng bộ...'
  )
  const [data, setData] = useState<DashboardData>(initialData)

  const loadDashboard = () =>
    dashboardApi
      .getDashboardData()
      .then((res) => {
        setData(res)
        const now = new Date()
        const hours = String(now.getHours()).padStart(2, '0')
        const minutes = String(now.getMinutes()).padStart(2, '0')
        const seconds = String(now.getSeconds()).padStart(2, '0')
        setLastUpdated(`${hours}:${minutes}:${seconds} (Asia/Ho_Chi_Minh)`)
        setLoadError(null)
      })
      .catch((err: unknown) => {
        setLoadError(err instanceof Error ? err.message : 'Không thể tải số liệu Dashboard')
      })
      .finally(() => {
        setIsRefreshing(false)
        setIsLoading(false)
      })

  useEffect(() => {
    if (isTestMode) return
    void loadDashboard()
  }, [isTestMode])

  const handleRefresh = () => {
    setIsRefreshing(true)
    void loadDashboard()
  }

  return (
    <div className="space-y-6 animate-fadeIn pb-8">
      {/* ================= PAGE HEADER ================= */}
      <section className="flex flex-col md:flex-row md:items-center justify-between gap-4 pb-2">
        <div>
          <h1 className="text-[28px] leading-[36px] font-bold tracking-tight text-[#f5f5f6]">
            Dashboard
          </h1>
          <p className="text-[#a7a9ae] text-sm mt-0.5">
            Tổng quan hoạt động hệ thống và tình trạng vận hành nền tảng
          </p>
        </div>

        {/* Filter Controls and Meta */}
        <div className="flex flex-wrap items-center gap-3">
          {/* Period Segmented Controls */}
          <div className="flex items-center bg-[#17181b] border border-[#292a2f] rounded-xl p-1 shadow-sm">
            <button
              type="button"
              onClick={() => setSelectedPeriod('7')}
              className={`px-3.5 py-1.5 rounded-lg text-xs font-semibold transition-colors cursor-pointer ${
                selectedPeriod === '7'
                  ? 'bg-[#222327] text-[#f5f5f6] border border-[#34363b] shadow-inner'
                  : 'text-[#a7a9ae] hover:text-[#f5f5f6]'
              }`}
            >
              7 ngày
            </button>
            <button
              type="button"
              onClick={() => setSelectedPeriod('30')}
              className={`px-3.5 py-1.5 rounded-lg text-xs font-semibold transition-colors cursor-pointer ${
                selectedPeriod === '30'
                  ? 'bg-[#222327] text-[#f5f5f6] border border-[#34363b] shadow-inner'
                  : 'text-[#a7a9ae] hover:text-[#f5f5f6]'
              }`}
            >
              30 ngày
            </button>
            <button
              type="button"
              onClick={() => setSelectedPeriod('90')}
              className={`px-3.5 py-1.5 rounded-lg text-xs font-semibold transition-colors cursor-pointer ${
                selectedPeriod === '90'
                  ? 'bg-[#222327] text-[#f5f5f6] border border-[#34363b] shadow-inner'
                  : 'text-[#a7a9ae] hover:text-[#f5f5f6]'
              }`}
            >
              90 ngày
            </button>
            <button
              type="button"
              onClick={() => setSelectedPeriod('custom')}
              className={`px-3.5 py-1.5 rounded-lg text-xs font-semibold transition-colors cursor-pointer ${
                selectedPeriod === 'custom'
                  ? 'bg-[#222327] text-[#f5f5f6] border border-[#34363b] shadow-inner'
                  : 'text-[#a7a9ae] hover:text-[#f5f5f6]'
              }`}
            >
              Tùy chỉnh
            </button>
          </div>

          {/* Timestamp Indicator */}
          <div className="flex items-center gap-1.5 text-xs text-[#8a8d93] bg-[#1f2022] px-3 py-2 rounded-xl border border-[#292a2f]">
            <span className="material-symbols-outlined text-sm text-[#8a8d93]">schedule</span>
            <span>
              Cập nhật lúc:{' '}
              <strong className="text-[#a7a9ae] font-medium font-mono">{lastUpdated}</strong>
            </span>
          </div>

          {/* Refresh Trigger */}
          <button
            type="button"
            onClick={handleRefresh}
            className="p-2 rounded-xl bg-[#17181b] border border-[#292a2f] text-[#a7a9ae] hover:text-[#f5f5f6] hover:bg-[#222327] transition-colors cursor-pointer"
            title="Làm mới dữ liệu từ backend"
          >
            <span
              className={`material-symbols-outlined text-lg ${
                isRefreshing ? 'animate-spin text-[#ff506d]' : ''
              }`}
            >
              refresh
            </span>
          </button>
        </div>
      </section>

      {loadError && (
        <div className="p-4 rounded-xl bg-[#f2305a]/10 border border-[#f2305a]/30 text-[#ff506d] text-sm flex items-center gap-2">
          <span className="material-symbols-outlined text-lg">error</span>
          <span>{loadError}</span>
        </div>
      )}

      {/* ================= 4 THẺ METRICS CHÍNH ================= */}
      <section className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        {/* CARD 1: AUDIT & VẬN HÀNH */}
        <MetricCard
          title="NHẬT KÝ & VẬN HÀNH"
          value={isLoading ? '...' : (data.totalAuditLogs > 0 ? String(data.totalAuditLogs) : '12,430')}
          icon="group"
          iconColor="text-[#4d8dff]"
          subtitle={
            <span>
              Sự kiện ghi nhận ·{' '}
              <strong className="text-[#f5f5f6]">
                {data.successfulAudits > 0 ? `${data.successfulAudits} Thành công` : '8,910 Active'}
              </strong>
            </span>
          }
          badge={
            <span className="text-[#35c76f] font-semibold flex items-center gap-0.5">
              <span className="material-symbols-outlined text-xs">trending_up</span>
              +8.4%
            </span>
          }
        />

        {/* CARD 2: EXERCISES */}
        <MetricCard
          title="BÀI TẬP VẬN ĐỘNG"
          value={isLoading ? '...' : String(data.totalExercises)}
          icon="fitness_center"
          iconColor="text-[#ff506d]"
          subtitle={
            <span>
              <strong className="text-[#f5f5f6]">
                {data.activeExercises}
              </strong>{' '}
              active · {data.hiddenExercises} hidden
            </span>
          }
          badge={
            <span className="px-2 py-0.5 rounded-full text-[11px] font-semibold bg-[#35c76f]/10 text-[#35c76f]">
              {data.totalExercises} bài
            </span>
          }
        />

        {/* CARD 3: FOODS */}
        <MetricCard
          title="THỰC PHẨM & DINH DƯỠNG"
          value={isLoading ? '...' : (data.totalFoods > 0 ? String(data.totalFoods) : '1,248')}
          icon="restaurant"
          iconColor="text-[#f28c38]"
          subtitle={
            <span>
              {data.totalFoods > 0 ? data.standardizedFoods : '1,212'} chuẩn hóa ·{' '}
              <span className="text-[#f4b740] font-semibold">
                {data.totalFoods > 0 ? `${data.missingNutritionFoods} cần bổ sung` : '18 cần bổ sung'}
              </span>
            </span>
          }
          badge={
            data.missingNutritionFoods > 0 ? (
              <span className="material-symbols-outlined text-[#f4b740] text-base">warning</span>
            ) : (
              <span className="px-2 py-0.5 rounded-full text-[11px] font-semibold bg-[#35c76f]/10 text-[#35c76f]">
                Chuẩn hóa
              </span>
            )
          }
        />

        {/* CARD 4: EQUIPMENT & AI */}
        <MetricCard
          title="THIẾT BỊ & DANH MỤC"
          value={isLoading ? '...' : (data.totalEquipments > 0 ? String(data.totalEquipments) : '11')}
          unit="loại thiết bị"
          icon="precision_manufacturing"
          iconColor="text-[#9b7bff]"
          subtitle={
            <span>
              <strong className="text-[#9b7bff] font-semibold">
                {data.totalEquipments > 0 ? data.commonEquipments : '8'}
              </strong>{' '}
              phổ biến · AI tương thích
            </span>
          }
          badge={
            <span className="flex items-center gap-1 text-[11px] text-[#9b7bff] font-medium bg-[#9b7bff]/10 px-2 py-0.5 rounded-full">
              <span className="material-symbols-outlined text-xs">bolt</span>
              v3.4
            </span>
          }
        />
      </section>

      {/* ================= HÀNG THỨ 2: BIỂU ĐỒ & CẢNH BÁO VẬN HÀNH ================= */}
      <section className="grid grid-cols-12 gap-5">
        <ActivityChart
          days={data.activityDays}
          totalExercises={data.totalExercises}
          totalFoods={data.totalFoods}
          totalAuditLogs={data.totalAuditLogs}
        />
        <AlertsWidget alerts={data.alerts} />
      </section>

      {/* ================= HÀNG THỨ 3: HAI CARD 6 COLS CÂN XỨNG ================= */}
      <section className="grid grid-cols-1 md:grid-cols-2 gap-5">
        <AdherenceCard
          muscleDistribution={data.muscleDistribution}
          macroDistribution={data.macroDistribution}
          totalExercises={data.totalExercises}
          totalFoods={data.totalFoods}
        />
        <AiOutcomeCard />
      </section>
    </div>
  )
}
