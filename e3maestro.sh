#!/bin/sh
# PACKAGES: luci kmod-usb-net-qmi-wwan kmod-usb-serial-option luci-proto-mbim picocom luci-proto-qmi kmod-rtw88 kmod-rtw88-8723du hostapd-wolfssl

## Switch to QMI
# ssh root@192.168.1.1
# picocom /dev/ttyUSB3
# AT+QCFG="usbnet",0

## Force Roaming
# ssh root@192.168.1.1
# picocom /dev/ttyUSB3
# AT+QCFG="roamservice",2,1

# log potential errors
exec >/tmp/setup.log 2>&1

# WiFi Settings
SSID="WiFiFreedom😎"
WIFI_PASS="my_password"

# Modem Settings
APN="ltedata.apn"

# Uncomment to set a root password
# ROOT_PASS="root_pass"

if [ -n "${ROOT_PASS}" ]; then
  (echo "${ROOT_PASS}"; sleep 1; echo "${ROOT_PASS}") | passwd > /dev/null
fi

for RADIO in 'radio0' 'radio1'
do
    # Radio doesn't exist.
    uci -q get wireless."${RADIO}" || continue

    # Set fixed channel
    BAND="$(uci -q get wireless."${RADIO}".band)"
    if [ "${BAND}" = "2g" ]; then
        uci set wireless."${RADIO}".channel=6
    fi
    if [ "${BAND}" = "5g" ]; then
        uci set wireless."${RADIO}".channel=36
    fi

    # Set country
    uci set wireless."${RADIO}".country="CA"

    # Enable radio
    uci set wireless."${RADIO}".disabled="0"

    # Set SSID and password
    uci set wireless.default_"${RADIO}".ssid="${SSID}"
    uci set wireless.default_"${RADIO}".encryption="psk2+ccmp"
    uci set wireless.default_"${RADIO}".key="${WIFI_PASS}"
    uci set wireless.default_"${RADIO}".short_preamble='0'
    uci commit wireless
done

# Set up the QMI Interface
uci set network.WWAN=interface
uci set network.WWAN.proto='qmi'
uci set network.WWAN.device='/dev/cdc-wdm0'
uci set network.WWAN.apn="${APN}"
uci set network.WWAN.auth='none'
# For IPv6 only change to 'ipv6'
uci set network.WWAN.pdptype='ip'
uci set network.WWAN.delay='30'

# Use multiple CPUs for receiving packets
uci set network.globals.packet_steering='1'

# Commit Networking Settings
uci commit network

# Enable fast network flows in the kernel
uci set firewall.@defaults[0].flow_offloading='1'

# Add WWAN to the WAN firewall group
uci add_list firewall.@zone[1].network='WWAN'

# Commit Firewall Settings
uci commit firewall

service firewall restart
service network restart

# Decrease power usage ('0' to fully shut off screen)
cat << 'EOF' > /
#!/bin/bash

echo 1 > /sys/class/backlight/intel_backlight/brightness
EOF

