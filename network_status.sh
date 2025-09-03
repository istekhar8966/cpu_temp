#!/usr/bin/env bash

# ─────────────────────────────────────────────────────────────
# Network status script for dwmblocks (using NetworkManager).
# Displays connection type (Ethernet/WiFi), signal strength,
# masked IP, and optional VPN indicator with Nerd Font icons.
# ─────────────────────────────────────────────────────────────

get_network_status() {
    # Ensure NetworkManager is running; otherwise show "NM Off"
    if ! systemctl is-active --quiet NetworkManager; then
        echo "󰤮 NM Off"
        return
    fi

    # Get the first active network connection (ethernet or wifi)
    ACTIVE_CONNECTION=$(nmcli -t -f TYPE,STATE,CONNECTION device \
        | grep -E "^(ethernet|wifi):connected:" | head -1)

    # If nothing is active, show "Disconnected"
    if [ -z "$ACTIVE_CONNECTION" ]; then
        echo "󰤮 Disconnected"
        return
    fi

    # Parse type (ethernet/wifi) and connection name (SSID/profile)
    CONNECTION_TYPE=$(echo "$ACTIVE_CONNECTION" | cut -d':' -f1)
    CONNECTION_NAME=$(echo "$ACTIVE_CONNECTION" | cut -d':' -f3)

    case "$CONNECTION_TYPE" in
        "ethernet")
            # ── Ethernet block ──────────────────────────────
            # Find first ethernet device
            ETH_DEV=$(nmcli -t -f DEVICE,TYPE device status \
                | awk -F: '$2=="ethernet"{print $1; exit}')

            # Extract IP address (v4 only, without subnet mask)
            IP_ADDR=$(nmcli -g IP4.ADDRESS device show "$ETH_DEV" \
                | head -1 | cut -d'/' -f1)

            if [ -n "$IP_ADDR" ]; then
                # Mask last octet for safe sharing (e.g. 192.168.1.*)
                SAFE_IP=$(echo "$IP_ADDR" | sed 's/\.[0-9]\{1,3\}$/.* /')
                echo "󰈀 $SAFE_IP"
            else
                echo "󰈀 Ethernet"
            fi
            ;;
        
        "wifi")
            # ── WiFi block ──────────────────────────────────
            # Try to fetch WiFi info for active SSID
            WIFI_INFO=$(nmcli -t -f SSID,SIGNAL,RATE,BARS device wifi \
                | grep "^$CONNECTION_NAME:" | head -1)

            if [ -z "$WIFI_INFO" ]; then
                # Fallback if SSID not found in scan results
                SSID=$(nmcli -g 802-11-wireless.ssid connection show "$CONNECTION_NAME" 2>/dev/null)
                SIGNAL=$(nmcli -f IN-USE,SIGNAL device wifi | grep '*' | awk '{print $2}')
            else
                SSID=$(echo "$WIFI_INFO" | cut -d':' -f1)
                SIGNAL=$(echo "$WIFI_INFO" | cut -d':' -f2)
            fi

            # Pick WiFi icon based on signal strength
            if [ -z "$SIGNAL" ]; then
                WIFI_ICON="󰤯"
            elif [ "$SIGNAL" -ge 80 ]; then
                WIFI_ICON="󰤨"
            elif [ "$SIGNAL" -ge 60 ]; then
                WIFI_ICON="󰤥"
            elif [ "$SIGNAL" -ge 40 ]; then
                WIFI_ICON="󰤢"
            elif [ "$SIGNAL" -ge 20 ]; then
                WIFI_ICON="󰤟"
            else
                WIFI_ICON="󰤯"
            fi

            # Show SSID + signal %
            if [ -n "$SSID" ] && [ -n "$SIGNAL" ]; then
                echo "$WIFI_ICON $SSID ($SIGNAL%)"
            elif [ -n "$SSID" ]; then
                echo "$WIFI_ICON $SSID"
            else
                echo "$WIFI_ICON Connected"
            fi
            ;;
        
        *)
            # ── Other connection types (fallback) ───────────
            echo "󰈀 Connected"
            ;;
    esac

    # ── VPN indicator ──────────────────────────────────────
    VPN_ACTIVE=$(nmcli -t -f TYPE,STATE connection show --active \
        | grep "vpn:activated" | head -1)
    if [ -n "$VPN_ACTIVE" ]; then
        echo -n " 󰒃"
    fi
}

# ── Main execution ─────────────────────────────────────────
get_network_status
