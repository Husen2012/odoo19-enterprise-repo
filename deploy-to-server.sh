#!/bin/bash

# Deployment script for Odoo 19 Enterprise to remote server
# Usage: ./deploy-to-server.sh <server_ip> <server_user> <server_password> <instance_name> <main_port> <longpolling_port> [redis_port] [pgbouncer_port]
# Example: ./deploy-to-server.sh 31.220.79.196 root password123 odoo19-ent 10019 20019 6389 6439

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
    echo -e "${PURPLE}================================================${NC}"
    echo -e "${PURPLE}  Odoo 19 Enterprise Remote Deployment${NC}"
    echo -e "${PURPLE}================================================${NC}"
}

# Validate parameters
if [ $# -lt 6 ]; then
    print_error "Usage: $0 <server_ip> <server_user> <server_password> <instance_name> <main_port> <longpolling_port> [redis_port] [pgbouncer_port]"
    print_error "Example: $0 31.220.79.196 root password123 odoo19-ent 10019 20019 6389 6439"
    exit 1
fi

SERVER_IP=$1
SERVER_USER=$2
SERVER_PASS=$3
INSTANCE_NAME=$4
MAIN_PORT=$5
LONGPOLLING_PORT=$6
REDIS_PORT=${7:-6379}
PGBOUNCER_PORT=${8:-6432}

print_header
print_status "Deploying Odoo 19 Enterprise to server: $SERVER_IP"
print_status "Instance name: $INSTANCE_NAME"
print_status "Main port: $MAIN_PORT"
print_status "Longpolling port: $LONGPOLLING_PORT"
print_status "Redis port: $REDIS_PORT"
print_status "pgbouncer port: $PGBOUNCER_PORT"

# Check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
    print_error "sshpass is required but not installed."
    print_error "Install it with: sudo apt-get install sshpass (Ubuntu/Debian) or brew install sshpass (macOS)"
    exit 1
fi

# Test server connection
print_status "Testing server connection..."
if ! sshpass -p "$SERVER_PASS" ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP "echo 'Connection successful'" > /dev/null 2>&1; then
    print_error "Failed to connect to server $SERVER_IP"
    print_error "Please check server IP, username, and password"
    exit 1
fi
print_success "Server connection successful!"

# Check if ports are available on server
print_status "Checking port availability on server..."
check_port_cmd="netstat -tuln 2>/dev/null | grep -E ':($MAIN_PORT|$LONGPOLLING_PORT|$REDIS_PORT|$PGBOUNCER_PORT) ' || true"
used_ports=$(sshpass -p "$SERVER_PASS" ssh $SERVER_USER@$SERVER_IP "$check_port_cmd")

if [ ! -z "$used_ports" ]; then
    print_error "Some ports are already in use on the server:"
    echo "$used_ports"
    print_error "Please choose different ports or stop the services using these ports"
    exit 1
fi
print_success "All ports are available!"

# Install Docker and Docker Compose on server if not present
print_status "Checking Docker installation on server..."
docker_check=$(sshpass -p "$SERVER_PASS" ssh $SERVER_USER@$SERVER_IP "command -v docker && command -v docker-compose || echo 'not_installed'")

if [[ "$docker_check" == *"not_installed"* ]]; then
    print_warning "Docker not found on server. Installing Docker and Docker Compose..."
    
    sshpass -p "$SERVER_PASS" ssh $SERVER_USER@$SERVER_IP << 'EOF'
        # Install Docker
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        
        # Install Docker Compose
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        
        # Start Docker service
        sudo systemctl start docker
        sudo systemctl enable docker
        
        echo "Docker and Docker Compose installed successfully"
EOF
    
    print_success "Docker and Docker Compose installed on server!"
else
    print_success "Docker is already installed on server!"
fi

# Create deployment directory on server
print_status "Creating deployment directory on server..."
sshpass -p "$SERVER_PASS" ssh $SERVER_USER@$SERVER_IP "mkdir -p /opt/$INSTANCE_NAME"

# Copy all files to server
print_status "Copying Odoo 19 Enterprise setup files to server..."
sshpass -p "$SERVER_PASS" scp -r ./* $SERVER_USER@$SERVER_IP:/opt/$INSTANCE_NAME/

# Execute deployment on server
print_status "Executing deployment on server..."
sshpass -p "$SERVER_PASS" ssh $SERVER_USER@$SERVER_IP << EOF
    cd /opt/$INSTANCE_NAME
    
    # Make scripts executable
    chmod +x run.sh
    chmod +x deploy-to-server.sh
    
    # Run the setup
    ./run.sh $INSTANCE_NAME $MAIN_PORT $LONGPOLLING_PORT $REDIS_PORT $PGBOUNCER_PORT
EOF

# Verify deployment
print_status "Verifying deployment..."
sleep 10

# Check if services are running
service_check=$(sshpass -p "$SERVER_PASS" ssh $SERVER_USER@$SERVER_IP "cd /opt/$INSTANCE_NAME && docker compose ps --format 'table {{.Name}}\t{{.Status}}' | grep -v 'NAME'")

if [[ "$service_check" == *"Up"* ]]; then
    print_success "✅ Deployment completed successfully!"
    echo
    print_success "🌐 Access URLs:"
    print_success "   Main Interface: http://$SERVER_IP:$MAIN_PORT"
    print_success "   Master Password: Enterprise@2025"
    print_success "   Longpolling: http://$SERVER_IP:$LONGPOLLING_PORT"
    echo
    print_success "🔧 Service Information:"
    print_success "   Redis: $SERVER_IP:$REDIS_PORT"
    print_success "   pgbouncer: $SERVER_IP:$PGBOUNCER_PORT"
    echo
    print_success "📁 Server Directory: /opt/$INSTANCE_NAME"
    echo
    print_success "🐳 Management Commands (run on server):"
    print_success "   SSH to server: ssh $SERVER_USER@$SERVER_IP"
    print_success "   Navigate to instance: cd /opt/$INSTANCE_NAME"
    print_success "   View logs: docker compose logs -f"
    print_success "   Stop services: docker compose down"
    print_success "   Restart services: docker compose restart"
    print_success "   Check status: docker compose ps"
    echo
    print_warning "⚠️  Important Next Steps:"
    print_warning "   1. Change the master password for production use"
    print_warning "   2. Configure your Odoo Enterprise license"
    print_warning "   3. Set up SSL/TLS certificates for production"
    print_warning "   4. Configure firewall rules if needed"
    print_warning "   5. Set up regular backups"
    print_warning "   6. Configure domain name and reverse proxy"
    echo
    print_success "🎉 Your Odoo 19 Enterprise instance is ready!"
    print_success "Access it at: http://$SERVER_IP:$MAIN_PORT"
else
    print_error "❌ Deployment may have issues. Service status:"
    echo "$service_check"
    print_error "Please check the logs on the server:"
    print_error "ssh $SERVER_USER@$SERVER_IP 'cd /opt/$INSTANCE_NAME && docker compose logs'"
    exit 1
fi
