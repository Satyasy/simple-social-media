FROM ubuntu:22.04

RUN apt update -y && \
    DEBIAN_FRONTEND=noninteractive apt install -y apache2 \
    php \
    npm \
    php-xml \
    php-mbstring \
    php-curl \
    php-mysql \
    php-gd \
    unzip \
    nano  \
    curl
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer

RUN mkdir /var/www/sosmed
ADD . /var/www/sosmed
ADD sosmed.conf /etc/apache2/sites-available/
RUN a2dissite 000-default.conf && \
    a2ensite sosmed.conf
WORKDIR /var/www/sosmed
RUN ./install.sh
RUN chown www-data:www-data /var/www/sosmed -R
RUN chmod -R 755 /var/www/sosmed
EXPOSE 8000
CMD php artisan serve --host=0.0.0.0 --port=8000
