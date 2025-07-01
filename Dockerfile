FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update -y && \
    apt-get install -y \
    apache2 \
    php \
    php-cli \
    php-xml \
    php-mbstring \
    php-curl \
    php-mysql \
    php-gd \
    unzip \
    nano \
    curl \
    git \
    supervisor \
    lsb-release \
    ca-certificates \
    apt-transport-https \
    software-properties-common

# Install Node.js (using NodeSource to get recent version)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Install Composer
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    rm composer-setup.php

# Set working directory
RUN mkdir -p /var/www/sosmed
WORKDIR /var/www/sosmed

# Copy source code and Apache config
COPY . /var/www/sosmed
COPY sosmed.conf /etc/apache2/sites-available/

# Enable site and rewrite module
RUN a2dissite 000-default.conf && \
    a2ensite sosmed.conf && \
    a2enmod rewrite

# Install PHP dependencies and JS assets
RUN composer install --no-interaction --prefer-dist --optimize-autoloader && \
    npm install && \
    npm run build

# Prepare Laravel
RUN cp .env.example .env && \
    php artisan key:generate && \
    php artisan migrate --force && \
    php artisan db:seed --force && \
    php artisan storage:link

# Permissions
RUN chown -R www-data:www-data /var/www/sosmed && \
    chmod -R 755 /var/www/sosmed/bootstrap/cache && \
    chmod -R 755 /var/www/sosmed/storage

EXPOSE 80

CMD ["apachectl", "-D", "FOREGROUND"]
