# Gunakan image dasar Ubuntu 22.04 LTS
FROM ubuntu:22.04

# Set environment variable untuk menghindari prompt interaktif saat instalasi paket
ENV DEBIAN_FRONTEND=noninteractive

# 1. Update package list dan instal semua dependency yang dibutuhkan
# Termasuk Apache2, PHP (dengan ekstensi), Composer, Node.js, NPM, git, supervisor, dan netcat
RUN apt update -y && \
    apt install -y \
    apache2 \
    php \
    php-xml \
    php-mbstring \
    php-curl \
    php-mysql \
    php-gd \
    unzip \
    nano \
    curl \
    npm \
    nodejs \
    git \
    supervisor \
    gnupg \
    lsb-release \
    ca-certificates \
    netcat-traditional # <-- NETCAT ditambahkan di sini

# 2. Instal Composer secara global
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# 3. Siapkan direktori aplikasi
RUN mkdir -p /var/www/sosmed
# Salin kode aplikasi ke direktori kerja
COPY . /var/www/sosmed

# Atur WORKDIR ke direktori aplikasi
WORKDIR /var/www/sosmed

# 4. Atur kepemilikan dan izin direktori Laravel
# Pastikan semua file aplikasi dimiliki oleh www-data dan memiliki izin yang sesuai
RUN chown -R www-data:www-data /var/www/sosmed && \
    chmod -R 775 /var/www/sosmed && \
    # Pastikan direktori cache dan storage bisa ditulisi SEBELUM perintah Laravel
    mkdir -p /var/www/sosmed/bootstrap/cache && \
    mkdir -p /var/www/sosmed/storage && \
    chmod -R 775 /var/www/sosmed/storage /var/www/sosmed/bootstrap/cache

# 5. Konfigurasi Apache2
COPY sosmed.conf /etc/apache2/sites-available/sosmed.conf
RUN a2dissite 000-default.conf && \
    a2ensite sosmed.conf && \
    a2enmod rewrite

# 6. Jalankan instalasi Node.js dan Composer di tahap build
# Ini adalah langkah yang akan menghasilkan artifact di image
RUN npm ci || npm install --unsafe-perm && \
    npm run dev && \
    composer install --no-dev --optimize-autoloader

# Salin entrypoint script dan berikan izin eksekusi
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 8000
# CMD menjalankan entrypoint script
CMD ["docker-entrypoint.sh"]
