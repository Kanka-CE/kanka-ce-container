#!/usr/bin/env bash
set -e

FLAG_FILE="/var/www/html/storage/installed.flag"
ENV_FILE="/var/www/html/.env"


wait_for_db() {
    echo ">>> Waiting for database connection..."

    DB_HOST="${DB_HOST:-mysql}"
    DB_PORT="${DB_PORT:-3306}"
    DB_USERNAME="${DB_USERNAME:-kanka}"
    DB_PASSWORD="${DB_PASSWORD:-}"
    DB_DATABASE="${DB_DATABASE:-kanka}"

    while ! mariadb -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USERNAME" -p"$DB_PASSWORD" "$DB_DATABASE" \
            -e "SELECT 1" >/dev/null 2>&1
    do
        echo "   Database not ready yet..."
        sleep 5
    done

    echo ">>> Database is reachable"
}


# Ensure .env exists
if [ ! -f ".env" ]; then
    echo "The configuration file is missing (.env)."
    exit 1
else
    source "$ENV_FILE"
fi


if [ ! -f "$FLAG_FILE" ]; then
    wait_for_db
    echo ">>> Running initial Kanka CE installation"
    php artisan kanka:install
    touch "$FLAG_FILE"
    echo ">>> Installation complete"
fi

# directly run php-fpm
sh -c "php-fpm -D && nginx -g 'daemon off;'"

