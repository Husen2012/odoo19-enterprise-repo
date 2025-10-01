# Custom Addons Directory

This directory is for your custom Odoo 19 Enterprise addons.

## Adding Addons

1. Copy your addon directories here
2. Restart the Odoo container: `docker compose restart odoo19`
3. Update the addon list in Odoo's Apps menu
4. Install your custom addons

## Example Structure

```
addons/
├── your_custom_addon/
│   ├── __init__.py
│   ├── __manifest__.py
│   ├── models/
│   ├── views/
│   ├── static/
│   └── security/
└── another_addon/
    ├── __init__.py
    ├── __manifest__.py
    └── ...
```

## Enterprise Addons

Enterprise addons are automatically managed in the `/enterprise/` directory. Do not modify that directory manually.

## Addon Development

### Creating a New Addon

```bash
# Access the Odoo container
docker compose exec odoo19 bash

# Create addon structure
mkdir -p /mnt/extra-addons/my_custom_addon
cd /mnt/extra-addons/my_custom_addon

# Create basic files
touch __init__.py
touch __manifest__.py
mkdir models views static security
```

### Manifest File Example

```python
{
    'name': 'My Custom Addon',
    'version': '19.0.1.0.0',
    'category': 'Custom',
    'summary': 'Custom addon for specific business needs',
    'description': """
        Detailed description of your addon
    """,
    'author': 'Your Company',
    'website': 'https://yourcompany.com',
    'depends': ['base', 'web'],
    'data': [
        'security/ir.model.access.csv',
        'views/custom_views.xml',
    ],
    'assets': {
        'web.assets_backend': [
            'my_custom_addon/static/src/css/custom.css',
            'my_custom_addon/static/src/js/custom.js',
        ],
    },
    'installable': True,
    'auto_install': False,
    'application': False,
    'license': 'LGPL-3',
}
```

## Best Practices

### Development Guidelines
- Follow Odoo coding standards
- Use proper naming conventions
- Include proper documentation
- Add security rules (ir.model.access.csv)
- Test thoroughly before deployment

### Version Control
- Keep your custom addons in version control
- Use semantic versioning
- Document changes in CHANGELOG.md
- Tag releases properly

### Performance Considerations
- Optimize database queries
- Use proper indexing
- Minimize external API calls
- Cache frequently accessed data

## Testing Addons

### Unit Testing
```bash
# Run tests for specific addon
docker compose exec odoo19 odoo -d test_db -i my_custom_addon --test-enable --stop-after-init

# Run all tests
docker compose exec odoo19 odoo -d test_db --test-enable --stop-after-init
```

### Manual Testing
1. Create a test database
2. Install your addon
3. Test all functionality
4. Check logs for errors
5. Verify performance

## Deployment

### Production Deployment
1. Test addon thoroughly in development
2. Create backup of production database
3. Deploy addon to production server
4. Update addon list in Odoo
5. Install/upgrade addon
6. Monitor for issues

### Staging Environment
Always test addons in a staging environment that mirrors production before deploying to live systems.

## Troubleshooting

### Common Issues
1. **Import Errors**: Check Python syntax and imports
2. **Permission Errors**: Verify file permissions and security rules
3. **Database Errors**: Check model definitions and migrations
4. **View Errors**: Validate XML syntax and field references

### Debug Mode
```bash
# Enable debug mode
docker compose exec odoo19 odoo --dev=all -d your_db

# Check logs
docker compose logs -f odoo19
```

## Notes

- This directory is mounted as `/mnt/extra-addons` inside the container
- Make sure your addon directories have proper permissions (755 for directories, 644 for files)
- Restart Odoo after adding new addons
- Enterprise addons are located in `/mnt/enterprise-addons` (read-only)
- Custom addons take precedence over standard addons with the same name

## Resources

- [Odoo Developer Documentation](https://www.odoo.com/documentation/19.0/developer.html)
- [Odoo Enterprise Documentation](https://www.odoo.com/documentation/19.0/applications.html)
- [Addon Development Tutorial](https://www.odoo.com/documentation/19.0/developer/tutorials.html)
- [Best Practices Guide](https://www.odoo.com/documentation/19.0/developer/misc/other/guidelines.html)
