FROM php:8.3-fpm-alpine as build
ARG VERSION

RUN apk add --no-cache \
    zip \
    libzip-dev \
    freetype \
    libjpeg-turbo \
    libpng \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    nodejs \
    npm \
    7zip \
    libsodium-dev \
    bash \
    git \
    && docker-php-ext-configure zip \
    && docker-php-ext-install zip pdo pdo_mysql bcmath opcache sodium \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-enable gd zip pdo pdo_mysql bcmath opcache sodium

# install composer

COPY --from=composer:2.7.6 /usr/bin/composer /usr/bin/composer

WORKDIR /app

RUN git clone https://github.com/LinkStackOrg/LinkStack.git /app/
RUN git checkout ${VERSION}
RUN rm /app/composer.lock
RUN sed -i "/\"php artisan lang:update\",/d; s|\"echo.> storage/app/ISINSTALLED\"|\"echo '.' > storage/app/ISINSTALLED\"|g" /app/composer.json

RUN chown -R www-data:www-data /app \
    && chmod -R 775 /app/storage \
    && chmod -R 775 /app/bootstrap/cache
## many dependencies on composer.lock are marked as MALWARE ...?

# install php and node.js dependencies
RUN composer install --no-dev --prefer-dist \
    && npm install 

RUN chown -R www-data:www-data /app/vendor \
    && chmod -R 775 /app/vendor

# stage 2: production stage
FROM php:8.3-fpm-alpine

# install nginx
RUN apk add --no-cache \
    zip \
    libzip-dev \
    freetype \
    libjpeg-turbo \
    libpng \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    oniguruma-dev \
    gettext-dev \
    freetype-dev \
    nginx \
    && docker-php-ext-configure zip \
    && docker-php-ext-install zip pdo pdo_mysql \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-enable gd \
    && docker-php-ext-install bcmath \
    && docker-php-ext-enable bcmath \
    && docker-php-ext-install exif \
    && docker-php-ext-enable exif \
    && docker-php-ext-install gettext \
    && docker-php-ext-enable gettext \
    && docker-php-ext-install opcache \
    && docker-php-ext-enable opcache \
    && rm -rf /var/cache/apk/*

# copy files from the build stage
COPY --from=build /app /app
COPY ./deploy/nginx.conf /etc/nginx/http.d/default.conf
COPY ./deploy/php.ini "$PHP_INI_DIR/conf.d/app.ini"

COPY .env /app/.env

RUN chown www-data:www-data /app/.env

WORKDIR /app

# add all folders where files are being stored that require persistence. if needed, otherwise remove this line.
# VOLUME ["/var/www/html/storage/app"]

CMD ["sh", "-c", "nginx && php-fpm"]