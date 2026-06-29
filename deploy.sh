#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

echo "=== Starting Deployment ==="

# Go to the project directory
cd /www/wwwroot/tld-bpad.nttprov.go.id

# Pull the latest changes from the main branch
echo "Pulling latest changes from GitHub..."
git pull origin main

# Install Composer dependencies
echo "Installing PHP dependencies..."
composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader

# Run database migrations
echo "Running database migrations..."
php artisan migrate --force

# Optimize Laravel Cache
echo "Clearing and optimizing application cache..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Install NPM dependencies & Build assets
if [ -f "package.json" ]; then
    echo "Installing Node.js dependencies..."
    npm install
    echo "Building assets (Vite)..."
    npm run build
fi

# Set proper ownership & permissions for aaPanel
echo "Applying permissions..."
chown -R www:www /www/wwwroot/tld-bpad.nttprov.go.id
chmod -R 755 /www/wwwroot/tld-bpad.nttprov.go.id/storage
chmod -R 755 /www/wwwroot/tld-bpad.nttprov.go.id/bootstrap/cache

echo "=== Deployment Finished Successfully! ==="
