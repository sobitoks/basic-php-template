FROM php:8.2.14-fpm-alpine as app

ARG UID=1000
ARG GID=1000

RUN addgroup -g $GID appusergroup \
    && adduser -u $UID -G appusergroup --disabled-password --gecos "" -D appuser

RUN mkdir -p /home/appuser/.ssh
RUN echo "StrictHostKeyChecking no" >> /home/appuser/.ssh/config
RUN mkdir -p /appdata/www
WORKDIR /appdata/www

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN set -eux; \
    install-php-extensions pdo pdo_mysql opcache amqp
#RUN docker-php-ext-install pdo pdo_mysql

ENV COMPOSER_ALLOW_SUPERUSER=1
COPY --from=composer:2.4 /usr/bin/composer /usr/bin/composer
COPY ./app/composer.* ./
RUN composer install --prefer-dist --no-dev --no-scripts --no-progress --no-interaction
COPY ./app .
RUN composer dump-autoload --optimize

RUN wget https://cs.symfony.com/download/php-cs-fixer-v3.phar -O php-cs-fixer
RUN chmod a+x php-cs-fixer
RUN mv php-cs-fixer /usr/local/bin/php-cs-fixer

# multistage build
FROM app as app_dev

ENV XDEBUG_MODE=off

COPY ./docker/php/conf.d/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# Install the most recent STABLE xdebug 3.x version (for example 3.2.2) -> xdebug-^3@stable
RUN set -eux; \
    install-php-extensions xdebug-3.3.1