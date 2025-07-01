#!/bin/bash
set -e
set -x

npm install
npm run dev

mkdir -p bootstrap/cache
chmod -R 775 bootstrap/cache

export COMPOSER_MEMORY_LIMIT=-1
export COMPOSER_RETRY=5
composer config --no-plugins allow-plugins.dealerdirect/phpcodesniffer-composer-installer true
composer install --prefer-dist --no-interaction --no-progress

cp .env.example .env
php artisan key:generate

sed -i 's/DB_HOST=127.0.0.1/DB_HOST=172.17.0.2/g' .env
sed -i 's/DB_PASSWORD=/DB_PASSWORD=password/g' .env

php artisan migrate
php artisan db:seed
php artisan storage:link
