import { apiClient, setCsrfToken, setUnauthorizedHandler } from './client'

describe('apiClient authentication recovery', () => {
  afterEach(() => {
    vi.unstubAllGlobals()
    setCsrfToken(null)
    setUnauthorizedHandler(null)
  })

  it('notifies the auth provider when refreshing an expired session fails', async () => {
    const onUnauthorized = vi.fn()
    setUnauthorizedHandler(onUnauthorized)
    setCsrfToken('expired-csrf-token')
    vi.stubGlobal(
      'fetch',
      vi
        .fn()
        .mockResolvedValueOnce(
          new Response(
            JSON.stringify({ error: { code: 'UNAUTHENTICATED', message: 'Unauthorized' } }),
            { status: 401, headers: { 'content-type': 'application/json' } }
          )
        )
        .mockResolvedValueOnce(new Response(null, { status: 403 }))
    )

    await expect(apiClient('/admin/exercises?page=0&size=500')).rejects.toThrow('Unauthorized')

    expect(onUnauthorized).toHaveBeenCalledOnce()
  })
})
