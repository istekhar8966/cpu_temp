# DWMBlocks Network Status Script

A **network status module** for [dwmblocks](https://github.com/torrinfail/dwmblocks) built using **Bash** and **NetworkManager**.  
It displays your current network state (Ethernet/WiFi/VPN) directly in the dwm status bar with useful icons.

---

## ✨ Features
- Detects whether **NetworkManager** is running.
- Shows:
  - **Disconnected** status if no network is active.
  - **Ethernet** connection with (masked) IP address.
  - **WiFi** connection with SSID and signal strength.
  - **VPN** active indicator (optional).
- Uses **nerd-font icons** for a clean and modern look.
- Masked IP for privacy when sharing screenshots or configs online.

---

## 📸 Example Output
- Ethernet with IP:  
  `󰈀 192.168.208.*`  
- WiFi with SSID and signal:  
  `󰤨 MyHomeWiFi (85%)`  
- Disconnected:  
  `󰤮 Disconnected`  
- VPN active:  
  `󰈀 192.168.208.* 󰒃`

---

## ⚙️ Requirements
- **dwmblocks** installed and configured.
- **NetworkManager** (`nmcli`) enabled.
- A nerd font patched font (for icons).

---

## 🚀 Installation
1. Save the script (e.g., `network.sh`) in your scripts folder,  
   e.g. `~/.config/scripts/network.sh`
2. Make it executable:
   ```bash
   chmod +x ~/.config/scripts/network.sh

