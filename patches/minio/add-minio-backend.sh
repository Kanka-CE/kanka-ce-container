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

# ++============================================================++
# ||                         Premilaris                         ||
# ++============================================================++
set -e

TOOLS_ROOT="$1"
KANKA_ROOT_DIR="$2"

source "$TOOLS_ROOT/core/lib.sh"



# ++============================================================++
# ||                      ADD MINIO FILESYSTEM                  ||
# ++============================================================++
add_minio_filesystem(){

MINIO_BLOCK="$(cat <<'EOF'

        /**
         * Added by Kanka-CE-Tools: MinIO backend
         * This can be used for selfhosting.
         */
        "minio" => [
            "driver" => "s3",
            "key" => env("MINIO_ACCESS_KEY_ID"),
            "secret" => env("MINIO_PASSWORD"),
            "region" => "local",
            "bucket" => env("MINIO_BUCKET"),
            "root" => env("APP_ENV") != "production" ? env("APP_ENV") : null,
            "visibility" => "public",
            "url" => env("MINIO_URL") . ':' . env("MINIO_PORT") . '/' . env("MINIO_BUCKET"),
            "endpoint" => env("MINIO_URL") . ':' . env("MINIO_PORT"),
            "use_path_style_endpoint" => env(true),
        ],
EOF
)"

TMP="${FILESYSTEM_CONFIG}.tmp"

awk -v block="$MINIO_BLOCK" '
    BEGIN {
        in_disks = 0
        depth = 0
    }

    {
        line = $0

        # Detect start of disks array
        if (!in_disks &&
            index(line, "\"disks\"") > 0 &&
            index(line, "=>") > 0 &&
            index(line, "[") > 0) {

            in_disks = 1
            depth = 1
            print line
            next
        }

        if (in_disks) {
            # Count brackets
            tmp = line
            gsub(/[^[]/, "", tmp)
            opens = length(tmp)

            tmp = line
            gsub(/[^\]]/, "", tmp)
            closes = length(tmp)

            depth += opens - closes

            # If depth returns to 0, this is the closing bracket of "disks"
            if (depth == 0) {
                print block
                print line
                in_disks = 0
                next
            }
        }

        print line
    }
' "$FILESYSTEM_CONFIG" > "$TMP"

mv "$TMP" "$FILESYSTEM_CONFIG"

}



# ++============================================================++
# ||                    The actual program                      ||
# ++============================================================++
FILESYSTEM_CONFIG="$KANKA_ROOT_DIR/config/filesystems.php"

if [[ ! -f "$FILESYSTEM_CONFIG" ]]; then
    echo "Error: file not found: $FILESYSTEM_CONFIG" 1
fi

if grep -q '"minio"' "$FILESYSTEM_CONFIG"; then
    cecho ${GOOD} "MinIO disk already exists."
else
  if ! add_minio_filesystem "$@"; then
    exit 1
  fi
fi

