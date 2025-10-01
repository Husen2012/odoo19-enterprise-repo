# 🚀 Odoo 19 Enterprise Quick Setup Guide

## Prerequisites

Before running the setup, ensure you have:

- ✅ **Docker** installed and running
- ✅ **Docker Compose** plugin installed
- ✅ **Git** installed (for cloning)
- ✅ **Root/sudo access** (for system configurations)
- ✅ **Valid Odoo Enterprise License** (required for Enterprise features)

## Installation Methods

### Method 1: One-Line Installation (Recommended)

```bash
cd /opt
curl -s https://raw.githubusercontent.com/Husen2012/odoo19-enterprise-repo/main/run.sh | sudo bash -s odoo19-ent 10019 20019 6389 6439
```

### Method 2: Manual Installation

```bash
# 1. Clone the repository
git clone https://github.com/Husen2012/odoo19-enterprise-repo.git
cd odoo19-enterprise-repo

# 2. Make script executable
chmod +x run.sh

# 3. Run setup
sudo ./run.sh odoo19-ent 10019 20019 6389 6439
```

## Multiple Enterprise Instances Setup

```bash
# Production instance
sudo ./run.sh odoo19-prod 10019 20019 6389 6439

# Development instance
sudo ./run.sh odoo19-dev 10020 20020 6390 6440

# Testing instance
sudo ./run.sh odoo19-test 10021 20021 6391 6441

# Staging instance
sudo ./run.sh odoo19-stage 10022 20022 6392 6442
```

## Post-Installation

1. **Access your instance**: `http://your-server-ip:10019`
2. **Master password**: `Enterprise@2025`
3. **Create your first database** through the web interface
4. **Configure Enterprise license** in the database settings
5. **Add custom addons** to the `addons/` directory

## Common Port Ranges

| Instance Type | Main Port | Longpolling | Redis | pgbouncer |
|---------------|-----------|-------------|-------|-----------|
| Production    | 10019     | 20019       | 6389  | 6439      |
| Development   | 10020     | 20020       | 6390  | 6440      |
| Testing       | 10021     | 20021       | 6391  | 6441      |
| Staging       | 10022     | 20022       | 6392  | 6442      |

## Enterprise License Configuration

### Method 1: License File
```bash
# Place your license file in the instance directory
cp /path/to/your/license.txt /opt/your-instance-name/enterprise_license.txt

# Restart the container
cd /opt/your-instance-name
docker compose restart odoo19
```

### Method 2: Database Configuration
1. Access your Odoo instance
2. Go to Settings > General Settings
3. Navigate to the "Enterprise License" section
4. Upload your license file or enter license key

## Verification

After installation, verify everything is working:

```bash
# Check if containers are running
docker compose ps

# Test the web interface
curl -I http://localhost:10019

# Check logs
docker compose logs -f

# Verify Enterprise features
curl -s http://localhost:10019/web/webclient/version_info | grep -i enterprise
```

## Enterprise Features Verification

### Available Enterprise Apps
After setup, verify these Enterprise apps are available:

- **Accounting**: Advanced accounting features
- **CRM**: Advanced customer relationship management
- **Sales**: Advanced sales management
- **Inventory**: Advanced inventory and manufacturing
- **HR**: Human resources and payroll
- **Project**: Advanced project management
- **Marketing**: Email and SMS marketing
- **Website**: Advanced website builder
- **eCommerce**: Online store features
- **Studio**: Custom app development
- **Documents**: Document management
- **Helpdesk**: Customer support ticketing
- **Field Service**: Field service management
- **Quality**: Quality control management
- **Maintenance**: Equipment maintenance

### Performance Optimization

```bash
# Monitor resource usage
docker stats

# Check database performance
docker compose exec db psql -U odoo -d postgres -c "SELECT * FROM pg_stat_activity;"

# Monitor Redis cache
docker compose exec redis redis-cli info memory
```

## SSL/HTTPS Setup

### Using Nginx Proxy Manager (Recommended)
1. Install Nginx Proxy Manager
2. Create proxy host pointing to your Odoo instance
3. Enable SSL certificate (Let's Encrypt)
4. Configure force SSL redirect

### Manual Nginx Configuration
```nginx
server {
    listen 443 ssl;
    server_name your-domain.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/private.key;
    
    location / {
        proxy_pass http://localhost:10019;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /longpolling {
        proxy_pass http://localhost:20019;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Backup Configuration

### Automated Database Backup
```bash
# Create backup script
cat > /opt/backup-odoo19.sh << 'EOF'
#!/bin/bash
INSTANCE_NAME="your-instance-name"
BACKUP_DIR="/opt/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Database backup
docker compose -f /opt/$INSTANCE_NAME/docker-compose.yml exec -T db pg_dump -U odoo postgres > $BACKUP_DIR/db_backup_$DATE.sql

# Filestore backup
tar -czf $BACKUP_DIR/filestore_backup_$DATE.tar.gz /opt/$INSTANCE_NAME/filestore/

# Custom addons backup
tar -czf $BACKUP_DIR/addons_backup_$DATE.tar.gz /opt/$INSTANCE_NAME/addons/

# Clean old backups (keep last 7 days)
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
EOF

chmod +x /opt/backup-odoo19.sh

# Add to crontab for daily backup at 2 AM
echo "0 2 * * * /opt/backup-odoo19.sh" | crontab -
```

## Troubleshooting

### Common Issues

1. **Enterprise License Error**
   ```bash
   # Check license file
   docker compose exec odoo19 ls -la /mnt/enterprise-addons/
   
   # Verify license in database
   docker compose exec db psql -U odoo -d your_db -c "SELECT * FROM ir_config_parameter WHERE key LIKE '%enterprise%';"
   ```

2. **Memory Issues**
   ```bash
   # Increase memory limits in docker-compose.yml
   # Monitor memory usage
   docker stats --no-stream
   ```

3. **Port Conflicts**
   ```bash
   # Check port usage
   netstat -tulpn | grep :10019
   
   # Use different ports
   ./run.sh odoo19-new 10025 20025 6395 6445
   ```

## Next Steps

1. 📚 Read the full [README.md](README.md) for detailed documentation
2. 🔧 Customize your [odoo.conf](etc/odoo.conf) if needed
3. 📦 Add your custom addons to the `addons/` directory
4. 🏢 Configure Enterprise license and features
5. 🔒 Change default passwords for production use
6. 🔄 Set up automated backups
7. 🌐 Configure domain and SSL certificates

## Need Help?

- 📖 Check the [README.md](README.md) for detailed documentation
- 🐛 Report issues on [GitHub Issues](https://github.com/Husen2012/odoo19-enterprise-repo/issues)
- 💬 Join discussions on [GitHub Discussions](https://github.com/Husen2012/odoo19-enterprise-repo/discussions)
- 📧 Contact support: support@yourcompany.com

---

**⚠️ Important**: This setup requires a valid Odoo Enterprise license. Make sure you have proper licensing before using Enterprise features in production.
