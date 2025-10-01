#!/bin/bash

# Odoo 19 Enterprise Restore Script
# Usage: ./restore.sh [backup_file] [restore_type]
# Example: ./restore.sh backups/odoo19-ent_db_20241001_120000.sql db

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${CYAN}[SUCCESS]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${PURPLE}  Odoo 19 Enterprise Restore Tool${NC}"
    echo -e "${PURPLE}========================================${NC}"
}

# Validate parameters
if [ $# -lt 1 ]; then
    print_error "Usage: $0 <backup_file> [restore_type]"
    print_error "Example: $0 backups/odoo19-ent_db_20241001_120000.sql db"
    print_error "Restore types: db, filestore, config"
    exit 1
fi

BACKUP_FILE=$1
RESTORE_TYPE=${2:-"auto"}

print_header
print_status "Restoring from backup file: $BACKUP_FILE"

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    print_error "Backup file not found: $BACKUP_FILE"
    exit 1
fi

# Auto-detect restore type if not specified
if [ "$RESTORE_TYPE" = "auto" ]; then
    if [[ "$BACKUP_FILE" == *"_db_"* ]]; then
        RESTORE_TYPE="db"
    elif [[ "$BACKUP_FILE" == *"_filestore_"* ]]; then
        RESTORE_TYPE="filestore"
    elif [[ "$BACKUP_FILE" == *"_config_"* ]]; then
        RESTORE_TYPE="config"
    else
        print_error "Cannot auto-detect restore type from filename"
        print_error "Please specify restore type: db, filestore, or config"
        exit 1
    fi
fi

print_status "Restore type: $RESTORE_TYPE"

# Check if Docker Compose is running
if ! docker compose ps | grep -q "Up"; then
    print_error "Docker Compose services are not running!"
    print_error "Start services with: docker compose up -d"
    exit 1
fi

# Confirmation prompt
print_warning "This will overwrite existing data!"
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "Restore cancelled."
    exit 0
fi

case $RESTORE_TYPE in
    "db")
        print_status "Restoring database..."
        print_warning "Stopping Odoo service temporarily..."
        docker compose stop odoo19
        
        print_status "Restoring PostgreSQL database..."
        docker compose exec -T db psql -U odoo -d postgres -c "DROP DATABASE IF EXISTS postgres;"
        docker compose exec -T db psql -U odoo -d postgres -c "CREATE DATABASE postgres;"
        docker compose exec -T db psql -U odoo -d postgres < "$BACKUP_FILE"
        
        print_status "Restarting Odoo service..."
        docker compose start odoo19
        print_success "Database restore completed!"
        ;;
        
    "filestore")
        print_status "Restoring filestore..."
        print_warning "Stopping Odoo service temporarily..."
        docker compose stop odoo19
        
        print_status "Extracting filestore backup..."
        rm -rf ./filestore/*
        tar -xzf "$BACKUP_FILE" -C ./filestore/
        
        print_status "Restarting Odoo service..."
        docker compose start odoo19
        print_success "Filestore restore completed!"
        ;;
        
    "config")
        print_status "Restoring configuration..."
        print_warning "This will overwrite configuration files!"
        
        print_status "Extracting configuration backup..."
        tar -xzf "$BACKUP_FILE"
        
        print_status "Restarting services..."
        docker compose restart
        print_success "Configuration restore completed!"
        ;;
        
    *)
        print_error "Invalid restore type: $RESTORE_TYPE"
        print_error "Valid types: db, filestore, config"
        exit 1
        ;;
esac

print_success "Restore completed successfully!"
print_status "Services status:"
docker compose ps
