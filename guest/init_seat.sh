root@jellyfin:~# cat init_seat.sh 
#!/bin/bash

mkdir -p /run/udev/data

cat <<EOF > /run/udev/data/c13:66
E:ID_INPUT=1
I:123456789
E:ID_INPUT_KEYBOARD=1
E:ID_SERIAL=openwrt_at_keyboard
E:ID_SEAT=seat0
G:seat
TAGS=:seat:
EOF

cat <<EOF > /run/udev/data/c13:67
E:ID_INPUT=1
I:123456788
E:ID_SERIAL=openwrt_mouse
E:ID_INPUT_TOUCHPAD=1
E:ID_SEAT=seat0
G:seat
TAGS=:seat:
EOF

cat <<EOF > /run/udev/data/c226:0
I:99999999
E:ID_SEAT=seat0
E:ID_FOR_SEAT=drm-pci-0000_00_02_0
G:seat:master-of-seat:uaccess:
TAGS=:seat:master-of-seat:uaccess:
EOF

mkdir -p /run/udev/tags/seat

ln -sf /run/udev/data/c13:66 /run/udev/tags/seat/c13:66
ln -sf /run/udev/data/c13:67 /run/udev/tags/seat/c13:67
ln -sf /run/udev/data/c226:0 /run/udev/tags/seat/c226:0

mkdir -p /run/udev/tags/master-of-seat

ln -sf /run/udev/data/c226:0 /run/udev/tags/master-of-seat/c226:0


#cat <<EOF > /run/udev/data/c13:71
#E:ID_INPUT=1
#E:ID_INPUT_KEYBOARD=1
#E:ID_SERIAL=trackpoint
#EOF
