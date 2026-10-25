# HostelHive infrastructure

Deployment configuration and operational procedures for the HostelHive open source hostel management system.

The documented assessment environment uses Vercel for the web portal, Render for the Go backend, Supabase PostgreSQL, Firebase Authentication and RTDB, and optional Cloudflare R2 private image storage. Deployment settings in this repository are templates pending comparison with the hosting dashboards.

## Start here

- [Architecture and repository ownership](docs/architecture.md)
- [Deployment and local setup](docs/deployment.md)
- [Environment variable reference](docs/environment-variables.md)
- [Backup and recovery](docs/backup-and-recovery.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Application CI reference files](docs/ci/README.md)

## Local PostgreSQL

Requires Docker Desktop with Linux containers and Docker Compose 2.23.1 or newer.

```powershell
Copy-Item .env.example .env
# Edit the local password and settings in .env.
docker compose config --quiet
docker compose up -d postgres
docker compose ps
```

The local database listens on 127.0.0.1:15433 by default. An existing container using that port must be stopped or POSTGRES_PORT changed. The Compose database has a new, separate volume. Follow the deployment guide to apply backend migrations and optionally run the backend container.

## Verify the hosted application

```powershell
./scripts/verify-deployment.ps1
```

This checks public health, database readiness, login page delivery and the frontend CORS origin. Authenticated acceptance checks are listed in the deployment guide.

## Back up the application database

Install PostgreSQL client tools matching the server major version or newer. Set DATABASE_URL securely in the current terminal, using the direct or session-pooler connection.

```powershell
./scripts/backup-database.ps1
```

The archive covers the application's public schema. Follow the recovery guide for restoring into an isolated empty database, private images and Firebase configuration.

## Infrastructure checks

CI parses PowerShell and YAML, checks the Compose model and scans Git history for secrets. Application tests remain in the backend, web and mobile repositories. CI does not deploy or access hosting credentials.

## Configuration ownership

Backend migrations and Firebase rules remain in [hostelhive-backend](https://github.com/Hostel-Hive/hostelhive-backend). Vercel configuration remains in [hostelhive-frontend](https://github.com/Hostel-Hive/hostelhive-frontend). Review the existing Render service before importing render.yaml. The supplied template uses the free plan, manual application deployment and disabled optional features.
