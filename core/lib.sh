#!/usr/bin/env bash

# ---------------------------------------------------------------------
#
# Copyright (C) 2026 @Sebastian Kinnewig
#
# The code is licensed under the GNU Lesser General Public License as
# published by the Free Software Foundation in version 2.1
# The full text of the license can be found in the file LICENSE.md
#
# ---------------------------------------------------------------------

# Colours for progress and error reporting
ERROR="\033[1;31m"
GOOD="\033[1;32m"
WARN="\033[1;35m"
INFO="\033[1;34m"
BOLD="\033[1m"

# Display messages in a specified colour
cecho() {
  COL=$1; shift
  echo -e "${COL}$@\033[0m"
}

# Error codes
E_OK=0
E_USAGE=1
E_UPSTREAM_NOT_FOUND=2
E_OUTPUT_WRITE_FAIL=3
E_PATCH_FAILED=4
E_RESOURCE_FAILED=5
E_STEP_FAILED=6
E_DEPENDENCY_MISSING=7

# Error handling
error() {
    local message="$1"
    local code="${2:-1}"

    cecho ${ERROR} "ERROR: $message" >&2
    exit "$code"
}

