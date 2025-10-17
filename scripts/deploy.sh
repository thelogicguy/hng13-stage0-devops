#!/bin/bash
set -e

echo "🚀 Starting deployment..."

# Configuration
DEPLOY_DIR="/var/www/mywebsite/html"
BACKUP_DIR="/opt/deployments/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create backup
echo "📦 Creating backup..."
sudo mkdir -p "$BACKUP_DIR"
if [ -d "$DEPLOY_DIR" ] && [ "$(ls -A $DEPLOY_DIR)" ]; then
    sudo tar -czf "$BACKUP_DIR/backup_$TIMESTAMP.tar.gz" -C "$DEPLOY_DIR" .
    echo "✅ Backup created: backup_$TIMESTAMP.tar.gz"
fi

# Deploy new files
echo "📁 Deploying new files..."
sudo rsync -av --delete src/ "$DEPLOY_DIR/"

# Set correct permissions
echo "🔐 Setting permissions..."
sudo chown -R deploy:www-data "$DEPLOY_DIR"
sudo find "$DEPLOY_DIR" -type d -exec chmod 755 {} \;
sudo find "$DEPLOY_DIR" -type f -exec chmod 644 {} \;

# Test NGINX configuration
echo "🔍 Testing NGINX configuration..."
sudo nginx -t

# Reload NGINX
echo "🔄 Reloading NGINX..."
sudo systemctl reload nginx

# Keep only last 5 backups
echo "🧹 Cleaning old backups..."
sudo ls -t "$BACKUP_DIR"/backup_*.tar.gz | tail -n +6 | xargs -r sudo rm

echo "✅ Deployment completed successfully!"
echo "🌐 Website is live!"
EOF

chmod +x scripts/deploy.sh