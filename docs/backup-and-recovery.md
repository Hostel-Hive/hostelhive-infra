# Backup and recovery

## Scope

scripts/backup-database.ps1 creates a PostgreSQL custom-format archive of the application's public schema, including schema_migrations. It excludes database ownership and grants. It does not export Supabase-managed schemas such as auth or storage, Firebase identities or R2 objects. This is an application backup, not a complete Supabase project clone.

Use PostgreSQL client tools matching the database server major version or newer for pg_dump. Use pg_restore compatible with the archive. Use the direct or session-pooler connection, with hosted SSL enabled, and a role permitted to read every application table. Verify row counts after restoration. Required extensions must be available on the recovery server.

## Backup

Set DATABASE_URL securely in the current terminal. The script does not read .env. Prefer a URL with an explicit database and port, and avoid putting credentials in terminal history. A password file supported by libpq can be used with a URL that omits the password.

```powershell
./scripts/backup-database.ps1
# Optionally choose an external destination.
./scripts/backup-database.ps1 -OutputDirectory 'D:/HostelHiveBackups'
```

Each export has a UTC timestamp and unique identifier. An incomplete export is removed. Store archives in access-controlled encrypted storage separate from the running database. The default backups directory is ignored by Git. Set a retention schedule appropriate to the deployment and record successful restoration rehearsals.

## Restore rehearsal

Use an isolated recovery database with an empty public schema. Do not run backend migrations first because the archive already contains the schema. The script checks for relations, types and functions and refuses an occupied public schema.

Set RESTORE_DATABASE_URL to the recovery connection. ConfirmTarget is host:port/database, without credentials. A missing port in the URL is interpreted as 5432.

```powershell
./scripts/restore-database.ps1 -BackupFile './backups/SELECTED.dump' -ConfirmTarget 'localhost:5432/hostelhive_recovery' -WhatIf
./scripts/restore-database.ps1 -BackupFile './backups/SELECTED.dump' -ConfirmTarget 'localhost:5432/hostelhive_recovery'
```

Review the interactive confirmation. Restoration runs in a single transaction and stops on an error. The script does not remove existing database objects.

After restoring, verify schema_migrations, table counts, foreign keys and sample student/allocation/movement records. Start a compatible backend against the recovery database and run public checks and authenticated smoke tests. Record the archive, commit ID, migration version, duration, operator and results.

The scripts pass connection settings through the child process environment. pg_restore uses an empty --dbname value so libpq resolves PGDATABASE, keeping the connection URL out of command-line arguments. Native tool error output is suppressed because it can contain credentials. On failure inspect permissions and connectivity using your normal private database tooling.

## Images and Firebase

Maintain a separate private R2 recovery procedure for profile photos and complaint evidence. Preserve object keys corresponding to the PostgreSQL image metadata and verify restored objects with authenticated API retrieval. Document object versioning or export policy and retention.

Preserve Firebase project settings, authorized domains, RTDB rules and a documented identity recovery strategy. Backend firebase/database.rules.json owns the RTDB access rules. RTDB projection recovery must be coordinated with the backend's supported projection logic.

## Suggested operating schedule

Take an application backup before migrations and at an agreed recurring interval. Rehearse restoration before release and after a significant schema or storage change. Verify the actual Supabase plan's retention and backup capabilities rather than assuming managed backups cover the recovery requirement.

References
- https://supabase.com/docs/guides/platform/backups
- https://www.postgresql.org/docs/current/app-pgdump.html
- https://www.postgresql.org/docs/current/app-pgrestore.html
- https://www.postgresql.org/docs/current/libpq-envars.html
