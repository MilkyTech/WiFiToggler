#Requires AutoHotkey v2.0
#SingleInstance Force

; === CONFIG ===

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

; === Global Adapter Name ===

Global AdapterName := GetWiFiAdapterName()

; === Tray Setup ===

A_IconTip := "WiFi Toggler"
A_TrayMenu.Delete()
A_TrayMenu.Add("Toggle WiFi", (*) => ToggleWiFi())
A_TrayMenu.Add()
A_TrayMenu.Add("Exit", (*) => ExitApp())
UpdateTrayIcon()
OnMessage(0x404, TrayClickHandler)

TrayClickHandler(wParam, lParam, *) {
    if (lParam = 0x202)  ; WM_LBUTTONUP
        ToggleWiFi()
}

; === Manual Hotkey ===

^!w::ToggleWiFi()  ; Ctrl + Alt + W

ToggleWiFi() {
    ssid := GetCurrentSSID()
    if (ssid = SSID_VPN) {
        targetSSID := SSID_ISP
        targetIP   := IP_ISP
        targetGW   := GW_ISP
        targetDNS  := DNS_ISP
    } else if (ssid = SSID_ISP) {
        targetSSID := SSID_VPN
        targetIP   := IP_VPN
        targetGW   := GW_VPN
        targetDNS  := DNS_VPN
    } else {
        TrayTip("WiFiToggler", "❌ Not connected to known network.", 2)
        return
    }

    if (ssid = targetSSID) {
        TrayTip("WiFiToggler", "✅ Already connected to " targetSSID, 2)
        return
    }

    RunQuiet("netsh wlan disconnect")
    Sleep(1000)

    success := ConnectToSSID(targetSSID)
    if !success {
        TrayTip("WiFiToggler", "❌ Failed to connect to " targetSSID, 2)
        return
    }

    ApplyStaticIP(targetIP, targetGW, targetDNS)
    UpdateTrayIcon()
    TrayTip("WiFiToggler", (targetSSID = SSID_VPN ? "🚀 VPN Protected" : "📶 ISP Online") "`nConnected to: " targetSSID, 2)
}

GetCurrentSSID() {
    output := RunQuiet("netsh wlan show interfaces")
    for line in StrSplit(output, "`n") {
        if line ~= "^\s*SSID\s*:" {
            rawSSID := StrSplit(line, ":")[2]
            return Trim(RegExReplace(rawSSID, "[^\x21-\x7E]"))  ; Printable only
        }
    }
    return ""
}

ConnectToSSID(ssid, retries := 2) {
    Loop retries + 1 {
        RunWait('netsh wlan connect name="' ssid '"', , "Hide")
        Sleep(3000)
        if (Trim(GetCurrentSSID()) = ssid)
            return true
    }
    return false
}

ApplyStaticIP(ip, gateway, dns) {
    try {
        RunWait(Format(
            'netsh interface ipv4 set address name="{}" static {} {} {}',
            AdapterName, ip, "255.255.255.0", gateway
        ), , "Hide")

        RunWait(Format(
            'netsh interface ipv4 set dns name="{}" static {}',
            AdapterName, dns
        ), , "Hide")

        RunWait(Format(
            'netsh interface ipv4 add dns name="{}" {} index=2',
            AdapterName, SecondaryDNS
        ), , "Hide")
    } catch as err {
        TrayTip("WiFiToggler", "❌ Failed to apply static IP:`n" err.Message, 3)
    }
}

GetWiFiAdapterName() {
    output := RunQuiet("netsh wlan show interfaces")
    for line in StrSplit(output, "`n") {
        if line ~= "^\s*Name\s*:" {
            return Trim(StrSplit(line, ":")[2], " `t`r`n")
        }
    }
    return ""
}

RunQuiet(cmd) {
    shell := ComObject("WScript.Shell")
    exec := shell.Exec(A_ComSpec " /c " cmd)
    return exec.StdOut.ReadAll()
}

UpdateTrayIcon() {
    ssid := GetCurrentSSID()
    if ssid = SSID_VPN
        A_IconTip := "VPN Network: " ssid
    else if ssid = SSID_ISP
        A_IconTip := "ISP Network: " ssid
    else
        A_IconTip := "Disconnected or Unknown"
    TraySetIcon((ssid = SSID_VPN) ? IconVPN : IconISP)
}
