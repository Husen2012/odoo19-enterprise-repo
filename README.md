# 🚀 Enhanced Odoo 19 Enterprise Docker Compose with pgbouncer

A production-ready, enhanced Docker Compose setup for Odoo 19 Enterprise with PostgreSQL 17, Redis, and pgbouncer connection pooling. Perfect for deploying multiple Odoo Enterprise instances with automatic port management and conflict detection.

## ✨ Features

- **🏢 Odoo 19 Enterprise**: Latest Enterprise edition with all premium features
- **🐳 Complete Docker Stack**: Odoo 19 Enterprise, PostgreSQL 17, Redis, pgbouncer
- **🔧 Automatic Port Management**: Prevents port conflicts between instances
- **⚡ Performance Optimized**: Connection pooling with pgbouncer
- **🔄 Redis Session Storage**: Improved session management
- **📊 Resource Management**: Memory limits and health checks
- **🛡️ Production Ready**: Security configurations and error handling
- **🎨 Colored Output**: Beautiful terminal output with status indicators
- **🔍 Port Conflict Detection**: Automatically checks for port availability
- **🔐 Enterprise License**: Supports Odoo Enterprise license integration

## 🚀 Quick Start

### One-Line Installation

```bash
cd /opt
curl -s https://raw.githubusercontent.com/Husen2012/odoo19-enterprise-repo/main/run.sh | sudo bash -s odoo19-ent 10019 20019 6389 6439
```

### Manual Installation

```bash
# 1. Clone the repository
git clone https://github.com/Husen2012/odoo19-enterprise-repo.git
cd odoo19-enterprise-repo

# 2. Make script executable
chmod +x run.sh

# 3. Run setup
sudo ./run.sh odoo19-ent 10019 20019 6389 6439
```

### Remote Server Deployment

```bash
# Deploy to remote server
./deploy-to-server.sh <server_ip> <username> <password> <instance_name> <main_port> <longpolling_port>

# Example:
./deploy-to-server.sh 31.220.79.196 root password123 odoo19-ent 10019 20019 6389 6439
```

## 📋 Usage Examples

### Basic Usage (Default Redis and pgbouncer ports)
```bash
./run.sh odoo19-ent 10019 20019
```

### Full Custom Ports (Recommended for multiple instances)
```bash
./run.sh odoo19-prod 10019 20019 6389 6439
./run.sh odoo19-dev  10020 20020 6390 6440
./run.sh odoo19-test 10021 20021 6391 6441
```

### Multiple Enterprise Instances Example
```bash
# Production instance
./run.sh odoo19-prod 10019 20019 6389 6439

# Development instance  
./run.sh odoo19-dev 10020 20020 6390 6440

# Testing instance
./run.sh odoo19-test 10021 20021 6391 6441
```

## 🔧 Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| `instance_name` | Name of the Odoo instance directory | ✅ Yes | - |
| `main_port` | Main Odoo web interface port | ✅ Yes | - |
| `longpolling_port` | Odoo longpolling/WebSocket port | ✅ Yes | - |
| `redis_port` | Redis server port | ❌ No | 6379 |
| `pgbouncer_port` | pgbouncer connection pooler port | ❌ No | 6432 |

## 🌐 Access Your Instance

After successful installation:

- **Main Interface**: `http://your-server-ip:main_port`
- **Master Password**: `Enterprise@2025`
- **Database Management**: Available through the web interface

## 📁 Directory Structure

```
your-instance-name/
├── docker-compose.yml      # Main Docker Compose configuration
├── etc/
│   └── odoo.conf          # Odoo configuration file
├── pgbouncer/
│   └── userlist.txt       # pgbouncer user authentication
├── addons/                # Custom addons directory
├── enterprise/            # Odoo Enterprise addons (auto-downloaded)
├── postgresql/            # PostgreSQL data (auto-created)
└── sessions/              # Odoo sessions directory
```

## 🐳 Docker Commands

```bash
# View logs
docker compose logs -f

# Stop the instance
docker compose down

# Restart services
docker compose restart

# View running containers
docker compose ps

# Access Odoo container shell
docker compose exec odoo19 bash
```

## ⚙️ Configuration

### Default Credentials
- **Master Password**: `Enterprise@2025`
- **Database User**: `odoo`
- **Database Password**: `odoo19@2025`

### Performance Settings
- **Workers**: 6 (optimized for Enterprise)
- **Memory Limit**: 3GB soft, 4GB hard
- **Connection Pool**: 50 connections via pgbouncer
- **Redis**: Session storage enabled

## 🏢 Enterprise Features

