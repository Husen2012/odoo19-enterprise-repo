#!/bin/bash

# Odoo 19 Enterprise Backup Script
# Usage: ./backup.sh [instance_name] [backup_type]
# Example: ./backup.sh odoo19-ent full

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
    echo -e "${PURPLE}  Odoo 19 Enterprise Backup Tool${NC}"
    echo -e "${PURPLE}========================================${NC}"
}

# Default values
INSTANCE_NAME=${1:-"odoo19-ent"}
BACKUP_TYPE=${2:-"full"}
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

print_header
print_status "Starting backup for instance: $INSTANCE_NAME"
print_status "Backup type: $BACKUP_TYPE"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Check if Docker Compose is running
if ! docker compose ps | grep -q "Up"; then
    print_error "Docker Compose services are not running!"
    print_error "Start services with: docker compose up -d"
    exit 1
fi

case $BACKUP_TYPE in
    "full")
        print_status "Creating full backup (database + filestore + config)..."
        
        # Database backup
        print_status "Backing up PostgreSQL database..."
        docker compose exec -T db pg_dumpall -U odoo > "$BACKUP_DIR/${INSTANCE_NAME}_db_${TIMESTAMP}.sql"
        
        # Filestore backup
        print_status "Backing up filestore..."
        tar -czf "$BACKUP_DIR/${INSTANCE_NAME}_filestore_${TIMESTAMP}.tar.gz" -C ./filestore .
        
        # Configuration backup
        print_status "Backing up configuration..."
        tar -czf "$BACKUP_DIR/${INSTANCE_NAME}_config_${TIMESTAMP}.tar.gz" ./etc ./addons ./enterprise
        
        print_success "Full backup completed!"
        ;;
        
    "db")
        print_status "Creating database backup only..."
        docker compose exec -T db pg_dumpall -U odoo > "$BACKUP_DIR/${INSTANCE_NAME}_db_${TIMESTAMP}.sql"
        print_success "Database backup completed!"
        ;;
        
    "filestore")
        print_status "Creating filestore backup only..."
        tar -czf "$BACKUP_DIR/${INSTANCE_NAME}_filestore_${TIMESTAMP}.tar.gz" -C ./filestore .
        print_success "Filestore backup completed!"
        ;;
        
    *)
        print_error "Invalid backup type: $BACKUP_TYPE"
        print_error "Valid types: full, db, filestore"
        exit 1
        ;;
esac

# Display backup information
print_success "Backup files created in: $BACKUP_DIR"
ls -lh "$BACKUP_DIR"/*${TIMESTAMP}*

print_success "Backup completed successfully!"
print_warning "Store backups in a secure, off-site location"
