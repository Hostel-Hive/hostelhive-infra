# Environment variables

Compose reads the ignored .env file automatically. The PowerShell operations scripts read process environment variables only. The Go executable also reads process environment variables. Configure hosted values in the hosting platform.

| Setting | Location | Purpose |
| --- | --- | --- |
| DATABASE_URL | Render; backup terminal; backend migration terminal | PostgreSQL connection URL with SSL for hosted databases |
| RESTORE_DATABASE_URL | Recovery terminal | Separate empty recovery database |
| FIREBASE_PROJECT_ID | Render / local backend | Firebase project shared with clients |
| GOOGLE_APPLICATION_CREDENTIALS | Render / local backend | Backend service account file path |
| HTTP_ADDR | Render / local backend | Explicit listening address and port |
| APP_ENV | Render / local backend | production on hosted service; development locally |
| CORS_ALLOWED_ORIGINS | Render / local backend | Comma-separated exact browser origins |
| HOSTEL_TIMEZONE | Render | Policy timezone |
| HOSTEL_EXIT_OPENING / HOSTEL_ENTRY_DEADLINE | Render | Movement policy times |
| RTDB_ENABLED / FIREBASE_DATABASE_URL | Render | Optional live attendance projection |
| R2_ENABLED | Render | Optional private image storage |
| R2_ACCOUNT_ID / R2_BUCKET | Render | R2 account and private bucket |
| R2_ACCESS_KEY_ID / R2_SECRET_ACCESS_KEY | Render secrets | Private image storage credentials |
| STUDENT_INVITATIONS_ENABLED | Render | Enable the invitation worker and API workflow |
| STUDENT_EMAIL_DOMAINS | Render | Accepted exact student email domains |
| FCM_ENABLED | Render | Optional mobile push delivery |
| VITE_API_BASE_URL | Vercel | Public backend origin without /api/v1 |
| VITE_FIREBASE_API_KEY | Vercel | Public Firebase web application key |
| VITE_FIREBASE_AUTH_DOMAIN | Vercel | Public Firebase auth domain |
| VITE_FIREBASE_PROJECT_ID | Vercel | Public Firebase project ID |
| GO_VERSION | Render | Native backend build toolchain |

The backend .env.example remains authoritative for additional timeout settings. VITE values are included in browser bundles. Database and storage secrets and Firebase service account private keys belong on the backend.

## Local Compose variables

POSTGRES_USER, POSTGRES_DB and POSTGRES_PASSWORD initialize a new database volume. POSTGRES_PORT defaults to 15433. BACKEND_PORT defaults to 18080. BACKEND_SOURCE selects the backend checkout. BACKEND_DATABASE_URL uses the postgres service hostname inside Compose. FIREBASE_CREDENTIALS_FILE names an existing host file mounted read-only into the backend container.

## Credential maintenance

Use separate credentials for each environment. Record the service owner and replacement procedure without recording secret values. After replacing a credential, update the affected service, redeploy or restart it, and verify the dependent feature.
