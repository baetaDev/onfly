FROM php:8.2-fpm

LABEL maintainer="Travel Orders Team"
LABEL description="Laravel application container for Travel Orders Service"

# Define working directory
WORKDIR /var/www

# Install system dependencies and PHP extensions dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions required by Laravel
RUN docker-php-ext-install \
    pdo_mysql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    zip

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy application entrypoint script
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Copy PHP-FPM pool configuration
COPY docker/php/www.conf /usr/local/etc/php-fpm.d/www.conf

# Copy application files
COPY . /var/www

# Set proper ownership and permissions
RUN chown -R www-data:www-data /var/www

# Expose PHP-FPM port
EXPOSE 9000

# Use custom entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
