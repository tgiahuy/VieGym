import React from 'react'
import type { WorkoutPlan, WorkoutPlanGoal, WorkoutPlanLevel, WorkoutPlanStatus } from '../types'

interface WorkoutPlanTableProps {
  plans: WorkoutPlan[]
  selectedId: string | null
  onSelect: (plan: WorkoutPlan) => void
  onToggleStatus?: (plan: WorkoutPlan, e: React.MouseEvent) => void
}

export const WorkoutPlanTable: React.FC<WorkoutPlanTableProps> = ({
  plans,
  selectedId,
  onSelect,
  onToggleStatus,
}) => {
  const getGoalBadge = (goal: WorkoutPlanGoal) => {
    switch (goal) {
      case 'hypertrophy':
        return (
          <span className="px-2.5 py-1 rounded-full text-[11px] font-medium bg-[#f2305a]/15 text-[#ff506d] border border-[#f2305a]/30">
            Tăng cơ bắp
          </span>
        )
      case 'strength':
        return (
          <span className="px-2.5 py-1 rounded-full text-[11px] font-medium bg-[#9b7bff]/15 text-[#bfa8ff] border border-[#9b7bff]/30">
            Sức mạnh tối đa
          </span>
        )
      case 'fat_loss':
        return (
          <span className="px-2.5 py-1 rounded-full text-[11px] font-medium bg-[#f97316]/15 text-[#fb923c] border border-[#f97316]/30">
            Giảm mỡ &amp; Cắt nét
          </span>
        )
      case 'general_fitness':
        return (
          <span className="px-2.5 py-1 rounded-full text-[11px] font-medium bg-[#06b6d4]/15 text-[#22d3ee] border border-[#06b6d4]/30">
            Thể lực &amp; Nền tảng
          </span>
        )
      case 'endurance':
        return (
          <span className="px-2.5 py-1 rounded-full text-[11px] font-medium bg-[#10b981]/15 text-[#34d399] border border-[#10b981]/30">
            Sức bền
          </span>
        )
      default:
        return <span>{goal}</span>
    }
  }

  const getLevelBadge = (level: WorkoutPlanLevel) => {
    switch (level) {
      case 'beginner':
        return (
          <span className="px-2 py-0.5 rounded-md text-[11px] font-medium bg-[#1f2022] text-[#35c76f] border border-[#292a2f]">
            Mới bắt đầu
          </span>
        )
      case 'intermediate':
        return (
          <span className="px-2 py-0.5 rounded-md text-[11px] font-medium bg-[#292a2c] text-[#e3e2e4] border border-[#292a2f]">
            Trung bình
          </span>
        )
      case 'advanced':
        return (
          <span className="px-2 py-0.5 rounded-md text-[11px] font-medium bg-[#1f2022] text-[#ff506d] border border-[#292a2f]">
            Nâng cao
          </span>
        )
      default:
        return (
          <span className="px-2 py-0.5 rounded-md text-[11px] font-medium bg-[#1f2022] text-[#a7a9ae] border border-[#292a2f]">
            Tất cả cấp độ
          </span>
        )
    }
  }

  const getStatusBadge = (status: WorkoutPlanStatus) => {
    switch (status) {
      case 'active':
        return (
          <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-medium bg-[#35c76f]/15 text-[#35c76f] border border-[#35c76f]/25">
            <span className="w-1.5 h-1.5 rounded-full bg-[#35c76f]" />
            Hoạt động
          </span>
        )
      case 'draft':
        return (
          <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-medium bg-[#eab308]/15 text-[#facc15] border border-[#facc15]/25">
            <span className="w-1.5 h-1.5 rounded-full bg-[#facc15]" />
            Bản nháp
          </span>
        )
      case 'archived':
        return (
          <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-medium bg-[#292a2c] text-[#8a8d93] border border-[#292a2f]">
            <span className="w-1.5 h-1.5 rounded-full bg-[#8a8d93]" />
            Lưu trữ
          </span>
        )
    }
  }

  if (plans.length === 0) {
    return (
      <div className="bg-[#17181b] border border-[#292a2f] rounded-xl p-12 text-center text-[#8a8d93] space-y-3">
        <span className="material-symbols-outlined text-[40px] text-[#8a8d93]">menu_book</span>
        <p className="text-[14px] font-medium text-[#f5f5f6]">Không tìm thấy giáo án nào phù hợp</p>
        <p className="text-[12px] text-[#8a8d93]">
          Hãy thử thay đổi điều kiện bộ lọc hoặc tạo mới giáo án để bắt đầu quản lý.
        </p>
      </div>
    )
  }

  return (
    <div className="bg-[#17181b] border border-[#292a2f] rounded-xl overflow-hidden shadow-sm">
      <div className="overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="h-11 bg-[#17181b] border-b border-[#292a2f] text-[12px] font-semibold text-[#a7a9ae] uppercase tracking-wider">
              <th className="py-3 px-4 w-12 text-center">#</th>
              <th className="py-3 px-4 min-w-[260px]">Giáo án &amp; Mục tiêu</th>
              <th className="py-3 px-4 min-w-[140px]">Phân bổ lịch</th>
              <th className="py-3 px-4">Cấp độ</th>
              <th className="py-3 px-4 min-w-[220px]">Cấu trúc buổi &amp; Bài tập</th>
              <th className="py-3 px-4">Trạng thái</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-[#292a2f] text-[14px]">
            {plans.map((plan, index) => {
              const isSelected = selectedId === plan.id
              const totalExercises = plan.days.reduce(
                (sum, day) => sum + (day.exercises?.length || 0),
                0
              )

              return (
                <tr
                  key={plan.id}
                  onClick={() => onSelect(plan)}
                  className={`h-20 transition-colors cursor-pointer ${
                    isSelected
                      ? 'bg-[#222327] border-l-[3px] border-l-[#f2305a] hover:bg-[#1c1d21]'
                      : 'hover:bg-[#1c1d21]'
                  }`}
                >
                  {/* Index / Icon */}
                  <td className="py-3 px-4 text-center text-[#8a8d93] text-[12px] font-mono">
                    {index + 1}
                  </td>

                  {/* Plan Info */}
                  <td className="py-3 px-4">
                    <div className="flex flex-col gap-1">
                      <div className="flex items-center gap-2">
                        <span className="font-semibold text-[#f5f5f6] hover:text-[#ff506d] transition-colors line-clamp-1">
                          {plan.title}
                        </span>
                        <span className="px-1.5 py-0.2 rounded text-[10px] font-mono text-[#a7a9ae] bg-[#222327] border border-[#292a2f] shrink-0">
                          {plan.code}
                        </span>
                      </div>
                      <div className="flex items-center gap-2">
                        {getGoalBadge(plan.goal)}
                        <span className="text-[11px] text-[#8a8d93] truncate max-w-[200px]">
                          Tạo bởi: {plan.author}
                        </span>
                      </div>
                    </div>
                  </td>

                  {/* Schedule info */}
                  <td className="py-3 px-4">
                    <div className="flex flex-col gap-0.5">
                      <span className="text-[13px] font-medium text-[#f5f5f6] flex items-center gap-1.5">
                        <span className="material-symbols-outlined text-[16px] text-[#8a8d93]">
                          calendar_today
                        </span>
                        {plan.daysPerWeek} buổi / tuần
                      </span>
                      <span className="text-[11px] text-[#8a8d93]">
                        Lộ trình: {plan.durationWeeks} tuần ({plan.estimatedDurationMin || 60}p/buổi)
                      </span>
                    </div>
                  </td>

                  {/* Level */}
                  <td className="py-3 px-4">{getLevelBadge(plan.level)}</td>

                  {/* Structure & Exercises */}
                  <td className="py-3 px-4">
                    <div className="flex flex-col gap-1.5">
                      <div className="flex items-center gap-2 text-[12px] text-[#f5f5f6]">
                        <span className="font-medium bg-[#222327] px-2 py-0.5 rounded text-[11px] border border-[#292a2f]">
                          {plan.days.length} buổi tập
                        </span>
                        <span className="text-[#a7a9ae]">
                          {totalExercises} bài tập liên kết
                        </span>
                      </div>
                      <div className="flex flex-wrap gap-1 max-w-[280px]">
                        {plan.days.slice(0, 2).map((d) => (
                          <span
                            key={d.id}
                            className="px-1.5 py-0.5 rounded text-[10px] bg-[#1c1d21] text-[#8a8d93] border border-[#292a2f] truncate max-w-[130px]"
                            title={d.name}
                          >
                            {d.name} ({d.exercises?.length || 0})
                          </span>
                        ))}
                        {plan.days.length > 2 && (
                          <span className="px-1.5 py-0.5 rounded text-[10px] bg-[#1c1d21] text-[#8a8d93] border border-[#292a2f]">
                            +{plan.days.length - 2} buổi
                          </span>
                        )}
                      </div>
                    </div>
                  </td>

                  {/* Status */}
                  <td className="py-3 px-4">
                    <button
                      type="button"
                      onClick={(e) => onToggleStatus?.(plan, e)}
                      title="Nhấn để đổi trạng thái"
                      className="cursor-pointer"
                    >
                      {getStatusBadge(plan.status)}
                    </button>
                  </td>
                </tr>
              )
            })}
          </tbody>
        </table>
      </div>
    </div>
  )
}
