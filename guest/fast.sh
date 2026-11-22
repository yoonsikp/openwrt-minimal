#!/bin/bash

# Ensure the directory exists
mkdir -p /run/udev/data

for dev in /sys/class/input/event*; do
    # Get major:minor numbers (e.g., 13:64)
    DEV_NUM=$(cat "$dev/dev")
    NAME=$(cat "$dev/device/name")
    
    # Skip known non-input devices (like HDMI audio)
    if [[ "$NAME" == *"HDMI/DP"* ]] || [[ "$NAME" == *"HDA Intel"* ]]; then
        continue
    fi

    # Initialize properties
    PROPS="E:ID_INPUT=1\nE:ID_SEAT=seat0"

    # Precise Logic:
    # 4. Check for Keyboard (Key capabilities)
    # 1. Check for Touchpad (specific name check + absolute axes)
    if [[ "$NAME" == *"Touchpad"* ]] || [[ "$NAME" == *"Synaptics"* ]]; then
        PROPS="$PROPS\nE:ID_INPUT_TOUCHPAD=1"
    

    elif [ -f "$dev/device/capabilities/key" ]; then
        PROPS="$PROPS\nE:ID_INPUT_KEYBOARD=1"


    # 2. Check for Mouse (relative axes)
    elif [ -f "$dev/device/capabilities/rel" ]; then
        PROPS="$PROPS\nE:ID_INPUT_MOUSE=1"

    # 3. Check for Touchscreen (Absolute axes, but not named touchpad)
    elif [ -f "$dev/device/capabilities/abs" ]; then
        PROPS="$PROPS\nE:ID_INPUT_TOUCHSCREEN=1"
    fi



    # Create the udev database entry with lowercase 'i'
    # Filename format: i<major>:<minor>
    echo -e "$PROPS" > "/run/udev/data/c$DEV_NUM"

    echo "Spoofed udev entry: $NAME (c$DEV_NUM) updated."
done
