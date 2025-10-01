# Odoo 19 Enterprise Addons Directory

This directory contains the official Odoo 19 Enterprise addons. These addons are automatically managed and should not be modified manually.

## ⚠️ Important Notice

- **DO NOT MODIFY** files in this directory
- Enterprise addons are automatically downloaded and updated
- Requires valid Odoo Enterprise license
- This directory is mounted as `/mnt/enterprise-addons` in the container

## 🏢 Enterprise Addons Included

### Accounting & Finance
- `account_accountant` - Advanced accounting features
- `account_asset` - Asset management
- `account_budget` - Budget management
- `account_consolidation` - Multi-company consolidation
- `account_reports` - Advanced financial reports
- `account_sepa` - SEPA payments
- `account_taxcloud` - TaxCloud integration
- `currency_rate_live` - Live currency rates

### Sales & CRM
- `crm_enterprise` - Advanced CRM features
- `sale_enterprise` - Advanced sales features
- `sale_subscription` - Subscription management
- `sale_amazon` - Amazon integration
- `sale_ebay` - eBay integration
- `website_sale_dashboard` - Sales dashboard

### Inventory & Manufacturing
- `mrp_enterprise` - Advanced manufacturing
- `mrp_plm` - Product Lifecycle Management
- `mrp_workorder` - Work order management
- `quality_control` - Quality control
- `stock_barcode` - Barcode scanning
- `stock_enterprise` - Advanced inventory

### Human Resources
- `hr_payroll_enterprise` - Advanced payroll
- `hr_appraisal` - Employee appraisals
- `hr_recruitment_enterprise` - Advanced recruitment
- `hr_work_entry_contract_enterprise` - Work entries
- `planning` - Employee planning
- `hr_referral` - Employee referral program

### Project Management
- `project_enterprise` - Advanced project management
- `project_forecast` - Resource forecasting
- `timesheet_grid` - Timesheet grid view
- `sale_timesheet_enterprise` - Sales timesheet integration

### Marketing
- `mass_mailing_enterprise` - Advanced email marketing
- `marketing_automation` - Marketing automation
- `social_media` - Social media management
- `sms` - SMS marketing

### Website & eCommerce
- `website_enterprise` - Advanced website features
- `website_sale_extra` - eCommerce extras
- `website_studio` - Website builder
- `website_helpdesk` - Website helpdesk integration

### Business Intelligence
- `web_dashboard` - Advanced dashboards
- `web_cohort` - Cohort analysis
- `web_gantt` - Gantt charts
- `web_grid` - Grid views
- `web_map` - Map views

### Document Management
- `documents` - Document management system
- `documents_hr` - HR documents
- `documents_account` - Accounting documents
- `documents_project` - Project documents

### Field Service
- `industry_fsm` - Field service management
- `industry_fsm_sale` - FSM sales integration
- `industry_fsm_stock` - FSM inventory integration

### Helpdesk
- `helpdesk` - Advanced helpdesk
- `helpdesk_timesheet` - Helpdesk timesheets
- `helpdesk_sale` - Helpdesk sales integration

### Studio & Customization
- `web_studio` - Visual app builder
- `web_enterprise` - Enterprise web features
- `base_automation` - Automated actions

### Maintenance
- `maintenance` - Equipment maintenance
- `maintenance_plan` - Maintenance planning

### Other Enterprise Features
- `voip` - VoIP integration
- `web_mobile` - Mobile app support
- `iot` - Internet of Things
- `data_cleaning` - Data cleaning tools
- `web_gantt` - Gantt chart views

## 📋 License Requirements

To use these Enterprise addons, you need:

1. **Valid Odoo Enterprise License**
2. **Active Subscription** with Odoo S.A.
3. **Proper License Configuration** in your database

## 🔧 Configuration

### License Setup
1. Access your Odoo instance
2. Go to Settings > General Settings
3. Find "Enterprise License" section
4. Upload your license file or enter license key
5. Save and restart if required

### Automatic Updates
Enterprise addons are automatically updated when:
- Container is restarted
- Odoo service is restarted
- Manual update is triggered

## 🚫 Restrictions

### What NOT to do:
- Don't modify files in this directory
- Don't delete enterprise addon files
- Don't copy enterprise addons to custom locations
- Don't redistribute enterprise addons

### Legal Notice
These addons are proprietary software owned by Odoo S.A. and are protected by copyright law. Unauthorized use, distribution, or modification is prohibited.

## 🔍 Verification

### Check Enterprise Status
```bash
# Verify enterprise addons are loaded
docker compose exec odoo19 odoo shell -d your_db

# In Odoo shell:
# >>> self.env['ir.module.module'].search([('name', 'like', 'enterprise')])
```

### License Verification
```bash
# Check license status in database
docker compose exec db psql -U odoo -d your_db -c "SELECT key, value FROM ir_config_parameter WHERE key LIKE '%enterprise%';"
```

## 📞 Support

For Enterprise addon issues:
- Contact Odoo Enterprise Support
- Check Odoo Enterprise Documentation
- Verify your license status
- Ensure subscription is active

## 🔄 Updates

Enterprise addons are updated automatically. To force an update:

```bash
# Restart the container to get latest enterprise addons
docker compose restart odoo19

# Or rebuild the container
docker compose down
docker compose up -d
```

---

**Note**: This directory is automatically managed. Any manual changes will be lost when the container is restarted or updated.
