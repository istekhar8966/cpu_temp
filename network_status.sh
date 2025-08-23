#!/bin/bash

# Network status script for dwmblocks using NetworkManager

get_network_status() {
    # Check if NetworkManager is running
    if ! systemctl is-active --quiet NetworkManager; then
        echo "󰤮 NM Off"
        return
    fi

    # Get active connection info
    ACTIVE_CONNECTION=$(nmcli -t -f TYPE,STATE,CONNECTION device | grep -E "^(ethernet|wifi):connected:" | head -1)
    
    if [ -z "$ACTIVE_CONNECTION" ]; then
        # No active connection
        echo "󰤮 Disconnected"
        return
    fi

    # Parse connection type
    CONNECTION_TYPE=$(echo "$ACTIVE_CONNECTION" | cut -d':' -f1)
    CONNECTION_NAME=$(echo "$ACTIVE_CONNECTION" | cut -d':' -f3)

    case "$CONNECTION_TYPE" in
        "ethernet")
            # Ethernet connection
            IP_ADDR=$(nmcli -g IP4.ADDRESS device show | head -1 | cut -d'/' -f1)
            if [ -n "$IP_ADDR" ]; then
                echo "󰈀 $IP_ADDR"
            else
                echo "󰈀 Ethernet"
            fi
            ;;
        
        "wifi")
            # WiFi connection
            # Get WiFi details
            WIFI_INFO=$(nmcli -t -f SSID,SIGNAL,RATE,BARS device wifi | grep "^$CONNECTION_NAME:" | head -1)
            
            if [ -z "$WIFI_INFO" ]; then
                # Fallback method if SSID match fails
                SSID=$(nmcli -g 802-11-wireless.ssid connection show "$CONNECTION_NAME" 2>/dev/null)
                SIGNAL=$(nmcli -f IN-USE,SIGNAL device wifi | grep '*' | awk '{print \$2}')
            else
                SSID=$(echo "$WIFI_INFO" | cut -d':' -f1)
                SIGNAL=$(echo "$WIFI_INFO" | cut -d':' -f2)
            fi

            # Determine WiFi icon based on signal strength
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

            # Get IP address
            IP_ADDR=$(nmcli -g IP4.ADDRESS device show | head -1 | cut -d'/' -f1)
            
            # Format output
            if [ -n "$SSID" ] && [ -n "$SIGNAL" ]; then
                echo "$WIFI_ICON $SSID ($SIGNAL%)"
            elif [ -n "$SSID" ]; then
                echo "$WIFI_ICON $SSID"
            else
                echo "$WIFI_ICON Connected"
            fi
            ;;
        
        *)
            # Other connection types
            echo "󰈀 Connected"
            ;;
    esac

    # Check for VPN (optional)
    VPN_ACTIVE=$(nmcli -t -f TYPE,STATE connection show --active | grep "vpn:activated" | head -1)
    if [ -n "$VPN_ACTIVE" ]; then
        echo -n " 󰒃"
    fi
}

# Main execution
get_network_status
