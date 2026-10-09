import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'
import { AdminLayout } from '../components/layout/AdminLayout'
import { AuthProvider, useAuth } from '../core/auth'
import { LoginPage } from '../features/auth/pages/LoginPage'
import { ExerciseListPage } from '../features/exercises/pages/ExerciseListPage'
import { EquipmentListPage } from '../features/equipments/pages/EquipmentListPage'
import { WorkoutPlanListPage } from '../features/workout-plans/pages/WorkoutPlanListPage'
import { FoodListPage } from '../features/foods/pages/FoodListPage'
import { UserListPage } from '../features/users/pages/UserListPage'
import { AiRulesPage } from '../features/ai-rules/pages/AiRulesPage'
import { AuditLogsPage } from '../features/audit-logs/pages/AuditLogsPage'
import { BulkImportPage } from '../features/imports/pages/BulkImportPage'
import { SettingsPage } from '../features/settings/pages/SettingsPage'
import { DashboardPage } from '../features/dashboard/pages/DashboardPage'
import './app.css'

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
})

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { isAuthenticated, isLoading } = useAuth()

  if (isLoading) {
    return (
      <div className="min-h-screen bg-[#0f1012] flex items-center justify-center text-[#f5f5f6]">
        <div className="flex flex-col items-center gap-3">
          <svg className="animate-spin h-8 w-8 text-[#ff506d]" fill="none" viewBox="0 0 24 24">
            <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
            <path
              className="opacity-75"
              d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
              fill="currentColor"
            />
          </svg>
          <span className="text-[13px] text-[#8a8d93] font-mono">Đang khởi tạo hệ thống...</span>
        </div>
      </div>
    )
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />
  }

  return <>{children}</>
}

function AppRoutes() {
  const { isAuthenticated, isLoading } = useAuth()

  if (isLoading) {
    return (
      <div className="min-h-screen bg-[#0f1012] flex items-center justify-center text-[#f5f5f6]">
        <div className="flex flex-col items-center gap-3">
          <svg className="animate-spin h-8 w-8 text-[#ff506d]" fill="none" viewBox="0 0 24 24">
            <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
            <path
              className="opacity-75"
              d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
              fill="currentColor"
            />
          </svg>
          <span className="text-[13px] text-[#8a8d93] font-mono">Đang khởi tạo hệ thống...</span>
        </div>
      </div>
    )
  }

  return (
    <Routes>
      <Route
        path="/login"
        element={
          isAuthenticated ? <Navigate to="/dashboard" replace /> : <LoginPage />
        }
      />

      <Route
        path="/"
        element={
          <ProtectedRoute>
            <AdminLayout />
          </ProtectedRoute>
        }
      >
        <Route index element={<Navigate to="/dashboard" replace />} />
        <Route path="dashboard" element={<DashboardPage />} />
        <Route path="exercises" element={<ExerciseListPage />} />
        <Route path="equipments" element={<EquipmentListPage />} />
        <Route path="workout-plans" element={<WorkoutPlanListPage />} />
        <Route path="foods" element={<FoodListPage />} />
        <Route path="imports" element={<BulkImportPage />} />
        <Route path="users" element={<UserListPage />} />
        <Route path="ai-config" element={<AiRulesPage />} />
        <Route path="audit-logs" element={<AuditLogsPage />} />
        <Route path="settings" element={<SettingsPage />} />
      </Route>

      <Route path="*" element={<Navigate to={isAuthenticated ? '/dashboard' : '/login'} replace />} />
    </Routes>
  )
}

export function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <BrowserRouter>
          <AppRoutes />
        </BrowserRouter>
      </AuthProvider>
    </QueryClientProvider>
  )
}
