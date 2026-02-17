# Project P1L0T Server API

## Run locally

```bash
cd services/server-api
npm install
npm start
```

Server default URL: `http://127.0.0.1:4280`

## Endpoints

- `GET /api/health`
- `GET /api/public/config`
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

Admin auth header:

`x-admin-token: <token>`

Default token:

`change-me-now`

Change it in `data/server.config.json`.

## Admin UI

`http://127.0.0.1:4280/admin/`

Includes:

- server settings (MOTD, signup/maintenance, max players/tick rate/autosave)
- hardware profile mode (`recommended` or `max`)
- user management with admin toggle and profile metadata
- per-user file management
- server logs
