import { env } from './env'

describe('environment configuration', () => {
  it('exposes a normalized API base URL', () => {
    expect(env.apiBaseUrl).not.toMatch(/\/$/)
  })

  it('parses the local auth bypass as a boolean', () => {
    expect(typeof env.authDisabled).toBe('boolean')
  })
})
