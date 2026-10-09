import React, { useState } from 'react'
import { FoodItem } from '../types'

interface FoodTableProps {
  foods: FoodItem[]
  selectedFoodId?: string
  onEdit: (food: FoodItem) => void
  onToggleStatus?: (food: FoodItem) => void
  onDelete?: (id: string) => void
}

export const FoodTable: React.FC<FoodTableProps> = ({
  foods,
  selectedFoodId,
  onEdit,
}) => {
  const [currentPage, setCurrentPage] = useState(1)
  const [pageSize, setPageSize] = useState(20)

  const totalFoods = foods.length
  const totalPages = Math.ceil(totalFoods / pageSize) || 1
  const startIndex = (currentPage - 1) * pageSize
  const paginatedFoods = foods.slice(startIndex, startIndex + pageSize)

  const renderStatusBadge = (status: FoodItem['status']) => {
    switch (status) {
      case 'active':
        return (
          <span className="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full text-xs font-medium bg-[#35c76f]/15 text-[#35c76f] border border-[#35c76f]/20">
            <span className="w-1.5 h-1.5 rounded-full bg-[#35c76f]" /> Active
          </span>
        )
      case 'incomplete':
        return (
          <span className="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full text-xs font-medium bg-[#f4b740]/15 text-[#f4b740] border border-[#f4b740]/25">
            <span className="w-1.5 h-1.5 rounded-full bg-[#f4b740]" /> Bổ sung
          </span>
        )
      case 'hidden':
        return (
          <span className="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full text-xs font-medium bg-[#8a8d93]/15 text-[#8a8d93] border border-[#8a8d93]/25">
            <span className="w-1.5 h-1.5 rounded-full bg-[#8a8d93]" /> Ẩn
          </span>
        )
    }
  }

  return (
    <div className="bg-[#17181b] rounded-2xl border border-[#292a2f] overflow-hidden flex flex-col">
      <div className="overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="h-11 bg-[#222327]/60 border-b border-[#292a2f] text-[12px] font-semibold text-[#a7a9ae] uppercase tracking-wider">
              <th className="py-3 px-4 w-72">Thực phẩm</th>
              <th className="py-3 px-4 w-32">Khẩu phần</th>
              <th className="py-3 px-4 text-right w-28">Năng lượng</th>
              <th className="py-3 px-4 text-right w-24">Protein</th>
              <th className="py-3 px-4 text-right w-24">Carbs</th>
              <th className="py-3 px-4 text-right w-24">Fat</th>
              <th className="py-3 px-4 w-40">Nguồn dữ liệu</th>
              <th className="py-3 px-4 w-32">Trạng thái</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-[#292a2f] text-[14px]">
            {paginatedFoods.length === 0 ? (
              <tr>
                <td colSpan={8} className="py-12 text-center text-[#8a8d93]">
                  <div className="flex flex-col items-center justify-center gap-2">
                    <span className="material-symbols-outlined text-4xl text-[#8a8d93]">
                      restaurant
                    </span>
                    <p className="text-sm">Không tìm thấy thực phẩm nào phù hợp với bộ lọc</p>
                  </div>
                </td>
              </tr>
            ) : (
              paginatedFoods.map((food) => {
                const isSelected = selectedFoodId === food.id
                return (
                  <tr
                    key={food.id}
                    onClick={() => onEdit(food)}
                    className={`h-16 transition-colors group cursor-pointer ${
                      isSelected
                        ? 'bg-[#222327] border-l-[3px] border-l-[#ff506d]'
                        : food.hasWarning
                        ? 'bg-[#f4b740]/5 hover:bg-[#1c1d21]/70'
                        : 'hover:bg-[#1c1d21]/70'
                    }`}
                  >
                    {/* Food Info */}
                    <td className="py-2.5 px-4">
                      <div className="flex items-center gap-3">
                        <img
                          src={food.image}
                          alt={food.nameVi}
                          className="w-11 h-11 rounded-lg object-cover border border-[#292a2f] bg-[#222327] shrink-0"
                          onError={(e) => {
                            // Fallback if image fails to load
                            e.currentTarget.src =
                              'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=100&auto=format&fit=crop&q=80'
                          }}
                        />
                        <div className="flex flex-col min-w-0">
                          <div className="flex items-center gap-1.5">
                            <span
                              className="font-semibold text-[#f5f5f6] truncate group-hover:text-[#ff506d] transition-colors"
                            >
                              {food.nameVi}
                            </span>
                            {food.hasWarning && (
                              <span
                                className="material-symbols-outlined text-[#f4b740] text-[16px] cursor-help"
                                title={food.warningText || 'Cần bổ sung thông tin macro'}
                              >
                                warning
                              </span>
                            )}
                          </div>
                          <span className="text-xs text-[#8a8d93] truncate">{food.nameEn}</span>
                        </div>
                      </div>
                    </td>

                    {/* Serving size */}
                    <td className="py-2.5 px-4 text-[#a7a9ae]">{food.servingUnit}</td>

                    {/* Calories */}
                    <td className="py-2.5 px-4 text-right tabular-nums font-medium text-[#f28c38]">
                      {food.nutrients.calories} kcal
                    </td>

                    {/* Protein */}
                    <td className="py-2.5 px-4 text-right tabular-nums font-semibold text-[#2cc7b5]">
                      {food.nutrients.protein.toFixed(1)} g
                    </td>

                    {/* Carbs */}
                    <td className="py-2.5 px-4 text-right tabular-nums text-[#35c76f]">
                      {food.nutrients.carbs.toFixed(1)} g
                    </td>

                    {/* Fat */}
                    <td className="py-2.5 px-4 text-right tabular-nums text-[#4d8dff]">
                      {food.nutrients.fat.toFixed(1)} g
                    </td>

                    {/* Data Source */}
                    <td className="py-2.5 px-4">
                      <span className="text-xs px-2 py-0.5 rounded bg-[#222327] text-[#a7a9ae] border border-[#292a2f]">
                        {food.sourceLabel}
                      </span>
                    </td>

                    {/* Status */}
                    <td className="py-2.5 px-4">{renderStatusBadge(food.status)}</td>
                  </tr>
                )
              })
            )}
          </tbody>
        </table>
      </div>

      {/* Table Pagination Footer */}
      <div className="h-14 px-6 border-t border-[#292a2f] flex flex-wrap items-center justify-between gap-3 bg-[#17181b]">
        <div className="flex items-center gap-3 text-xs text-[#a7a9ae]">
          <span>
            Hiển thị{' '}
            <strong className="text-[#f5f5f6] tabular-nums">
              {totalFoods > 0 ? startIndex + 1 : 0}–
              {Math.min(startIndex + pageSize, totalFoods)}
            </strong>{' '}
            trong số <strong className="text-[#f5f5f6] tabular-nums">{totalFoods}</strong> thực
            phẩm
          </span>
          <div className="h-3 w-[1px] bg-[#292a2f] hidden sm:block" />
          <div className="flex items-center gap-1.5">
            <span>Số dòng:</span>
            <select
              value={pageSize}
              onChange={(e) => {
                setPageSize(Number(e.target.value))
                setCurrentPage(1)
              }}
              className="h-7 px-2 rounded-lg bg-[#222327] border border-[#292a2f] text-[#f5f5f6] text-xs font-medium focus:outline-none cursor-pointer"
            >
              <option value="20">20 / trang</option>
              <option value="50">50 / trang</option>
              <option value="100">100 / trang</option>
            </select>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <span className="text-xs text-[#a7a9ae] mr-2">
            Trang <strong className="text-[#f5f5f6]">{currentPage}</strong> / {totalPages}
          </span>
          <button
            type="button"
            disabled={currentPage <= 1}
            onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
            className="w-8 h-8 rounded-lg bg-[#222327] border border-[#292a2f] text-[#8a8d93] hover:text-[#f5f5f6] disabled:opacity-40 flex items-center justify-center transition-colors cursor-pointer disabled:cursor-not-allowed"
          >
            <span className="material-symbols-outlined text-[18px]">chevron_left</span>
          </button>
          <button
            type="button"
            disabled={currentPage >= totalPages}
            onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
            className="w-8 h-8 rounded-lg bg-[#222327] border border-[#292a2f] text-[#f5f5f6] hover:bg-[#1c1d21] disabled:opacity-40 flex items-center justify-center transition-colors cursor-pointer disabled:cursor-not-allowed"
          >
            <span className="material-symbols-outlined text-[18px]">chevron_right</span>
          </button>
        </div>
      </div>
    </div>
  )
}
