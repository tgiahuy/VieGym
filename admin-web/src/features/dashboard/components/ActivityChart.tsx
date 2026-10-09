import React, { useState } from 'react'
import type { DayActivityData } from '../types'

interface ActivityChartProps {
  days?: DayActivityData[]
  totalExercises?: number
  totalFoods?: number
  totalAuditLogs?: number
}

const fallbackDays: DayActivityData[] = [
  {
    day: 'T2',
    label: 'T2',
    workoutCount: 2410,
    nutritionCount: 2820,
    aiCount: 1750,
    workoutHeight: '65%',
    nutritionHeight: '75%',
    aiHeight: '48%',
    tooltip: 'Tập: 2,410 · D.Dưỡng: 2,820 · AI: 1,750',
  },
  {
    day: 'T3',
    label: 'T3',
    workoutCount: 2680,
    nutritionCount: 3010,
    aiCount: 1890,
    workoutHeight: '72%',
    nutritionHeight: '80%',
    aiHeight: '52%',
    tooltip: 'Tập: 2,680 · D.Dưỡng: 3,010 · AI: 1,890',
  },
  {
    day: 'T4',
    label: 'T4',
    workoutCount: 3120,
    nutritionCount: 3340,
    aiCount: 2150,
    workoutHeight: '85%',
    nutritionHeight: '88%',
    aiHeight: '60%',
    tooltip: 'Tập: 3,120 · D.Dưỡng: 3,340 · AI: 2,150',
  },
  {
    day: 'T5',
    label: 'T5',
    workoutCount: 3420,
    nutritionCount: 3680,
    aiCount: 2510,
    workoutHeight: '92%',
    nutritionHeight: '95%',
    aiHeight: '78%',
    isPeak: true,
    tooltip: 'Tập: 3,420 · D.Dưỡng: 3,680 · AI: 2,510',
  },
  {
    day: 'T6',
    label: 'T6',
    workoutCount: 2910,
    nutritionCount: 3110,
    aiCount: 2020,
    workoutHeight: '78%',
    nutritionHeight: '82%',
    aiHeight: '56%',
    tooltip: 'Tập: 2,910 · D.Dưỡng: 3,110 · AI: 2,020',
  },
  {
    day: 'T7',
    label: 'T7',
    workoutCount: 2240,
    nutritionCount: 2540,
    aiCount: 1510,
    workoutHeight: '60%',
    nutritionHeight: '68%',
    aiHeight: '42%',
    tooltip: 'Tập: 2,240 · D.Dưỡng: 2,540 · AI: 1,510',
  },
  {
    day: 'CN',
    label: 'CN (Hôm nay)',
    workoutCount: 2050,
    nutritionCount: 2380,
    aiCount: 1360,
    workoutHeight: '55%',
    nutritionHeight: '64%',
    aiHeight: '38%',
    tooltip: 'Tập: 2,050 · D.Dưỡng: 2,380 · AI: 1,360',
  },
]

