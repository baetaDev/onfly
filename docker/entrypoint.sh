#!/bin/bash
set -e

cd /var/www

# Check if Laravel is installed
if [ ! -f "artisan" ] || [ ! -f "composer.json" ]; then
    echo "[INFO] Laravel not found. Installing Laravel..."
    
    # Install Laravel via Composer in temporary directory
    composer create-project laravel/laravel /tmp/laravel-install --prefer-dist --no-interaction
    
    # Move Laravel files to /var/www, preserving existing Docker files
    cd /tmp/laravel-install
    for item in * .[!.]*; do
        if [ "$item" != "." ] && [ "$item" != ".." ] && [ ! -e "/var/www/$item" ]; then
            cp -r "$item" /var/www/ 2>/dev/null || true
        fi
    done
    cd /var/www
    rm -rf /tmp/laravel-install
    
    echo "[SUCCESS] Laravel installed successfully"
else
    echo "[INFO] Laravel already installed"
fi

# Install Composer dependencies
if [ -f "composer.json" ]; then
    echo "[INFO] Installing Composer dependencies..."
    if [ -f "composer.lock" ]; then
        composer install --no-interaction --prefer-dist --optimize-autoloader 2>&1 || {
            echo "[WARNING] Error installing from lock file, trying update..."
            rm -f composer.lock
            composer update --no-interaction --prefer-dist 2>&1 || echo "[WARNING] Composer error, continuing..."
        }
    else
        composer install --no-interaction --prefer-dist --optimize-autoloader 2>&1 || echo "[WARNING] Composer error, continuing..."
    fi
fi

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "[INFO] Creating .env file..."
    if [ -f ".env.example" ]; then
        cp .env.example .env
    else
        cat > .env <<'ENVFILE'
APP_NAME=Laravel
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost

LOG_CHANNEL=stack
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=onfly
DB_USERNAME=onfly
DB_PASSWORD=onfly

BROADCAST_DRIVER=log
CACHE_DRIVER=file
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120
ENVFILE
    fi
    
    # Generate application key
    if [ -f "artisan" ] && [ -d "vendor" ]; then
        php artisan key:generate --ansi
    fi
fi

# Fix storage and bootstrap/cache permissions
if [ -d "storage" ]; then
    echo "[INFO] Setting storage permissions..."
    chown -R www-data:www-data storage bootstrap/cache 2>/dev/null || true
    chmod -R 775 storage bootstrap/cache 2>/dev/null || true
    find storage bootstrap/cache -type d -exec chmod 775 {} \; 2>/dev/null || true
    find storage bootstrap/cache -type f -exec chmod 664 {} \; 2>/dev/null || true
fi

# Start PHP-FPM
echo "[INFO] Starting PHP-FPM..."
php-fpm -D
sleep 2

# Verify PHP-FPM is running
if ! ss -tln | grep -q ":9000"; then
    echo "[ERROR] PHP-FPM failed to start, retrying..."
    php-fpm -D
    sleep 2
fi

# Wait for database and run migrations in background
if [ -f "artisan" ]; then
    (
        echo "[INFO] Waiting for database connection..."
        max_attempts=30
        attempt=0
        
        while [ $attempt -lt $max_attempts ]; do
            if mysqladmin ping -h db -u onfly -ponfly &>/dev/null 2>&1; then
                echo "[SUCCESS] Database connection established"
                
                # Run migrations if any exist
                if [ -d "database/migrations" ] && [ "$(ls -A database/migrations/*.php 2>/dev/null)" ]; then
                    echo "[INFO] Running database migrations..."
                    php artisan migrate --force || echo "[WARNING] Migration error"
                fi
                break
            fi
            attempt=$((attempt + 1))
            if [ $((attempt % 5)) -eq 0 ]; then
                echo "[INFO] Database connection attempt $attempt/$max_attempts..."
            fi
            sleep 2
        done
    ) &
fi

# Keep container alive and monitor PHP-FPM
echo "[INFO] PHP-FPM is running. Container is ready."
while true; do
    if ! ss -tln | grep -q ":9000"; then
        echo "[WARNING] PHP-FPM stopped, restarting..."
        php-fpm -D
        sleep 2
    fi
    sleep 10
done
