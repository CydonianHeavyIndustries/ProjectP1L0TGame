# Project P1L0T Launcher

CHII-themed Electron launcher for Project P1L0T.

## Quick Start

1. `cd apps/launcher`
2. `npm install`
3. `npm run dev`

## Update Source

Updates pull directly from GitHub releases for:
`CydonianHeavyIndustries/ProjectP1L0TGame`

## Verification Email (No-Reply)

The launcher can send account verification emails via an HTTP mail endpoint.

Set these environment variables before starting Electron:

- `P1LOT_EMAIL_API_URL` (required): endpoint that accepts `POST` JSON `{ to, from, subject, text, html }`
- `P1LOT_EMAIL_API_KEY` (optional): bearer token sent as `Authorization: Bearer ...`
- `P1LOT_EMAIL_FROM` (optional): defaults to `noreply@cydonianheavyindustries.inc`
- `P1LOT_EMAIL_FROM_NAME` (optional): defaults to `Project P1L0T`

If no email API is configured, launcher falls back to dev-mode verification code logging.

