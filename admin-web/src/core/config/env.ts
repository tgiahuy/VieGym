const defaultApiBaseUrl = '/api/v1'

function normalizeBaseUrl(value: string): string {
  return value.trim().replace(/\/$/, '')
}

export const env = Object.freeze({
  apiBaseUrl: normalizeBaseUrl(import.meta.env.VITE_API_BASE_URL ?? defaultApiBaseUrl),
})
