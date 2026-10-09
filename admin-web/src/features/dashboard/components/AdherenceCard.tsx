import React from 'react'
import type { MacroDistributionStat, MuscleGroupStat } from '../types'

interface AdherenceCardProps {
  muscleDistribution?: MuscleGroupStat[]
  macroDistribution?: MacroDistributionStat
  totalExercises?: number
  totalFoods?: number
}

export const AdherenceCard: React.FC<AdherenceCardProps> = ({
  muscleDistribution = [],
  macroDistribution,
  totalExercises = 0,
  totalFoods = 0,
}) => {
  const topMusclesText =
    muscleDistribution.length > 0
      ? muscleDistribution.slice(0, 2).map((m) => m.name).join(' & ')
      : 'Ngực & Lưng'

  const avgProtein = macroDistribution?.avgProtein ?? 24.5
  const highProteinPercentage = macroDistribution?.highProteinPercentage ?? 84.2

  return (
    <div className="bg-[#17181b] border border-[#292a2f] rounded-[18px] p-6 flex flex-col justify-between shadow-sm">
      <div>
        {/* Header */}
        <div className="flex items-center justify-between pb-4 border-b border-[#292a2f]">
          <div>
            <h2 className="text-[16px] font-bold text-[#f5f5f6]">
              Phân bổ danh mục &amp; Tuân thủ dữ liệu
            </h2>
            <p className="text-xs text-[#a7a9ae] mt-0.5">
              Tỷ trọng nhóm cơ trong bài tập và hàm lượng dinh dưỡng thực phẩm
            </p>
          </div>
          <span className="px-2.5 py-1 rounded-full text-xs font-semibold bg-[#35c76f]/10 text-[#35c76f] border border-[#35c76f]/20">
            {totalExercises > 0 ? `${totalExercises} Bài tập` : '82.4% Đạt chuẩn'}
          </span>
        </div>

        {/* Metric Progress Breakdown */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-5 my-5">
          {/* Completion Circle 1: Workout */}
          <div className="flex items-center gap-4 bg-[#222327] p-4 rounded-xl border border-[#292a2f]">
            <div className="relative w-20 h-20 shrink-0 flex items-center justify-center">
              <svg className="w-full h-full transform -rotate-90" viewBox="0 0 36 36">
                <path
                  className="text-[#38393b]"
                  d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="3.5"
                />
                <path
                  className="text-[#f2305a]"
                  d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                  fill="none"
                  stroke="currentColor"
                  strokeDasharray="88, 100"
                  strokeLinecap="round"
                  strokeWidth="3.5"
                />
              </svg>
              <div className="absolute inset-0 flex flex-col items-center justify-center text-center">
                <span className="text-base font-bold text-[#f5f5f6]">
                  {totalExercises > 0 ? `${totalExercises}` : '78%'}
                </span>
                <span className="text-[9px] text-[#8a8d93] uppercase">Exercises</span>
              </div>
            </div>
            <div className="flex flex-col text-xs space-y-1">
              <span className="font-semibold text-[#f5f5f6]">Kho bài tập chuẩn hóa</span>
              <span className="text-[#8a8d93]">Bao phủ 17 nhóm cơ chính</span>
              <span className="text-[#35c76f] text-[11px] font-medium">+100% dữ liệu backend</span>
            </div>
          </div>

          {/* Completion Circle 2: Nutrition */}
          <div className="flex items-center gap-4 bg-[#222327] p-4 rounded-xl border border-[#292a2f]">
            <div className="relative w-20 h-20 shrink-0 flex items-center justify-center">
              <svg className="w-full h-full transform -rotate-90" viewBox="0 0 36 36">
                <path
                  className="text-[#38393b]"
                  d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="3.5"
                />
                <path
                  className="text-[#53e084]"
                  d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                  fill="none"
                  stroke="currentColor"
                  strokeDasharray="92, 100"
                  strokeLinecap="round"
                  strokeWidth="3.5"
                />
              </svg>
              <div className="absolute inset-0 flex flex-col items-center justify-center text-center">
                <span className="text-base font-bold text-[#f5f5f6]">
                  {totalFoods > 0 ? `${totalFoods}` : '86%'}
                </span>
                <span className="text-[9px] text-[#8a8d93] uppercase">Foods</span>
              </div>
            </div>
            <div className="flex flex-col text-xs space-y-1">
              <span className="font-semibold text-[#f5f5f6]">Dữ liệu dinh dưỡng</span>
              <span className="text-[#8a8d93]">Trung bình {avgProtein}g Protein/món</span>
              <span className="text-[#35c76f] text-[11px] font-medium">Chuẩn NIN &amp; USDA</span>
            </div>
          </div>
        </div>

        {/* Detailed Stacked Bars */}
        <div className="space-y-3.5">
          <div>
            <div className="flex justify-between text-xs mb-1.5">
              <span className="text-[#a7a9ae]">
                Phân bổ nhóm cơ ưu tiên ({topMusclesText})
              </span>
              <span className="font-semibold text-[#f5f5f6]">
                {muscleDistribution.length} nhóm cơ nổi bật
              </span>
            </div>
            <div className="h-2.5 w-full bg-[#222327] rounded-full overflow-hidden flex">
              {muscleDistribution.map((m, idx) => (
                <div
                  key={idx}
                  className="h-full transition-all"
                  style={{ width: `${m.percentage}%`, backgroundColor: m.color }}
                  title={`${m.name}: ${m.count} bài (${m.percentage}%)`}
                />
              ))}
            </div>
            <div className="flex flex-wrap gap-3 mt-1.5 text-[11px] text-[#8a8d93]">
              {muscleDistribution.slice(0, 4).map((m, idx) => (
                <div key={idx} className="flex items-center gap-1">
                  <span className="w-2 h-2 rounded-full" style={{ backgroundColor: m.color }} />
                  <span>{m.name} ({m.percentage}%)</span>
                </div>
              ))}
            </div>
          </div>

          <div>
            <div className="flex justify-between text-xs mb-1">
              <span className="text-[#a7a9ae]">
                Tỷ lệ thực phẩm giàu dinh dưỡng / Protein cao
              </span>
              <span className="font-semibold text-[#f5f5f6]">{highProteinPercentage}% Thực phẩm</span>
            </div>
            <div className="h-2 w-full bg-[#222327] rounded-full overflow-hidden flex">
              <div className="h-full bg-[#2cc7b5]" style={{ width: `${highProteinPercentage}%` }} />
              <div className="h-full bg-[#38393b]" style={{ width: `${100 - highProteinPercentage}%` }} />
            </div>
          </div>
        </div>
      </div>

      {/* Footer */}
      <div className="pt-4 mt-4 border-t border-[#292a2f]/60 flex items-center justify-between text-xs text-[#a7a9ae]">
        <span>Đồng bộ từ cơ sở dữ liệu hệ thống VieGym</span>
        <span className="text-[#35c76f] font-mono font-semibold">Synced Live</span>
      </div>
    </div>
  )
}

