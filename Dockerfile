FROM php:7.2-fpm
ARG TIMEZONE="Europe/Prague"

RUN apt-get update \
    && apt-get install -y openssl unzip git software-properties-common libzip-dev libxml2-dev libpng-dev

RUN docker-php-ext-configure zip --with-libzip
RUN docker-php-ext-install mysqli pdo pdo_mysql xml zip gd

# Install Composer
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_NO_INTERACTION=1
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer --version
RUN mkdir -p /var/cache /vendor

COPY ./php-ini-overrides.ini /usr/local/etc/php/conf.d/99-overrides.ini

# Redis
RUN pecl install -o -f redis \
&&  rm -rf /tmp/pear \
&&  docker-php-ext-enable redis

# Set timezone
RUN ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && echo ${TIMEZONE} > /etc/timezone
RUN printf '[PHP]\ndate.timezone = "%s"\n', ${TIMEZONE} > /usr/local/etc/php/conf.d/tzone.ini
RUN "date"

# xdebug
RUN pecl install xdebug;
