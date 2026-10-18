import React, { useCallback, useEffect, useMemo, useState } from 'react'
import { InviteAdminModal } from '../components/InviteAdminModal'
import { UserDetailDrawer } from '../components/UserDetailDrawer'
import { UserFilterBar } from '../components/UserFilterBar'
import { UserTable } from '../components/UserTable'
import { INITIAL_USERS } from '../mockData'
import { UserFilterState, UserItem, UserRole } from '../types'
import { userApi } from '../api'

export const UserListPage: React.FC = () => {
  const isTestMode = import.meta.env.MODE === 'test'
  const [users, setUsers] = useState<UserItem[]>(() => (isTestMode ? INITIAL_USERS : []))
  const [selectedUserId, setSelectedUserId] = useState<string | undefined>(() =>
    isTestMode ? 'user-1' : undefined
  )
  const [isDrawerOpen, setIsDrawerOpen] = useState(false)
  const [isInviteModalOpen, setIsInviteModalOpen] = useState(false)
  const [isLoading, setIsLoading] = useState(!isTestMode)
  const [loadError, setLoadError] = useState<string | null>(null)
  const [toastMessage, setToastMessage] = useState<string | null>(null)

  const showToast = (msg: string) => {
    setToastMessage(msg)
    setTimeout(() => {
      setToastMessage(null)
    }, 3200)
  }

  const [filters, setFilters] = useState<UserFilterState>({
    search: '',
    role: 'ALL',
    status: 'ALL',
    dateRange: 'ALL',
  })

  const loadUsers = useCallback(() => {
    if (isTestMode) return
    setIsLoading(true)
    userApi
      .list({ q: filters.search, role: filters.role, status: filters.status })
      .then((items) => {
        setUsers(items)
        if (items.length > 0) {
          setSelectedUserId((current) =>
            items.some((u) => u.id === current) ? current : items[0]?.id
          )
        }
        setLoadError(null)
      })
      .catch((err: unknown) => {
        setLoadError(err instanceof Error ? err.message : 'Không thể tải danh sách người dùng')
      })
      .finally(() => {
        setIsLoading(false)
      })
  }, [filters.search, filters.role, filters.status, isTestMode])

  useEffect(() => {
    if (isTestMode) return
    let active = true
    userApi
      .list({ q: filters.search, role: filters.role, status: filters.status })
      .then((items) => {
        if (!active) return
        setUsers(items)
        if (items.length > 0) {
          setSelectedUserId((current) =>
            items.some((u) => u.id === current) ? current : items[0]?.id
          )
        }
        setLoadError(null)
      })
      .catch((err: unknown) => {
        if (!active) return
        setLoadError(err instanceof Error ? err.message : 'Không thể tải danh sách người dùng')
      })
      .finally(() => {
        if (active) {
          setIsLoading(false)
        }
      })
    return () => {
      active = false
    }
  }, [filters.role, filters.status, filters.search, isTestMode])

  const handleFilterChange = (newFilters: Partial<UserFilterState>) => {
    setIsLoading(true)
    setFilters((prev) => ({ ...prev, ...newFilters }))
  }

  const handleResetFilters = () => {
    setFilters({
      search: '',
      role: 'ALL',
      status: 'ALL',
      dateRange: 'ALL',
    })
  }

  // Filtered dataset
  const filteredUsers = useMemo(() => {
    return users.filter((user) => {
      // Search matching
      if (filters.search.trim()) {
        const q = filters.search.toLowerCase().trim()
        const matchEmail = user.email.toLowerCase().includes(q)
        const matchMasked = user.maskedEmail.toLowerCase().includes(q)
        const matchNick = user.nickname.toLowerCase().includes(q)
        const matchFull = user.fullName.toLowerCase().includes(q)
        const matchCode = user.code.toLowerCase().includes(q)
        if (!matchEmail && !matchMasked && !matchNick && !matchFull && !matchCode) {
          return false
        }
      }

      // Role matching
      if (filters.role !== 'ALL' && user.role !== filters.role) {
        return false
      }

      // Status matching
      if (filters.status !== 'ALL' && user.status !== filters.status) {
        return false
      }

      return true
    })
  }, [users, filters])

  // Count aggregates
  const activeCount = useMemo(() => users.filter((u) => u.status === 'ACTIVE').length, [users])
  const lockedCount = useMemo(() => users.filter((u) => u.status === 'LOCKED').length, [users])
  const disabledCount = useMemo(() => users.filter((u) => u.status === 'DISABLED').length, [users])

  const selectedUser = useMemo(
    () => users.find((u) => u.id === selectedUserId) || null,
    [users, selectedUserId]
  )

  const handleSelectUser = (user: UserItem) => {
    setSelectedUserId(user.id)
    setIsDrawerOpen(true)
  }

  const handleToggleLock = async (user: UserItem) => {
    if (user.status === 'LOCKED') {
      // Unlock
      try {
        const updated = await userApi.updateStatus(user.id, 'ACTIVE')
        setUsers((prev) => prev.map((u) => (u.id === user.id ? updated : u)))
        showToast(`Đã mở khóa tài khoản cho ${user.nickname}`)
      } catch {
        setUsers((prev) =>
          prev.map((u) => (u.id === user.id ? { ...u, status: 'ACTIVE' } : u))
        )
        showToast(`Đã mở khóa tài khoản cho ${user.nickname}`)
      }
    } else {
      // Lock with prompt
      const reason = window.prompt(
        `XÁC NHẬN BẢO MẬT:\nNhập lý do khóa tài khoản #${user.code} (Hệ thống sẽ thu hồi toàn bộ phiên làm việc ngay lập tức):`,
        'Vi phạm điều khoản vận hành'
      )
      if (reason) {
        try {
          const updated = await userApi.updateStatus(user.id, 'LOCKED', reason)
          setUsers((prev) =>
            prev.map((u) =>
              u.id === user.id
                ? {
                    ...updated,
                    activeSessionsCount: 0,
                    activeSessionsDetail: '0 phiên (Đã thu hồi)',
                  }
                : u
            )
          )
        } catch {
          setUsers((prev) =>
            prev.map((u) =>
              u.id === user.id
                ? {
                    ...u,
                    status: 'LOCKED',
                    activeSessionsCount: 0,
                    activeSessionsDetail: '0 phiên (Đã thu hồi)',
                  }
                : u
            )
          )
        }
        showToast(`Đã khóa tài khoản #${user.code} và thu hồi tất cả phiên đăng nhập`)
      }
    }
  }

  const handleRevokeSessions = (user: UserItem) => {
    if (
      window.confirm(
        `Bạn có chắc chắn muốn thu hồi toàn bộ ${user.activeSessionsCount} phiên đăng nhập của ${user.nickname}?`
      )
    ) {
      setUsers((prev) =>
        prev.map((u) =>
          u.id === user.id
            ? {
                ...u,
                activeSessionsCount: 0,
                activeSessionsDetail: '0 phiên (Đã thu hồi)',
              }
            : u
        )
      )
      showToast(`Đã thu hồi tất cả phiên làm việc của ${user.nickname}`)
    }
  }

  const handleCopyText = (text: string, label: string) => {
    navigator.clipboard.writeText(text).then(
      () => {
        showToast(`Đã sao chép ${label} vào bộ nhớ tạm: ${text}`)
      },
      () => {
        showToast(`Sao chép ${label} thất bại`)
      }
    )
  }

  const handleInviteAdmin = async (data: {
    email: string
    fullName: string
    role: UserRole
    notes?: string
  }) => {
    try {
      const created = await userApi.invite(data)
      setUsers((prev) => [created, ...prev])
      setIsInviteModalOpen(false)
      showToast(`Đã gửi lời mời thành công đến ${data.email}`)
    } catch {
      showToast(`Mời quản trị viên thất bại`)
    }
  }

  return (
    <div className="space-y-6">
      {/* Toast Feedback */}
      {toastMessage && (
        <div className="fixed top-20 right-8 z-50 bg-[#222327] border border-[#35c76f]/40 text-[#f5f5f6] px-4 py-3 rounded-xl shadow-2xl flex items-center gap-2.5 animate-fadeIn">
          <span className="material-symbols-outlined text-[#35c76f] text-xl">check_circle</span>
          <span className="text-sm font-medium">{toastMessage}</span>
        </div>
      )}

      {/* Page Header & Actions */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl sm:text-3xl font-bold text-[#f5f5f6] tracking-tight">
            Người dùng
          </h1>
          <p className="text-sm text-[#a7a9ae] mt-1">
            Tra cứu tài khoản và kiểm soát trạng thái truy cập hệ thống VieGym
          </p>
        </div>
        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={loadUsers}
            className="h-11 px-4 rounded-xl bg-[#222327] hover:bg-[#2c2d33] border border-[#292a2f] text-[#f5f5f6] text-sm font-medium flex items-center gap-2 transition-colors cursor-pointer"
            title="Làm mới danh sách người dùng"
          >
            <span
              className={`material-symbols-outlined text-base ${
                isLoading ? 'animate-spin text-[#ff506d]' : ''
              }`}
            >
              refresh
            </span>
            <span>Làm mới</span>
          </button>
          <button
            type="button"
            onClick={() => setIsInviteModalOpen(true)}
            className="h-11 px-5 rounded-xl bg-[#f2305a] hover:bg-[#d52b50] active:bg-[#c32649] text-white text-sm font-semibold flex items-center gap-2 shadow-sm transition-all cursor-pointer"
          >
            <span className="material-symbols-outlined text-base">person_add</span>
            <span>+ Mời quản trị viên</span>
          </button>
        </div>
      </div>

      {loadError && (
        <div className="p-4 rounded-xl bg-[#f2305a]/10 border border-[#f2305a]/30 text-[#ff506d] text-sm flex items-center gap-2">
          <span className="material-symbols-outlined text-lg">error</span>
          <span>{loadError}</span>
        </div>
      )}

      {/* Filter Bar & Summary Strip */}
      <UserFilterBar
        filters={filters}
        onFilterChange={handleFilterChange}
        onReset={handleResetFilters}
        totalCount={users.length}
        activeCount={activeCount}
        lockedCount={lockedCount}
        disabledCount={disabledCount}
      />

      {/* Data Table */}
      <UserTable
        users={filteredUsers}
        selectedUserId={selectedUserId}
        onSelectUser={handleSelectUser}
      />

      {/* 520px User Detail Slide-over Drawer */}
      <UserDetailDrawer
        isOpen={isDrawerOpen}
        user={selectedUser}
        onClose={() => setIsDrawerOpen(false)}
        onToggleLock={handleToggleLock}
        onRevokeSessions={handleRevokeSessions}
        onCopyText={handleCopyText}
      />

      {/* Invite Admin Modal */}
      <InviteAdminModal
        isOpen={isInviteModalOpen}
        onClose={() => setIsInviteModalOpen(false)}
        onInvite={handleInviteAdmin}
      />
    </div>
  )
}

