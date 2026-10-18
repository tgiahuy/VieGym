import React, { useState } from 'react'
import type { DayActivityData } from '../types'

interface ActivityChartProps {
  days?: DayActivityData[]
  totalExercises?: number
  totalFoods?: number
  totalAuditLogs?: number
}

export const ActivityChart: React.FC<ActivityChartProps> = ({
  days,
  totalAuditLogs = 0,
}) => {
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null)
  const chartDays = days ?? []

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

            {chartDays.length === 0 && (
              <div className="absolute inset-0 z-20 flex items-center justify-center text-sm text-[#8a8d93]">
                Chưa có endpoint cung cấp dữ liệu hoạt động theo ngày
              </div>
            )}
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
            <span className="text-[#f5f5f6] font-semibold">Chưa có dữ liệu</span>
          </div>
          <div>
            <span className="text-[#8a8d93] block text-[11px]">Tổng lượt workout:</span>
            <span className="text-[#f5f5f6] font-semibold">Chưa có dữ liệu</span>
          </div>
          <div>
            <span className="text-[#8a8d93] block text-[11px]">Nhật ký calo nạp:</span>
            <span className="text-[#f5f5f6] font-semibold">Chưa có dữ liệu</span>
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
          <span>Dữ liệu backend</span>
        </div>
      </div>
    </div>
  )
}

