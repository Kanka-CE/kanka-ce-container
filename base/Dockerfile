###############################################
# 1) BUILD STAGE
###############################################
FROM quay.io/rockylinux/rockylinux:10-minimal AS build

RUN microdnf install -y \
    dnf git tar gzip which findutils curl \
    && microdnf clean all

# Enable Remi PHP 8.4
RUN dnf install -y https://rpms.remirepo.net/enterprise/remi-release-10.rpm \
    && dnf module reset -y php \
    && dnf module enable -y php:remi-8.4

# Install PHP + build deps
RUN dnf install -y \
    php php-cli php-mbstring php-xml php-zip php-bcmath \
    php-intl php-gd php-pdo php-mysqlnd php-opcache php-pecl-redis \
    unzip 

# Install Node.js
RUN dnf install -y nodejs npm 

# DNF Clean up
RUN dnf clean all

WORKDIR /app

# Copy composer files
COPY Kanka-CE/composer.json Kanka-CE/composer.lock ./

# Copy Kanka-CE itself
COPY Kanka-CE .

# Remove folder not required by the container
RUN rm -rf   \
    .claude  \
    .git     \
    .github  \
    .mariadb \
    .nginx   \
    docker   \
    docs     \
    public/vendor/fontawesome

# Remove files not required by the container
RUN rm -f \
    .dockerignore      \
    .editorconfig      \
    .env.example       \
    .env.testing       \
    .gitattributes     \
    .gitignore         \
    .jshintrc          \
    boost.json         \
    CLAUDE.md          \
    CODE_OF_CONDUCT.md \
    docker-compose.yml \
    README.md          


# Install the Composer
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin --filename=composer

# Install PHP deps
RUN composer install --no-dev --optimize-autoloader --no-interaction \
    && composer clear-cache

# Build frontend assets
RUN npm install --legacy-peer-deps \
    && npm run build \
    && rm -rf node_modules


###############################################
# 2) RUNTIME STAGE
###############################################
FROM rockylinux:10-minimal AS runtime

# Install nginx
RUN microdnf install -y dnf nginx && microdnf clean all

# Install php-fpm
RUN dnf install -y https://rpms.remirepo.net/enterprise/remi-release-10.rpm \
    && dnf module reset -y php \
    && dnf module enable -y php:remi-8.4 \
    && dnf install -y \
        php php-cli php-fpm php-mbstring php-xml php-zip php-bcmath \
        php-intl php-gd php-pdo php-mysqlnd php-opcache php-pecl-redis \
        php-json php-curl php-fileinfo

# Install mariadb
RUN dnf install -y mariadb

RUN mkdir -p /run/php-fpm && chown -R nginx:nginx /run/php-fpm

WORKDIR /var/www/html

COPY --from=build /app /var/www/html

# Clean up
RUN dnf clean all \
    && rm -rf /var/cache/dnf /var/cache/yum

# Remove unused files (i.e. docs, manpages, locales)
RUN rm -rf /usr/share/man/* /usr/share/doc/* /usr/share/info/* /usr/share/locale/*

# Remove node modules
RUN rm -rf node_modules

RUN chown -R nginx:nginx storage bootstrap/cache

# Copy configs
COPY ./deploy/nginx.conf /etc/nginx/nginx.conf
COPY ./deploy/php-fpm.conf /etc/php-fpm.d/www.conf

# Create the entry point
COPY ./deploy/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80
