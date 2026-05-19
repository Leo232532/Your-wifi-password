#!/bin/bash

# 1. Ask the user to input the IP address
read -p "Enter the target IP address: " TARGET_IP

# 2. Find the interface name matching that IP
INTERFACE=$(ip -o addr show | grep "$TARGET_IP" | awk '{print $2}')

if [ -z "$INTERFACE" ]; then
    echo "Error: No active network interface found with the IP $TARGET_IP."
    exit 1
fi

# 3. Get the Connection Name from NetworkManager history (works offline)
NETWORK_NAME=$(nmcli -t -f GENERAL.CONNECTION device show "$INTERFACE" | cut -d: -f2)

if [ -z "$NETWORK_NAME" ] || [ "$NETWORK_NAME" == "--" ]; then
    echo "Error: The interface $INTERFACE is not currently tied to a saved network profile."
    exit 1
fi

echo "Found Network Profile: $NETWORK_NAME"
echo "Retrieving saved password from local storage..."
echo "----------------------------------------"

# 4. Read the password from local configuration files (Requires sudo/root privileges)
if [ -f "/etc/NetworkManager/system-connections/$NETWORK_NAME.nmconnection" ]; then
    sudo grep -i "psk=" "/etc/NetworkManager/system-connections/$NETWORK_NAME.nmconnection"
elif [ -f "/etc/NetworkManager/system-connections/$NETWORK_NAME" ]; then
    sudo grep -i "psk=" "/etc/NetworkManager/system-connections/$NETWORK_NAME"
else
    # Fallback to nmcli if configuration files are hidden
    sudo nmcli -s connection show "$NETWORK_NAME" | grep -i "psk"
fi
