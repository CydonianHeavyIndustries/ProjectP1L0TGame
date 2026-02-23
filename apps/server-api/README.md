# Project P1L0T Server API

## Run locally

```bash
cd apps/server-api
npm install
npm start
```

Server default URL: `http://127.0.0.1:4280`

## Endpoints

- `GET /api/health`
- `GET /api/public/config`
- `GET /api/public/auth-config`
- `POST /api/auth/signup`
- `POST /api/auth/resend-verification`
- `GET /api/auth/verify-email?token=...`
- `POST /api/auth/login`
- `GET /api/auth/me` (Bearer token)
- `POST /api/auth/logout` (Bearer token)
- `GET /api/admin/settings`
- `PUT /api/admin/settings`
- `GET /api/admin/users`
- `GET /api/admin/users/:userId`
- `POST /api/admin/users`
- `PATCH /api/admin/users/:userId`
- `GET /api/admin/users/:userId/files`
- `POST /api/admin/users/:userId/files`
- `DELETE /api/admin/users/:userId/files/:fileName`
- `GET /api/admin/logs`
- `POST /api/admin/update`
- `GET /api/admin/update/status`

Admin auth header:

`x-admin-token: <token>`

Default token:

`change-me-now`

Change it in `data/server.config.json`.

## Auth + Email verification

User passwords are stored as salted scrypt hashes.

Verification flow:

1. `POST /api/auth/signup` creates user with `emailVerified=false`.
2. Server issues verification token and sends email.
3. `GET /api/auth/verify-email?token=...` marks user verified.
4. `POST /api/auth/login` returns session token.

SMTP configuration is read from `data/server.config.json` (or env):

- `smtpHost`
- `smtpPort`
- `smtpSecure`
- `smtpUser`
- `smtpPass`
- `smtpFrom`
- `publicBaseUrl`

If SMTP is not configured, verification links are written to:

`apps/server-api/data/email_outbox.log`

## Admin UI

`http://127.0.0.1:4280/admin/`

Includes:

- server settings (MOTD, signup/maintenance, max players/tick rate/autosave)
- hardware profile mode (`recommended` or `max`)
- user management with admin toggle and profile metadata
- per-user file management
- server logs
