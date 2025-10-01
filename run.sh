#!/bin/bash

# Enhanced Odoo 19 Enterprise Docker Compose Setup with pgbouncer
# Usage: ./run.sh <instance_name> <main_port> <longpolling_port> [redis_port] [pgbouncer_port]
# Example: ./run.sh odoo19-ent 10019 20019 6389 6439

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
    echo -e "${PURPLE}  Enhanced Odoo 19 Enterprise Setup${NC}"
    echo -e "${PURPLE}========================================${NC}"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Validate parameters
if [ $# -lt 3 ]; then
    print_error "Usage: $0 <instance_name> <main_port> <longpolling_port> [redis_port] [pgbouncer_port]"
    print_error "Example: $0 odoo19-ent 10019 20019 6389 6439"
    exit 1
fi

INSTANCE_NAME=$1
MAIN_PORT=$2
LONGPOLLING_PORT=$3
REDIS_PORT=${4:-6379}
PGBOUNCER_PORT=${5:-6432}

print_header
print_status "Setting up Odoo 19 Enterprise instance: $INSTANCE_NAME"
print_status "Main port: $MAIN_PORT"
print_status "Longpolling port: $LONGPOLLING_PORT"
print_status "Redis port: $REDIS_PORT"
print_status "pgbouncer port: $PGBOUNCER_PORT"

# Check if ports are available
check_port() {
    local port=$1
    if netstat -tuln | grep -q ":$port "; then
        print_error "Port $port is already in use!"
        exit 1
    fi
}

print_status "Checking port availability..."
check_port $MAIN_PORT
check_port $LONGPOLLING_PORT
check_port $REDIS_PORT
check_port $PGBOUNCER_PORT

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create instance directory
print_status "Creating instance directory..."
mkdir -p "$INSTANCE_NAME"
cd "$INSTANCE_NAME"

# Clone repository if not already present
if [ ! -f "docker-compose.yml" ]; then
    print_status "Downloading Odoo 19 Enterprise setup..."
    git clone --depth=1 https://github.com/Husen2012/odoo19-enterprise-repo.git temp_repo
    cp -r temp_repo/* .
    rm -rf temp_repo
fi

# Remove git history if present
rm -rf .git

print_status "Configuring ports..."

# Update docker-compose.yml with custom ports
sed -i "s/10019:8069/$MAIN_PORT:8069/g" docker-compose.yml
sed -i "s/20019:8072/$LONGPOLLING_PORT:8072/g" docker-compose.yml
sed -i "s/6389:6379/$REDIS_PORT:6379/g" docker-compose.yml
sed -i "s/6439:6432/$PGBOUNCER_PORT:6432/g" docker-compose.yml

print_status "Setting up system configurations..."

# Set system configurations for better performance
echo "fs.inotify.max_user_watches = 524288" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "kernel.panic = 10" >> /etc/sysctl.conf
echo "vm.swappiness = 10" >> /etc/sysctl.conf
echo "vm.vfs_cache_pressure = 50" >> /etc/sysctl.conf
sysctl -p

print_status "Creating necessary directories..."
mkdir -p addons enterprise postgresql pgbouncer sessions filestore redis-data
chmod 777 sessions filestore

# Create pgbouncer userlist
print_status "Configuring pgbouncer authentication..."
echo '"odoo" "odoo19@2025"' > pgbouncer/userlist.txt

# Download Odoo Enterprise addons if not present
if [ ! -d "enterprise/web_enterprise" ]; then
    print_status "Setting up Odoo 19 Enterprise addons..."
    print_warning "Enterprise addons will be downloaded automatically on first container start"
    print_warning "Make sure you have a valid Odoo Enterprise subscription"
fi

print_status "Starting Docker containers..."
docker compose up -d

# Wait for services to be ready
print_status "Waiting for services to start..."
sleep 15

# Check PostgreSQL
print_status "Checking PostgreSQL connection..."
for i in {1..30}; do
    if docker compose exec -T db pg_isready -U odoo -d postgres > /dev/null 2>&1; then
        print_success "PostgreSQL is ready!"
        break
    fi
    if [ $i -eq 30 ]; then
        print_error "PostgreSQL failed to start properly"
        exit 1
    fi
    sleep 2
done

# Check Redis
print_status "Checking Redis connection..."
for i in {1..15}; do
    if docker compose exec -T redis redis-cli ping > /dev/null 2>&1; then
        print_success "Redis is ready!"
        break
    fi
    if [ $i -eq 15 ]; then
        print_error "Redis failed to start properly"
        exit 1
    fi
    sleep 2
done

# Check pgbouncer
print_status "Checking pgbouncer connection..."
for i in {1..20}; do
    if docker compose exec -T pgbouncer pg_isready -U odoo -d postgres -h localhost -p 6432 > /dev/null 2>&1; then
        print_success "pgbouncer is ready!"
        break
    fi
    if [ $i -eq 20 ]; then
        print_error "pgbouncer failed to start properly"
        exit 1
    fi
    sleep 2
done

# Final service check
print_status "Performing final service check..."
if docker compose ps | grep -q "Up"; then
    print_success "✅ Odoo 19 Enterprise instance '$INSTANCE_NAME' started successfully!"
    echo
    print_success "🌐 Access URLs:"
    print_success "   Main Interface: http://localhost:$MAIN_PORT"
    print_success "   Master Password: Enterprise@2025"
    print_success "   Longpolling: http://localhost:$LONGPOLLING_PORT"
    echo
    print_success "🔧 Service Ports:"
    print_success "   Redis: $REDIS_PORT"
    print_success "   pgbouncer: $PGBOUNCER_PORT"
    echo
    print_success "📁 Instance Directory: $(pwd)"
    print_success "📝 Add your custom addons to: $(pwd)/addons/"
    print_success "🏢 Enterprise addons location: $(pwd)/enterprise/"
    echo
    print_success "🐳 Docker Commands:"
    print_success "   View logs: docker compose logs -f"
    print_success "   Stop: docker compose down"
    print_success "   Restart: docker compose restart"
    print_success "   Status: docker compose ps"
    echo
    print_warning "⚠️  Important Notes:"
    print_warning "   - Change the master password for production use"
    print_warning "   - Ensure you have a valid Odoo Enterprise license"
    print_warning "   - Configure SSL/TLS for production deployment"
    print_warning "   - Set up regular backups for your data"
    echo
    print_success "🎉 Setup completed! Your Odoo 19 Enterprise instance is ready to use."
else
    print_error "❌ Some services failed to start properly"
    print_error "Check the logs with: docker compose logs"
    exit 1
fi
