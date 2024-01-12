FROM php:8.2-fpm-alpine as app

ARG UID=1000
ARG GID=1000

RUN addgroup -g ${GID} appusergroup \
    && adduser -u ${UID} -G appusergroup --disabled-password --gecos "" -D appuser \

RUN echo "StrictHostKeyChecking no" >> /home/appuser/.ssh/config


COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN set -eux; \
    install-php-extensions pdo pdo_mysql
#RUN docker-php-ext-install pdo pdo_mysql

RUN docker-php-ext-enable --ini-name 05-opcache.ini opcache


ENV COMPOSER_ALLOW_SUPERUSER=1
COPY --from=composer:2.4 /usr/bin/composer /usr/bin/composer
COPY ./app/composer.* ./
RUN composer install --prefer-dist --no-dev --no-scripts --no-progress --no-interaction
COPY ./app .
RUN composer dump-autoload --optimize


# multistage build
FROM app as app_dev

ENV XDEBUG_MODE=off

COPY ./docker/php/conf.d/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

RUN set -eux; \
    install-php-extensions xdebug