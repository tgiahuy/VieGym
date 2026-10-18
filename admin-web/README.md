# VieGym Web Admin

React + TypeScript + Vite application for the ADMIN-only VieGym web channel.

## Runtime

- Node.js `24.18.1` (`.nvmrc`)
- npm `11.16.0`
- Exact direct dependency versions and committed `package-lock.json`

## Setup

```bash
cp .env.example .env.local
nvm use
npm ci
npm run dev
```

Only browser-safe configuration may use the `VITE_` prefix. Never place secrets, passwords, signing keys, or server credentials in this application.

For local UI development, `VITE_AUTH_DISABLED=true` skips the Admin Web login screen. This only bypasses the frontend route/session check; backend Admin APIs remain protected. Keep it `false` in every deployed environment.

## Verification

```bash
npm run verify
```

This runs lint, component tests, TypeScript compilation, and the production build.
