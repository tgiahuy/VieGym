import { createContext } from 'react'
import type { AdminLoginRequest, AdminUser } from './types'

export interface AuthContextType {
  user: AdminUser | null
  isAuthenticated: boolean
  isLoading: boolean
  error: string | null
  login: (credentials: AdminLoginRequest) => Promise<AdminUser>
  logout: () => Promise<void>
  checkSession: () => Promise<void>
}

export const AuthContext = createContext<AuthContextType | undefined>(undefined)
