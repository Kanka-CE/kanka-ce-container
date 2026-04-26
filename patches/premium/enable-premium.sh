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
# ||                 REPLACE FUNCTION WITH TYPE                 ||
# ++============================================================++
# This is a helper function, that given:
#  - #1 a function name
#  - #2 a return type (bool or int)
#  - #3 a file path
# modifies the function in the provided file to either always return true (for bool) or
# always return 100 (for int).
replace_function_with_type() {
    local signature="$1"
    local return_type="$2"
    local file="$3"

    awk -v funcname="$signature" -v rettype="$return_type" '
    BEGIN {
        in_func = 0
        depth = 0
    }

    # Match the function declaration line
    $0 ~ "^[[:space:]]*public[[:space:]]+function[[:space:]]+" funcname"[[:space:]]*\\(" {
        in_func = 1
        depth = 0

        # store indentation
        match($0, /^([[:space:]]*)/, m)
        indent = m[1]

        # Determine return value based on type
        if (rettype == "bool") {
            ret = "true"
        } else if (rettype == "int") {
            ret = "100"
        } else {
            ret = "null"
        }

        # Write replacement function
        print indent "public function " funcname "(): " rettype " {"
        print indent "    return " ret ";"
        print indent "}"

        # Skip original declaration line
        next
    }

    # While inside the original function, skip its body based on brace depth
    in_func {
        # Count braces on this line
        # (good enough for PHP code without trying to parse strings/comments)
        n_open = gsub(/\{/, "{")
        n_close = gsub(/\}/, "}")
        depth += n_open
        depth -= n_close

        # When depth reaches 0, we’ve passed the closing brace of the function
        if (depth <= 0) {
            in_func = 0
        }

        next
    }

    # Everything else is printed unchanged
    {
        print
    }
    ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}



# ++============================================================++
# ||                    The actual program                      ||
# ++============================================================++
USER_PREMIUM_FILE="$KANKA_ROOT_DIR/app/Models/User.php"
bool_functions_to_replace=(
    isSubscriber
    isElemental
    hasManualSubscription
)
for signature in "${bool_functions_to_replace[@]}"; do
    if ! replace_function_with_type "$signature" "bool" "$USER_PREMIUM_FILE" "$@"; then
        exit 1
    fi
done

USER_BOOSTS_FILE="$KANKA_ROOT_DIR/app/Models/Concerns/UserBoosters.php"
int_functions_to_replace=(
    availableBoosts
    maxBoosts
)
for signature in "${int_functions_to_replace[@]}"; do
    if ! replace_function_with_type "$signature" "int" "$USER_BOOSTS_FILE" "$@"; then
        exit 1
    fi
done
