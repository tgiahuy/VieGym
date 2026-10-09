export interface ApiErrorDetail {
  code: string
  message: string
  details?: Record<string, unknown>
}

export interface ApiResponse<T> {
  success: boolean
  data: T
  error?: ApiErrorDetail
}

export class ApiError extends Error {
  constructor(
    public readonly status: number,
    public readonly code: string,
    message: string,
    public readonly details?: Record<string, unknown>,
  ) {
    super(message)
    this.name = 'ApiError'
  }
}
