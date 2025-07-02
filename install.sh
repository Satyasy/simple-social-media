#!/bin/bash

npm install
npm run dev
mkdir -p /var/www/sosmed/bootstrap/cache
chmod -R 777 /var/www/sosmed/bootstrap/cache
composer install
cp .env.example .env
php artisan key:generate

sed -i 's/DB_HOST=127.0.0.1/DB_HOST=172.17.0.2/g' .env &&
sed -i 's/DB_PASSWORD=/DB_PASSWORD=password/g' .env &&

php artisan migrate
php artisan db:seed
php artisan storage:link
