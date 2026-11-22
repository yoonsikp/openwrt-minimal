#!/bin/bash
#XDG_RUNTIME_DIR=/tmp/sway-$(id -u) WLR_NO_HARDWARE_CURSORS=1 sway &
#sleep 10
#XDG_RUNTIME_DIR=/tmp/sway-$(id -u) WAYLAND_DISPLAY=wayland-1 wayvnc --keyboard=us 0.0.0.0 -f 30

/root/init_seat.sh
/root/fast.sh
#echo "sway" | su - browser
echo "sway & sleep 10; WAYLAND_DISPLAY=wayland-1 wayvnc --keyboard=us 0.0.0.0 -f 1" | su - browser
