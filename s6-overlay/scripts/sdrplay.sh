#!/command/with-contenv bash
#shellcheck shell=bash

#shellcheck disable=SC1091
source /scripts/common

SCRIPT_NAME="$(basename "$0")"
SCRIPT_NAME="${SCRIPT_NAME%.*}"

# shellcheck disable=SC2034
s6wrap=(s6wrap --quiet --timestamps --prepend="$SCRIPT_NAME" --args)

#shellcheck disable=SC2154
"${s6wrap[@]}" /usr/bin/sdrplay_apiService

# Define the string to monitor
TARGET_STRING="sdrplay_apiServ\[[:digit:]]\+: segfault at"

# File to store processed lines
LOG_FILE="/tmp/processed_lines.log"

# Create the log file if it doesn't exist
touch "$LOG_FILE"

# Monitor dmesg output continuously
dmesg --follow | while read -r line
do
    # Check if the line matches the target pattern
    if echo "$line" | grep -Eq "$TARGET_STRING"; then
        # Check if the line has already been processed
        if ! grep -Fxq "$line" "$LOG_FILE"; then
            # Log the line to the processed lines file
            echo "$line" >> "$LOG_FILE"

            # Do sometthing
            echo "Segfault found, restarting API"
            s6-svc -r /var/run/sdrplay
        fi
    fi
done
