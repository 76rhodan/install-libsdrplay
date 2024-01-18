#!/command/with-contenv bash
#shellcheck shell=bash

#shellcheck disable=SC1091
source /scripts/common

SCRIPT_NAME="$(basename "$0")"
SCRIPT_NAME="${SCRIPT_NAME%.*}"

# shellcheck disable=SC2034
s6wrap=(s6wrap --quiet --timestamps --prepend="$SCRIPT_NAME" --args)

#shellcheck disable=SC2154
if pgrep -x "sdrplay_apiService" > /dev/null
then
    echo "sdrplay api already running"
    exit 0
else
    echo "starting sdrplay api"
    "${s6wrap[@]}" /usr/bin/sdrplay_apiService
fi
