# Deployment

## Prerequisites

Obtain access to the selected Vercel, Render, Supabase and Firebase projects. Record the exact backend and frontend commit IDs. Read environment-variables.md and backup-and-recovery.md before changing a hosted environment.

## Deployment order

1. Verify database connectivity and create a recoverable backup.
2. Review pending SQL migrations at the chosen backend commit. Apply them explicitly using the backend migration tooling with the target database connection. Its scripts/install-migrate.ps1 and scripts/migrate.ps1 own the pinned migration tool and public.schema_migrations metadata.
3. Configure the Render backend and deploy the chosen commit.
4. Confirm /health and /ready. Readiness checks database connectivity and does not establish that every migration has been applied.
5. Configure and deploy the Vercel frontend from the matching frontend commit.
6. Run scripts/verify-deployment.ps1, then complete the authenticated acceptance checks below.

## Render

Generate a Blueprint from the existing Render service and compare it with render.yaml before adopting the template. Confirm the plan, region, branch, Go version, build/start commands and existing feature flags. A Blueprint names an existing service and can change its settings when applied.

The supplied service builds the backend repository, not this infrastructure repository. It expects Go 1.27.3, matching the inspected backend go.mod, and binds HTTP_ADDR to 0.0.0.0:10000. Verify that Render supports that Go version before adopting the native runtime. Set the service port consistently if changing it.

Supply DATABASE_URL, FIREBASE_PROJECT_ID and CORS_ALLOWED_ORIGINS in Render. Upload the Firebase service account through Render Secret Files as firebase-service-account.json. GOOGLE_APPLICATION_CREDENTIALS points to /etc/secrets/firebase-service-account.json. Keep the file outside Git.

Optional RTDB, R2, invitations and FCM are disabled in the template. Preserve their verified existing settings when managing an existing service. Enable each only after configuring its dependent services. Confirm Firebase email permissions and templates for invitations.

Application automatic deployment is disabled in this template. Review the Blueprint sync diff before applying infrastructure changes. Reviewers must confirm hosting dashboard values and the selected service before adoption.

## Vercel

Use the frontend repository with root directory web, Vite framework, npm ci, npm run build and dist output. Its web/vercel.json owns the single-page route fallback.

Set VITE_API_BASE_URL to the backend origin without /api/v1. Supply the public Firebase API key, auth domain and project ID from the same Firebase project used by the backend. Set values separately for Preview and Production as appropriate. Redeploy after build-time variable changes.

Allow the selected frontend origin in backend CORS_ALLOWED_ORIGINS and Firebase Authentication authorized domains. Add preview origins explicitly when needed.

## Local Compose

1. Copy .env.example to .env and choose a local PostgreSQL password. Percent-encode it in BACKEND_DATABASE_URL and keep both values consistent.
2. Start PostgreSQL with docker compose up -d postgres.
3. In a backend terminal set DATABASE_URL to the local host connection, normally port 15433. Run the backend's migration installation script and scripts/migrate.ps1 -Command up.
4. Run the backend's existing development script with -SkipDatabase, or set BACKEND_SOURCE, FIREBASE_PROJECT_ID and FIREBASE_CREDENTIALS_FILE in the infra .env and run docker compose --profile backend up -d --build.
5. Point the frontend at http://127.0.0.1:18080 and start it using the frontend repository instructions.

The optional backend Docker build copies backend cmd, internal and docs directories. Review any newly added embedded files before changing the backend structure. The Docker Go version must track go.mod. Images require access to their registries and Go dependencies.

Use docker compose down to stop the local stack. Preserve its named database volume. Updating POSTGRES_PASSWORD after a volume was initialized does not change the existing database user's password.

## Authenticated release acceptance

Record the commit IDs and observed results for each check.

- Admin and Warden sign in and see only permitted actions.
- Student sign in, profile and accommodation load correctly.
- A disposable test student's permission and QR gate scan update recorded presence correctly.
- Private profile and complaint images load only for permitted users when R2 is enabled.
- Invitations are delivered and the setup link works when invitations are enabled.
- RTDB live attendance changes reach permitted listeners when enabled.
- Going Home does not set recorded OUT presence until a gate scan.
- Sign out and switch accounts without retaining another student's private data.

## Rollback

Record the previous successful frontend and backend deployments before releasing. Prefer an application rollback when the previous version is compatible with the new database schema. Review migration compatibility explicitly. A destructive migration rollback can discard data, so use an isolated restore rehearsal and a reviewed recovery plan before replacing the active database.
