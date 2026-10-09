import { apiClient, setCsrfToken } from '../api/client'
import type {
  AdminCsrfResponse,
  AdminLoginRequest,
  AdminSessionResponse,
} from './types'

export const authApi = {
  async fetchCsrf(): Promise<string> {
    const data = await apiClient<AdminCsrfResponse>('/admin/auth/csrf', {
      method: 'GET',
    })
    setCsrfToken(data.csrfToken)
    return data.csrfToken
  },

  async login(credentials: AdminLoginRequest): Promise<AdminSessionResponse> {
    await this.fetchCsrf()
    const data = await apiClient<AdminSessionResponse>('/admin/auth/login', {
      method: 'POST',
      csrfRequired: true,
      body: JSON.stringify(credentials),
    })
    if (data.csrfToken) {
      setCsrfToken(data.csrfToken)
    }
    return data
  },

  async getSession(): Promise<AdminSessionResponse> {
    const data = await apiClient<AdminSessionResponse>('/admin/auth/session', {
      method: 'GET',
    })
    if (data.csrfToken) {
      setCsrfToken(data.csrfToken)
    }
    return data
  },

  async logout(): Promise<void> {
    await apiClient<void>('/admin/auth/logout', {
      method: 'POST',
      csrfRequired: true,
    })
    setCsrfToken(null)
  },
}
