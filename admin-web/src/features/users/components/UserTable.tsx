import React, { useState } from 'react'
import { UserItem, UserRole, UserStatus } from '../types'

interface UserTableProps {
  users: UserItem[]
  selectedUserId?: string
  onSelectUser: (user: UserItem) => void
}

export const UserTable: React.FC<UserTableProps> = ({
  users,
  selectedUserId,
  onSelectUser,
}) => {
  const [currentPage, setCurrentPage] = useState(1)
  const [pageSize, setPageSize] = useState(20)

  const totalUsers = users.length
  const totalPages = Math.ceil(totalUsers / pageSize) || 1
  const startIndex = (currentPage - 1) * pageSize
  const paginatedUsers = users.slice(startIndex, startIndex + pageSize)

  const renderRoleBadge = (role: UserRole) => {
    switch (role) {
      case 'USER':
        return (
          <span className="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-[#1c1d21] text-[#f5f5f6] border border-[#34363b]">
            USER
          </span>
        )
      case 'TRAINER':
        return (
          <span className="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-[#4d8dff]/10 text-[#4d8dff] border border-[#4d8dff]/20">
            TRAINER
          </span>
        )
      case 'ADMIN':
        return (
          <span className="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-[rgba(242,48,90,0.12)] text-[#ff506d] border border-[#ff506d]/30">
            ADMIN
          </span>
        )
    }
  }

  const renderStatusBadge = (status: UserStatus) => {
    switch (status) {
      case 'ACTIVE':
        return (
          <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-[#35c76f]/10 text-[#35c76f] border border-[#35c76f]/20">
            <span className="w-1.5 h-1.5 rounded-full bg-[#35c76f]" />
            Active
          </span>
        )
      case 'LOCKED':
        return (
          <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-[#ff5a5f]/10 text-[#ff5a5f] border border-[#ff5a5f]/20">
            <span className="w-1.5 h-1.5 rounded-full bg-[#ff5a5f]" />
            Locked
          </span>
        )
      case 'DISABLED':
        return (
          <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-[#222327] text-[#8a8d93] border border-[#34363b]">
            <span className="w-1.5 h-1.5 rounded-full bg-[#8a8d93]" />
            Disabled
          </span>
        )
    }
  }

  const renderAvatar = (user: UserItem) => {
    if (user.avatarUrl) {
      return (
        <img
          src={user.avatarUrl}
          alt={user.nickname}
          className="w-7 h-7 rounded-full object-cover border border-[#ff506d]/40 shrink-0"
        />
      )
    }

    let bgClass = 'bg-[#1c1d21] text-[#a7a9ae] border-[#34363b]'
    if (user.role === 'ADMIN') {
      bgClass = 'bg-[#9b7bff]/10 text-[#9b7bff] border-[#9b7bff]/30'
    } else if (user.status === 'LOCKED') {
      bgClass = 'bg-[#ff5a5f]/10 text-[#ff5a5f] border-[#ff5a5f]/30'
    } else if (user.role === 'USER') {
      bgClass = 'bg-[rgba(242,48,90,0.12)] text-[#ff506d] border-[#ff506d]/40'
    }

    return (
      <div
        className={`w-7 h-7 rounded-full border flex items-center justify-center text-[11px] font-bold shrink-0 ${bgClass}`}
      >
        {user.initials}
      </div>
    )
  }

  return (
    <div className="rounded-xl border border-[#292a2f] bg-[#17181b] overflow-hidden shadow-none flex flex-col">
      <div className="overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="h-11 bg-[#17181b] border-b border-[#292a2f] text-[#f5f5f6] text-[12px] font-semibold tracking-wider uppercase">
              <th className="px-5 py-3">EMAIL (MASKED)</th>
              <th className="px-4 py-3">NICKNAME</th>
              <th className="px-4 py-3">VAI TRÒ</th>
              <th className="px-4 py-3">TRẠNG THÁI</th>
              <th className="px-4 py-3">NGÀY ĐĂNG KÝ</th>
              <th className="px-5 py-3">ĐĂNG NHẬP CUỐI</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-[#292a2f] text-[14px]">
            {paginatedUsers.length === 0 ? (
              <tr>
                <td colSpan={6} className="py-12 text-center text-[#8a8d93]">
                  <div className="flex flex-col items-center justify-center gap-2">
                    <span className="material-symbols-outlined text-4xl text-[#8a8d93]">group</span>
                    <p className="text-sm">Không tìm thấy người dùng nào phù hợp với bộ lọc</p>
                  </div>
                </td>
              </tr>
            ) : (
              paginatedUsers.map((user) => {
                const isSelected = selectedUserId === user.id
                return (
                  <tr
                    key={user.id}
                    onClick={() => onSelectUser(user)}
                    className={`h-14 transition-colors cursor-pointer group ${
                      isSelected
                        ? 'bg-[#222327] border-l-4 border-l-[#ff506d]'
                        : user.status === 'LOCKED'
                        ? 'bg-[#ff5a5f]/5 hover:bg-[#1c1d21]'
                        : 'hover:bg-[#1c1d21]'
                    }`}
                  >
                    {/* Email */}
                    <td className="px-5 py-3 font-mono text-[13px] text-[#f5f5f6]">
                      <div className="flex items-center gap-2">
                        <span className="material-symbols-outlined text-base text-[#8a8d93] group-hover:text-[#ff506d] transition-colors">
                          mail
                        </span>
                        <span>{user.maskedEmail}</span>
                      </div>
                    </td>

                    {/* Nickname & Avatar */}
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2">
                        {renderAvatar(user)}
                        <span className="font-semibold text-[#f5f5f6]">{user.nickname}</span>
                      </div>
                    </td>

                    {/* Role */}
                    <td className="px-4 py-3">{renderRoleBadge(user.role)}</td>

                    {/* Status */}
                    <td className="px-4 py-3">{renderStatusBadge(user.status)}</td>

                    {/* Registration Date */}
                    <td className="px-4 py-3 tabular-nums text-[#a7a9ae] text-sm">
                      {user.registeredAt}
                    </td>

                    {/* Last Login */}
                    <td className="px-5 py-3 tabular-nums text-sm">
                      {user.lastLoginAt ? (
                        <span className="text-[#f5f5f6]">{user.lastLoginAt}</span>
                      ) : (
                        <span className="text-[#8a8d93]">— Chưa đăng nhập</span>
                      )}
                    </td>
                  </tr>
                )
              })
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination Controls */}
      <div className="h-14 px-5 bg-[#17181b] border-t border-[#292a2f] flex flex-col sm:flex-row items-center justify-between gap-4">
        <div className="flex items-center gap-3 text-xs text-[#a7a9ae]">
          <span>
            Hiển thị{' '}
            <strong className="text-[#f5f5f6] tabular-nums">
              {totalUsers > 0 ? startIndex + 1 : 0}–{Math.min(startIndex + pageSize, totalUsers)}
            </strong>{' '}
            trong số <strong className="text-[#f5f5f6] tabular-nums">{totalUsers}</strong>
          </span>
          <div className="h-4 w-px bg-[#292a2f]" />
          <div className="flex items-center gap-2">
            <span>Hàng:</span>
            <select
              value={pageSize}
              onChange={(e) => {
                setPageSize(Number(e.target.value))
                setCurrentPage(1)
              }}
              className="h-8 px-2 py-0 bg-[#222327] border border-[#292a2f] rounded-md text-xs text-[#f5f5f6] cursor-pointer focus:outline-none"
            >
              <option value="20">20 / trang</option>
              <option value="50">50 / trang</option>
              <option value="100">100 / trang</option>
            </select>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <button
            type="button"
            disabled={currentPage <= 1}
            onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
            className="w-8 h-8 rounded-lg border border-[#292a2f] bg-[#222327] text-[#8a8d93] hover:text-[#f5f5f6] hover:bg-[#1c1d21] disabled:opacity-40 flex items-center justify-center transition-colors cursor-pointer disabled:cursor-not-allowed"
          >
            <span className="material-symbols-outlined text-sm">chevron_left</span>
          </button>
          <div className="flex items-center gap-1 text-sm font-semibold">
            <span className="px-2.5 py-1 rounded-md bg-[#f2305a] text-[#f5f5f6] text-xs tabular-nums">
              {currentPage}
            </span>
            <span className="text-[#8a8d93] text-xs">/</span>
            <span className="text-[#a7a9ae] text-xs tabular-nums">{totalPages}</span>
          </div>
          <button
            type="button"
            disabled={currentPage >= totalPages}
            onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
            className="w-8 h-8 rounded-lg border border-[#292a2f] bg-[#222327] text-[#a7a9ae] hover:text-[#f5f5f6] hover:bg-[#1c1d21] disabled:opacity-40 flex items-center justify-center transition-colors cursor-pointer disabled:cursor-not-allowed"
          >
            <span className="material-symbols-outlined text-sm">chevron_right</span>
          </button>
        </div>
      </div>
    </div>
  )
}
