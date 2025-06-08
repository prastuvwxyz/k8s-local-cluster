# PostgreSQL Database

This directory contains the configuration for PostgreSQL databases managed by the CloudNativePG operator.

## Structure

- `base/`: Contains the base configuration for the PostgreSQL cluster
  - `namespace.yaml`: Creates the database namespace
  - `cluster.yaml`: Defines the PostgreSQL cluster with optimized settings
  - `backup.yaml`: Defines the backup configuration
  - `scheduled-backup.yaml`: Defines daily scheduled backups
  - `kustomization.yaml`: Kustomization file for the base directory

- `local/`: Contains environment-specific overrides for local development
  - `superuser-secret.yaml`: Defines the superuser credentials
  - `user-secret.yaml`: Defines the application user credentials
  - `cluster-patch.yaml`: Patches the PostgreSQL cluster with local-specific settings
  - `servicemonitor.yaml`: Prometheus ServiceMonitor for metrics collection
  - `custom-metrics.yaml`: ConfigMap with custom Prometheus metrics queries
  - `kustomization.yaml`: Kustomization file that references the base and applies patches

## PostgreSQL Configuration

The PostgreSQL cluster is configured with:

- Advanced autovacuum settings
- Optimized memory and CPU settings
- PostgreSQL extensions (pg_stat_statements, pgaudit, auto_explain)
- User permissions and database setup
- Connection settings
- Monitoring enabled via PodMonitor
- Anti-affinity rules for high availability
- Daily automated backups using volume snapshots
- Custom metrics for monitoring database size and table usage

## Local Development Settings

For local development, the cluster is patched with:
- Specific resource requests and limits
- Storage size of 30Gi
- Reduced worker processes for local environments
- Monitoring enabled with custom metrics collection

## Usage

The database is deployed using Kustomize:

```bash
kubectl kustomize apps/database/local | kubectl apply -f -
```

Or using the Makefile:

```bash
make deploy-postgres
```

## Connecting to PostgreSQL

### Using the provided scripts

```bash
# Connect as superuser to postgres database
make pg-connect

# Connect as application user to app database
make pg-connect-app

# Connect as a specific user to a specific database
make pg-connect USER=app_user DB=app_db

# Create a port-forward in the foreground
make pg-port-forward PORT=5432

# Create a port-forward in the background
make pg-port-forward-bg PORT=5432
```

### Using psql from inside a pod

```bash
# Connect as superuser
kubectl -n database exec -it postgres-cluster-1 -- psql -U postgres

# Connect as application user
kubectl -n database exec -it postgres-cluster-1 -- psql -U app_user -d app
```

### Using port forwarding

```bash
# Forward the PostgreSQL port to your local machine
kubectl port-forward -n database svc/postgres-cluster-rw 5432:5432

# In a new terminal, connect using psql
PGPASSWORD=postgrespassword psql -h localhost -p 5432 -U postgres
```

### Connection parameters

```
Host: localhost (when using port-forward) or postgres-cluster-rw.database (from within the cluster)
Port: 5432
Username: postgres (superuser) or app_user (application user)
Password: postgrespassword (superuser) or app_password (application user)
Database: postgres, app_db, or app
```

## Monitoring and Maintenance

### Checking database status

```bash
make cnpg-status
```

### Monitoring disk usage

```bash
make pg-disk-usage
```

### Checking backups

```bash
make pg-backups
```

### Restoring from backup

```bash
# List available backups
make pg-backups

# Restore from a specific backup
make pg-restore BACKUP=postgres-backup
```

### Viewing PostgreSQL logs

```bash
# View logs in follow mode (last 100 lines + new entries)
make pg-logs

# View specific number of lines in follow mode
make pg-logs LINES=200

# View logs without follow (just display and exit)
make pg-logs-tail LINES=500
```

### Importing and Exporting Data

```bash
# Export a database to a file (defaults to app database)
make pg-export

# Export a specific database to a named file
make pg-export DB=app_db FILE=my_backup.sql

# Import data from a file (defaults to app database)
make pg-import FILE=my_backup.sql

# Import data to a specific database
make pg-import DB=app_db FILE=my_backup.sql
```

## Troubleshooting

### Common issues

1. **Pod not starting**: Check events and logs
   ```bash
   kubectl get events -n database
   kubectl logs -n database postgres-cluster-1
   ```

2. **Connection issues**: Verify secrets and services
   ```bash
   kubectl get secrets -n database
   kubectl get svc -n database
   ```

3. **Performance problems**: Check PostgreSQL logs
   ```bash
   kubectl exec -it -n database postgres-cluster-1 -- tail -f /controller/log/postgres/postgresql.log
   ```

4. **Backup failures**: Check backup resources and events
   ```bash
   kubectl describe backup -n database postgres-backup
   kubectl describe scheduledbackups -n database postgres-scheduled-backup
   ```

```bash
# Connect to PostgreSQL as superuser
kubectl -n database exec -it postgres-cluster-1 -- psql -U postgres

# Connect to PostgreSQL as application user
kubectl -n database exec -it postgres-cluster-1 -- psql -U app_user -d app_db

# Get the connection string
kubectl get secrets -n database postgres-cluster-app -o jsonpath='{.data.uri}' | base64 -d
```