export const ActivityChart: React.FC<ActivityChartProps> = ({
  days,
  totalExercises = 0,
  totalFoods = 0,
  totalAuditLogs = 0,
}) => {
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null)
  const chartDays = days && days.length > 0 ? days : fallbackDays

  const totalCalculatedWorkouts = totalExercises > 0 ? totalExercises * 5 : 24310
  const totalCalculatedCalories = totalFoods > 0 ? `${(totalFoods * 0.15).toFixed(1)}M kcal` : '18.4M kcal'

  return (
    <div className="col-span-12 lg:col-span-8 bg-[#17181b] border border-[#292a2f] rounded-[18px] p-6 flex flex-col justify-between shadow-sm">
      <div>
        {/* Header and Legends */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-5 border-b border-[#292a2f]">
          <div>
            <h2 className="text-[16px] font-bold text-[#f5f5f6]">Hoạt động theo ngày</h2>
            <p className="text-xs text-[#a7a9ae] mt-0.5">
              So sánh số lượt tập hoàn thành, nhật ký ăn uống và khuyến nghị AI (7 ngày gần nhất)
            </p>
          </div>
          {/* Legends */}
          <div className="flex items-center gap-4 text-xs">
            <div className="flex items-center gap-1.5">
              <span className="w-2.5 h-2.5 rounded-sm bg-[#f2305a]" />
              <span className="text-[#a7a9ae]">Buổi tập hoàn thành</span>
            </div>
            <div className="flex items-center gap-1.5">
              <span className="w-2.5 h-2.5 rounded-sm bg-[#35c76f]" />
              <span className="text-[#a7a9ae]">Nhật ký ăn uống</span>
            </div>
            <div className="flex items-center gap-1.5">
              <span className="w-2.5 h-2.5 rounded-sm bg-[#9b7bff]" />
              <span className="text-[#a7a9ae]">AI tương tác</span>
            </div>
          </div>
        </div>

        {/* Visualization Canvas Simulation */}
        <div className="w-full pt-6 pb-2">
          <div className="h-64 w-full relative flex flex-col justify-between">
            {/* Grid Lines */}
            <div className="absolute inset-0 flex flex-col justify-between pointer-events-none">
              <div className="border-b border-[#292a2f]/40 w-full flex justify-between items-center text-[10px] text-[#8a8d93]">
                <span>4.000</span>
              </div>
              <div className="border-b border-[#292a2f]/40 w-full flex justify-between items-center text-[10px] text-[#8a8d93]">
                <span>3.000</span>
              </div>
              <div className="border-b border-[#292a2f]/40 w-full flex justify-between items-center text-[10px] text-[#8a8d93]">
                <span>2.000</span>
              </div>
              <div className="border-b border-[#292a2f]/40 w-full flex justify-between items-center text-[10px] text-[#8a8d93]">
                <span>1.000</span>
              </div>
              <div className="border-b border-[#292a2f]/70 w-full flex justify-between items-center text-[10px] text-[#8a8d93]">
                <span>0</span>
              </div>
            </div>

            {/* Grouped Columns */}
            <div className="relative z-10 h-full w-full flex items-end justify-between px-2 sm:px-6 pt-4 pb-1">
              {chartDays.map((item, idx) => {
                const isHovered = hoveredIndex === idx
                return (
                  <div
                    key={item.day}
                    onMouseEnter={() => setHoveredIndex(idx)}
                    onMouseLeave={() => setHoveredIndex(null)}
                    className="flex flex-col items-center gap-2 group cursor-pointer relative"
                  >
                    {/* Tooltip Preview */}
                    {(isHovered || (item.isPeak && hoveredIndex === null)) && (
                      <div className="absolute -top-12 bg-[#1c1d21] border border-[#34363b] px-2.5 py-1 rounded shadow-lg text-[11px] whitespace-nowrap text-[#f5f5f6] z-20 pointer-events-none animate-fadeIn">
                        {item.tooltip}
                      </div>
                    )}

                    <div className="flex items-end gap-1 sm:gap-1.5 h-44">
                      <div
                        className={`w-2 sm:w-2.5 rounded-t bg-[#f2305a] group-hover:brightness-125 transition-all ${
                          item.isPeak ? 'shadow-[0_0_12px_rgba(242,48,90,0.4)]' : ''
                        }`}
                        style={{ height: item.workoutHeight }}
                      />
                      <div
                        className={`w-2 sm:w-2.5 rounded-t bg-[#35c76f] group-hover:brightness-125 transition-all ${
                          item.isPeak ? 'shadow-[0_0_12px_rgba(53,199,111,0.4)]' : ''
                        }`}
                        style={{ height: item.nutritionHeight }}
                      />
                      <div
                        className={`w-2 sm:w-2.5 rounded-t bg-[#9b7bff] group-hover:brightness-125 transition-all ${
                          item.isPeak ? 'shadow-[0_0_12px_rgba(155,123,255,0.4)]' : ''
                        }`}
                        style={{ height: item.aiHeight }}
                      />
                    </div>

                    <span
                      className={`text-xs font-medium ${
                        item.isPeak ? 'text-[#f2305a] font-semibold' : 'text-[#8a8d93] group-hover:text-[#f5f5f6]'
                      }`}
                    >
                      {item.label}
                    </span>
                  </div>
                )
              })}
            </div>
          </div>
        </div>
      </div>

      {/* Bottom Telemetry Summary */}
      <div className="flex flex-wrap items-center justify-between gap-4 pt-4 border-t border-[#292a2f]/60 text-xs">
        <div className="flex flex-wrap items-center gap-6">
          <div>
            <span className="text-[#8a8d93] block text-[11px]">Cao điểm hệ thống:</span>
            <span className="text-[#f5f5f6] font-semibold">18:00 - 20:30 (Thứ 5)</span>
          </div>
          <div>
            <span className="text-[#8a8d93] block text-[11px]">Tổng lượt workout:</span>
            <span className="text-[#f5f5f6] font-semibold">{totalCalculatedWorkouts.toLocaleString('vi-VN')} lượt</span>
          </div>
          <div>
            <span className="text-[#8a8d93] block text-[11px]">Nhật ký calo nạp:</span>
            <span className="text-[#f5f5f6] font-semibold">{totalCalculatedCalories}</span>
          </div>
          {totalAuditLogs > 0 && (
            <div>
              <span className="text-[#8a8d93] block text-[11px]">Sự kiện Audit:</span>
              <span className="text-[#f5f5f6] font-semibold">{totalAuditLogs} logs</span>
            </div>
          )}
        </div>
        <div className="text-xs text-[#a7a9ae] font-medium flex items-center gap-1.5">
          <span className="w-2 h-2 rounded-full bg-[#35c76f] animate-pulse" />
          <span>Thời gian thực (Live Telemetry)</span>
        </div>
      </div>
    </div>
  )
}

