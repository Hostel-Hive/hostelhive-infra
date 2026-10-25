# Architecture

The browser loads the React web application from Vercel. Firebase Authentication issues the user's ID token. The web and mobile applications send authenticated requests to the Go API on Render, which applies local account and role checks before accessing Supabase PostgreSQL.

PostgreSQL holds authoritative accounts, profiles, inventory, allocations, movements, permissions, complaints and notification records. Firebase RTDB is an optional projection of attendance for live displays. Cloudflare R2 optionally stores private profile photographs and complaint evidence. Database restoration alone does not restore these objects or Firebase user accounts.

ESP32 gate devices call the backend with their own scanner credentials. Device configuration must point to the selected backend origin. Scanner credentials are managed through the application and kept outside version control.

## Repository responsibilities

| Repository | Source of truth |
| --- | --- |
| hostelhive-backend | Go server, API specification, SQL migrations, Firebase RTDB rules and backend tests |
| hostelhive-frontend | Web source, Vercel routing/build configuration and frontend tests |
| Mobile repository | Flutter source and mobile integration tests |
| hostelhive-infra | Deployment templates, local Compose environment, verification and recovery procedures |

## Environments

Keep local, staging and production database connections and credentials separate. The existing backend name includes dev and the documented shared environment follows develop. Confirm the intended assessment/staging designation before labelling it production. Record deployed frontend and backend commit IDs during each release.

## Current documented endpoints

- Web portal https://web-kohl-delta-90.vercel.app
- Backend https://hostelhive-backend-dev.onrender.com
- API specification /openapi.json
- Liveness /health
- Database readiness /ready

These addresses come from the application repository documentation. Verify them before an operational release.
