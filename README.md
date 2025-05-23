# WiFiToggler

**WiFiToggler.ahk** is a lightweight AutoHotkey v2 script that toggles your Wi-Fi adapter between two networks — perfect for setups with both an ISP router and a VPN router. It handles network switching, IP configuration (static or dynamic), and updates the system tray icon to reflect the active connection.

I originally created this script to quickly switch between two Wi-Fi networks that each required different static IP settings. It’s ideal for anyone with a media center, HTPC, or split-network configuration where convenience and speed matter.

---

## 🚀 Features

- Toggles between two specified Wi-Fi SSIDs
- Applies custom static IP, gateway, and DNS settings for each
- Supports DHCP fallback/customization
- Custom tray icons for each network
- Optional keyboard shortcut (`Ctrl+Alt+W`)

---

## 🔧 Configuration

Open the script and edit the `CONFIG` section at the top:

```autohotkey
SSID_ISP := "MyWiFi_5G"
SSID_VPN := "Linksys04892-5GHz"

IP_ISP    := "192.168.0.100"
GW_ISP    := "192.168.0.1"
DNS_ISP   := "192.168.0.1"

IP_VPN    := "192.168.50.100"
GW_VPN    := "192.168.50.1"
DNS_VPN   := "192.168.50.1"

SecondaryDNS := "8.8.4.4"

IconISP := A_ScriptDir "\WiFi_ISP.ico"
IconVPN := A_ScriptDir "\WiFi_VPN.ico"
```

If both of your Wi-Fi networks use **automatic (DHCP) IP settings**, comment out the static IP settings of `CONFIG` section and modify the `ApplyStaticIP()` function like so:

```autohotkey
ApplyStaticIP(ip, gateway, dns) {
    RunWait(Format('netsh interface ipv4 set address name="{}" dhcp', AdapterName), , "Hide")
    RunWait(Format('netsh interface ipv4 set dns name="{}" dhcp', AdapterName), , "Hide")
}
```

If only **one network** (e.g., VPN) requires a static IP and the other is DHCP:
- Leave the static config for one network as-is.
- For the DHCP network, use conditional logic in `ToggleWiFi()` to call a separate `ApplyDHCP()` function, or modify `ApplyStaticIP()` to handle both cases dynamically.

Example modification:
```autohotkey
if (targetSSID = SSID_ISP)
    ApplyDHCP()
else
    ApplyStaticIP(targetIP, targetGW, targetDNS)
```

---

## ⌨️ Hotkey

Press `Ctrl+Alt+W` to toggle manually. You can change this line to suit your preference:

```autohotkey
^!w::ToggleWiFi()  ; Ctrl + Alt + W
```

---

## 🧠 Need Ethernet Switching Instead?

Check out my companion script: **[AdapterToggler](https://github.com/MilkyTech/AdapterToggler)**

It lets you toggle between two network adapters (e.g., Ethernet and Wi-Fi)

---

## 📎 Requirements

- Windows 10 or 11
- [AutoHotkey v2](https://www.autohotkey.com/) (or pre-compiled WiFiToggler.exe included for convenience)
- Administrator privileges (required for changing IP settings)

---

## 💬 Final Notes

-Even when compiled, Windows may still flash a phantom console window like it’s trying to haunt you with legacy GUI vibes. It’s harmless, but annoying. We suppress it where we can, but some flickers persist.
-This script is tailored for those who live on the edge — jumping between networks, testing VPN routes, or just wanting faster control over their Wi-Fi behavior without digging through Windows settings.
-Use it, tweak it, break it, fix it — and if it helps you out, that’s a win in my book. 😎

---

## Support

- If you encounter any issues or have suggestions for improvements, please open an issue. We appreciate your feedback and are always looking to improve the tool.

---

## 🔐 Disclaimer

Use responsibly. This script modifies your network settings, so make sure you understand what you're changing — especially if you’re deploying it on critical machines or media servers.
