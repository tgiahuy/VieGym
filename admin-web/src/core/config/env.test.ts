import { env } from './env'

describe('environment configuration', () => {
  it('exposes a normalized API base URL', () => {
    expect(env.apiBaseUrl).not.toMatch(/\/$/)
  })
})
