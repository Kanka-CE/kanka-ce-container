#!/bin/bash
set -e

mkdir -p data/{kanka,mariadb}

# Test 1: Container starts
docker compose up -d

# Test 2: Required processes running
podman exec kanka_ce pgrep nginx
podman exec kanka_ce pgrep php-fpm

# Test 3: Kanka CE is reachable
curl -f http://localhost:8081
curl -f http://localhost:8081/login

# Test 4: storage is writable:
podman exec kanka_ce touch /var/www/storage/testfile

# Test 5: Environment variables
# This test, if the environment variables are respected.
# As an easy example we are looking at the timezone here.
TZ_VALUE=$(podman exec kanka_ce printenv TZ)

if [ "$TZ_VALUE" != "Europe/Berlin" ]; then
    echo "Expected Europe/Berlin but got $TZ_VALUE"
    exit 1
fi

# Test 6: PID/UID
podman exec kanka_ce id
