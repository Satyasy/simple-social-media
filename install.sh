#!/bin/bash
git config --global --add safe.directory /var/www/sosmed

# Use a local npm cache/log directory instead of /root/.npm
export NPM_CONFIG_CACHE=/tmp/.npm
mkdir -p /tmp/.npm/_logs
chmod -R 777 /tmp/.npm

npm ci || npm install --unsafe-perm
npm run dev
composer install
cp .env.example .env
php artisan key:generate
sed -i 's/DB_HOST=127.0.0.1/DB_HOST=172.17.0.2/g' .env &&
sed -i 's/DB_PASSWORD=/DB_PASSWORD=password/g' .env &&

php artisan migrate
php artisan db:seed
php artisan storage:link
