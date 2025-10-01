#!/bin/bash

# Script to push Odoo 19 Enterprise repository to GitHub
# Run this after creating the repository on GitHub

echo "🚀 Pushing Odoo 19 Enterprise repository to GitHub..."

# Add remote origin (update with your GitHub username if different)
git remote add origin https://github.com/Husen2012/odoo19-enterprise-repo.git

# Push to GitHub
git push -u origin main

echo "✅ Repository pushed to GitHub successfully!"
echo "🌐 Repository URL: https://github.com/Husen2012/odoo19-enterprise-repo"
echo ""
echo "📋 Next steps:"
echo "1. Visit your repository on GitHub"
echo "2. Update repository description if needed"
echo "3. Add topics/tags for better discoverability"
echo "4. Consider adding a repository banner/logo"
echo "5. Set up branch protection rules if needed"
