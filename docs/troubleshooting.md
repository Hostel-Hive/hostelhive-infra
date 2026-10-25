# Troubleshooting

| Symptom | Checks |
| --- | --- |
| Login reports that the service is unreachable | Run verify-deployment.ps1. Confirm the deployed VITE_API_BASE_URL, Render availability and exact CORS origin. |
| /health works but /ready fails | Check the Render DATABASE_URL, hosted SSL, database reachability and credentials. Confirm migration version separately. |
| Backend cannot listen on the hosted port | Set HTTP_ADDR explicitly to 0.0.0.0:10000 or the service's chosen port. This backend does not derive HTTP_ADDR from PORT. |
| Profile or evidence image API returns 503 | Confirm R2_ENABLED and all four R2 settings and verify private object-storage access. |
| Invitation stays pending | Confirm feature enablement, schema migration, worker logs, Firebase email permissions and templates. Check delivery status and attempts before retrying. |
| Live attendance does not update | Check RTDB enablement, URL, deployed rules and backend logs. Compare the authoritative REST state. |
| Local database port is occupied | Inspect existing local containers. Choose a different POSTGRES_PORT and update the backend host connection. |
| Local credentials fail after editing .env | A previously initialized PostgreSQL volume retains its original database user credentials. |
| Restore is rejected | Use a separate empty public schema, verify ConfirmTarget and use compatible PostgreSQL client tools. |
| Blueprint deployment fails | Compare the template with the existing Render service, supported Go runtime, secret file, environment settings and backend repository access. |

## Release evidence

For each release record frontend and backend commit IDs, migration version, hosting deployment IDs, public check results, authenticated acceptance results and a successful recovery rehearsal. Store reports without tokens, passwords or student personal information.

References
- https://render.com/docs/infrastructure-as-code
- https://render.com/docs/blueprint-spec
