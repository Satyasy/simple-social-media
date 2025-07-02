#!/bin/bash

# Update DB config from environment
sed -i "s/DB_HOST=.*/DB_HOST=${DB_HOST}/g" .env
sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD}/g" .env

# Run Laravel commands
php artisan migrate --force
php artisan db:seed --force
php artisan storage:link

# Run Apache
exec "$@"
