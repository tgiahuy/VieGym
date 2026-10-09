export type AdminRole = 'ADMIN' | 'SUPER_ADMIN'

export interface AdminUser {
  id: number
  email: string
  role: AdminRole
}

export interface AdminCsrfResponse {
  csrfToken: string
}

export interface AdminSessionResponse {
  admin: AdminUser
  expiresIn: number
  csrfToken: string
}

export interface AdminLoginRequest {
  email: string
  password: string
  deviceInfo?: string
}
