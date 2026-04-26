#!/usr/bin/env bash

# ---------------------------------------------------------------------
# 
# Copyright (C) 2026 @Sebastian Kinnewig
#
# This file is part of the Kanka CE toolchain.
# It is NOT part of the official Kanka project and is not affiliated
# with or endorsed by the Kanka developers.
#
# The code in this file is licensed under the GNU Lesser General
# Public License v2.1 (LGPL-2.1) as published by the Free Software
# Foundation.
#
# The full text of the license can be found in the file LICENSE.md.
#
# ---------------------------------------------------------------------

function generatePassword() {
    openssl rand -hex 16
}

if [ ! -e "$(dirname "$0")/.env" ]; then
    echo "$(dirname "$0")/.env does not exist!"
    exit 1
fi

DB_PASSWORD=$(generatePassword)
DB_ROOT_PASSWORD=$(generatePassword)
MEILISEARCH_KEY=$(generatePassword)
MINIO_PASSWORD=$(generatePassword)
REVERB_APP_SECRET=$(generatePassword)

sed -i.bak \
    -e "s#DB_PASSWORD=.*#DB_PASSWORD=${DB_PASSWORD}#g" \
    -e "s#DB_ROOT_PASSWORD=.*#DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD}#g" \
    -e "s#MEILISEARCH_KEY=.*#MEILISEARCH_KEY=${MEILISEARCH_KEY}#g" \
    -e "s#MINIO_PASSWORD=.*#MINIO_PASSWORD=${MINIO_PASSWORD}#g" \
    -e "s#REVERB_APP_SECRET=.*#REVERB_APP_SECRET=${REVERB_APP_SECRET}#g" \
    "$(dirname "$0")/.env"