### Included Enterprise Apps
- **Accounting & Finance**: Advanced accounting, invoicing, payments
- **Sales & CRM**: Advanced CRM, quotations, sales automation
- **Inventory & MRP**: Advanced inventory, manufacturing, PLM
- **HR & Payroll**: Advanced HR, payroll, appraisals, recruitment
- **Project Management**: Advanced project management, timesheets
- **Marketing**: Email marketing, SMS marketing, social marketing
- **eCommerce**: Advanced website builder, eCommerce features
- **Studio**: Custom app builder and workflow automation
- **Documents**: Document management system
- **Helpdesk**: Advanced helpdesk and support ticketing
- **Field Service**: Field service management
- **Quality**: Quality control and management
- **Maintenance**: Equipment maintenance management

### License Configuration
Place your `odoo_enterprise.zip` file in the root directory before running the setup, or the system will download the latest version automatically.

## 🔒 Security Features

- Database listing disabled (`list_db = False`)
- Proxy mode enabled for reverse proxy compatibility
- Resource limits to prevent memory exhaustion
- Health checks for all services
- Enterprise-grade security configurations

## 🛠️ Customization

### Adding Custom Addons
```bash
# Copy your addons to the addons directory
cp -r /path/to/your/addon /opt/your-instance-name/addons/

# Restart Odoo to load new addons
cd /opt/your-instance-name
docker compose restart odoo19
```

### Enterprise Addons Management
```bash
# Enterprise addons are automatically managed
# Located in: /opt/your-instance-name/enterprise/
# Updated automatically with container restarts
```

## 🔧 Advanced Configuration

### Environment Variables
```bash
# Set in docker-compose.yml or .env file
ODOO_VERSION=19.0
POSTGRES_VERSION=17
REDIS_VERSION=latest
PGBOUNCER_VERSION=latest
```

### Custom Configuration
Edit `etc/odoo.conf` to customize:
- Database settings
- Performance parameters
- Security options
- Enterprise license settings

## 📊 Monitoring & Maintenance

### Health Checks
All services include comprehensive health checks:
- PostgreSQL: Database connectivity
- Redis: Service availability
- pgbouncer: Connection pooling status
- Odoo: Application readiness

### Resource Monitoring
```bash
# Monitor container resources
docker stats

# Check service logs
docker compose logs -f odoo19
docker compose logs -f db
docker compose logs -f redis
```

## 🚀 Production Deployment

### Recommended Server Specs
- **CPU**: 4+ cores
- **RAM**: 8GB+ (16GB recommended)
- **Storage**: 100GB+ SSD
- **Network**: 1Gbps+

### SSL & Domain Setup
1. Configure reverse proxy (Nginx Proxy Manager recommended)
2. Set up SSL certificates
3. Configure domain routing
4. Enable HTTPS redirects

## 🔄 Backup & Recovery

### Automated Backups
```bash
# Database backup
docker compose exec db pg_dump -U odoo postgres > backup_$(date +%Y%m%d).sql

# Full instance backup
tar -czf instance_backup_$(date +%Y%m%d).tar.gz /opt/your-instance-name/
```

### Recovery Process
```bash
# Restore database
docker compose exec -T db psql -U odoo postgres < backup_file.sql

# Restore files
tar -xzf instance_backup.tar.gz -C /opt/
```

## 🐛 Troubleshooting

### Common Issues
1. **Port conflicts**: Use different ports for multiple instances
2. **Memory issues**: Increase Docker memory limits
3. **Database connection**: Check pgbouncer configuration
4. **Enterprise license**: Verify license file placement

### Debug Commands
```bash
# Check container status
docker compose ps

# View detailed logs
docker compose logs --tail=100 odoo19

# Test database connection
docker compose exec db psql -U odoo -d postgres -c "SELECT version();"
```

## 📈 Performance Tuning

### Database Optimization
- Connection pooling via pgbouncer
- Optimized PostgreSQL settings
- Regular maintenance tasks

### Application Optimization
- Worker process scaling
- Memory limit optimization
- Redis session caching
- Static file serving

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Based on the original Odoo 18 enhanced setup
- Optimized for Odoo 19 Enterprise features
- Community feedback and contributions

## 📞 Support

- 📧 Email: support@yourcompany.com
- 🐛 Issues: [GitHub Issues](https://github.com/Husen2012/odoo19-enterprise-repo/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/Husen2012/odoo19-enterprise-repo/discussions)
- 📖 Documentation: [Wiki](https://github.com/Husen2012/odoo19-enterprise-repo/wiki)

## 🚀 Quick Deployment to Server

Deploy directly to your server with one command:

```bash
# Deploy to server 31.220.79.196
./deploy-to-server.sh 31.220.79.196 root your_password odoo19-ent 10019 20019 6389 6439
```

---

**⭐ Star this repository if it helped you!**
