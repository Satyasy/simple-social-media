#!/bin/bash
set -e

# Tunggu sampai database siap
# 'mysql' adalah nama hostname container MySQL yang Anda jalankan di GitHub Actions
echo "Waiting for MySQL to be ready..."
until nc -z -v -w30 mysql 3306; do
  echo "Waiting for database connection..."
  sleep 5
done
echo "MySQL is up and running!"

# Setup Laravel environment dan jalankan migrasi/seeding
# cp -n akan menyalin .env.example jika .env belum ada
cp -n .env.example .env || true

# Generate application key
php artisan key:generate --force

# Konfigurasi koneksi DB di .env
# DB_HOST diatur ke 'mysql' karena itu adalah nama service/container MySQL
# yang akan dijangkau dari container Laravel di network yang sama.
sed -i '/^DB_HOST=/c\DB_HOST=mysql' .env
sed -i '/^DB_DATABASE=/c\DB_DATABASE=social_media' .env # Sesuaikan dengan MYSQL_DATABASE di workflow
sed -i '/^DB_USERNAME=/c\DB_USERNAME=root' .env
sed -i '/^DB_PASSWORD=/c\DB_PASSWORD=password' .env # Sesuaikan dengan MYSQL_ROOT_PASSWORD

# Jalankan migrasi dan seeding database
php artisan migrate --force
php artisan db:seed --force
php artisan storage:link

# Jalankan command utama aplikasi (Laravel Serve)
echo "Starting Laravel application..."
exec php artisan serve --host=0.0.0.0 --port=8000
