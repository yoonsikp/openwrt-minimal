#!/bin/sh

BAT_PATH="/sys/class/power_supply/BAT0/capacity"
PREV=""

while true
do
    if [ -f "$BAT_PATH" ]; then
        CURRENT="$(cat "$BAT_PATH")"

        # Ensure numeric value
        case "$CURRENT" in
            ''|*[!0-9]*)
                sleep 60
                continue
            ;;
        esac

        if [ -n "$PREV" ]; then
            if [ "$PREV" -gt 10 ] && [ "$CURRENT" -le 10 ]; then
                logger "Battery dropped from $PREV% to $CURRENT%. Powering off."
                poweroff
                exit 0
            fi
        fi

        PREV="$CURRENT"
    else
        logger "Battery path not found!"
        exit 1
    fi

    sleep 60
done
