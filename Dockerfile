FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system packages
RUN apt update -y && \
    apt install -y apache2 \
    php \
    php-cli \
    php-mbstring \
    php-xml \
    php-curl \
    php-mysql \
    php-gd \
    php-zip \
    php-bcmath \
    php-tokenizer \
    libapache2-mod-php \
    unzip \
    curl \
    nano \
    nodejs \
    npm \
    git

# Install Composer
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    rm composer-setup.php

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Create project directory
RUN mkdir -p /var/www/sosmed

# Copy application files
COPY . /var/www/sosmed
COPY sosmed.conf /etc/apache2/sites-available/sosmed.conf

# Set working directory
WORKDIR /var/www/sosmed

# Permissions
RUN chown -R www-data:www-data /var/www/sosmed && \
    chmod -R 755 /var/www/sosmed && \
    mkdir -p bootstrap/cache && \
    chmod -R 775 bootstrap/cache

# Install dependencies (build time)
RUN composer install --no-interaction --prefer-dist --optimize-autoloader && \
    npm install && \
    npm run build && \
    cp .env.example .env && \
    php artisan key:generate

# Enable Apache site
RUN a2dissite 000-default.conf && a2ensite sosmed.conf

# Expose port
EXPOSE 80

# Entrypoint script (for migrations & seeding)
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Run entrypoint then Apache
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["apache2ctl", "-D", "FOREGROUND"]
