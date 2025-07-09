#!/bin/bash

# Database migration script for eth2-beaconchain-explorer
# This script runs all SQL migration files in chronological order

set -e  # Exit on any error

DB_HOST="localhost"
DB_PORT="5432"
DB_USER="postgres"
DB_NAME="db"
DB_PASSWORD="pass"

echo "Starting database migrations..."
echo "Database: $DB_USER@$DB_HOST:$DB_PORT/$DB_NAME"

# Set PGPASSWORD to avoid password prompts
export PGPASSWORD="$DB_PASSWORD"

# Get all migration files in chronological order
MIGRATION_FILES=$(ls -1 db/migrations/*.sql | grep -v new.sh | sort)

# Counter for tracking progress
TOTAL_FILES=$(echo "$MIGRATION_FILES" | wc -l | tr -d ' ')
CURRENT=0

echo "Found $TOTAL_FILES migration files to execute"
echo "----------------------------------------"

# Execute each migration file
for file in $MIGRATION_FILES; do
    CURRENT=$((CURRENT + 1))
    filename=$(basename "$file")
    
    echo "[$CURRENT/$TOTAL_FILES] Executing: $filename"
    
    # Execute the migration file
    if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$file" -q; then
        echo "✓ Success: $filename"
    else
        echo "✗ Failed: $filename"
        echo "Migration failed. Stopping execution."
        exit 1
    fi
    echo ""
done

echo "----------------------------------------"
echo "All migrations completed successfully!"
echo "Database schema is now up to date."

# Show final table count
echo ""
echo "Final database status:"
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "\dt" -q

# Clean up
unset PGPASSWORD
