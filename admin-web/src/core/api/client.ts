import { env } from '../config/env'
import { ApiError, type ApiResponse } from './types'

let csrfTokenCache: string | null = null

export function setCsrfToken(token: string | null): void {
  csrfTokenCache = token
}

export function getCsrfToken(): string | null {
  return csrfTokenCache
}

export interface RequestOptions extends RequestInit {
  csrfRequired?: boolean
  skipRefresh?: boolean
}

export async function apiClient<T>(endpoint: string, options: RequestOptions = {}): Promise<T> {
  const { csrfRequired = false, skipRefresh = false, headers, ...customConfig } = options

  const url = endpoint.startsWith('http') ? endpoint : `${env.apiBaseUrl}${endpoint}`

  const requestHeaders: Record<string, string> = {
    'Content-Type': 'application/json',
    Accept: 'application/json',
    ...(headers as Record<string, string>),
  }

  if (csrfRequired && csrfTokenCache) {
    requestHeaders['X-CSRF-Token'] = csrfTokenCache
  }

  let response = await fetch(url, {
    ...customConfig,
    credentials: 'include',
    headers: requestHeaders,
  })

  if (response.status === 401 && !skipRefresh && !endpoint.includes('/admin/auth/')) {
    const refreshed = await refreshAdminSession()
    if (refreshed) {
      if (csrfRequired && csrfTokenCache) requestHeaders['X-CSRF-Token'] = csrfTokenCache
      response = await fetch(url, { ...customConfig, credentials: 'include', headers: requestHeaders })
    }
  }

  const isJson = response.headers.get('content-type')?.includes('application/json')
  const body = isJson ? await response.json() : null

  if (!response.ok) {
    const errorDetail = body?.error
    const code = errorDetail?.code || `HTTP_${response.status}`
    const message = errorDetail?.message || response.statusText || 'Yêu cầu không thành công'
    throw new ApiError(response.status, code, message, errorDetail?.details)
  }

  const apiResponse = body as ApiResponse<T>
  return apiResponse.data
}

let refreshPromise: Promise<boolean> | null = null

function refreshAdminSession(): Promise<boolean> {
  if (refreshPromise) return refreshPromise
  refreshPromise = (async () => {
    try {
      const response = await fetch(`${env.apiBaseUrl}/admin/auth/refresh`, {
        method: 'POST', credentials: 'include', headers: {
          Accept: 'application/json', 'Content-Type': 'application/json',
          ...(csrfTokenCache ? { 'X-CSRF-TOKEN': csrfTokenCache } : {}),
        },
      })
      if (!response.ok) return false
      const body = await response.json() as ApiResponse<{ csrfToken?: string }>
      if (body.data?.csrfToken) setCsrfToken(body.data.csrfToken)
      return true
    } catch {
      return false
    } finally {
      refreshPromise = null
    }
  })()
  return refreshPromise
}
