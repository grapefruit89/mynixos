---
title: IOT & Zigbee SLZB-06 Provisioning Report
project: NMS v2.3
last_updated: 2026-03-02
status: Active Standard
type: Provisioning Report
---

# 🐝 IOT & ZIGBEE PROVISIONING

Dieses Dokument beschreibt die Anbindung des SLZB-06 Ethernet Zigbee-Koordinators an den NixOS-Stack.

## 📡 Netzwerk-Discovery
Im Rahmen des Rollouts am 02. März wurde ein Netzwerk-Scan durchgeführt, um den Status des Zigbee-Koordinators zu verifizieren.

**Scan-Ergebnis (`nmap`):**
*   **IP**: `192.168.2.46`
*   **Offener Port**: `6638` (Zigbee-to-TCP Bridge)
*   **Status**: Online & erreichbar.

## 🛠️ Konfigurations-Update
Die SSoT-Variable in `00-core/configs.nix` wurde von der veralteten IP (`.200`) auf den neuen Wert korrigiert:
```nix
hardware.zigbeeStickIP = "192.168.2.46";
```

## 🚀 Zigbee2MQTT Migration (`ember` Treiber)
Die Logs von Zigbee2MQTT deuteten darauf hin, dass der alte `ezsp` Treiber (EmberZNet Serial Protocol) veraltet ist. Das System wurde erfolgreich auf den modernen **`ember`** Treiber umgestellt.

**Vorteile der Umstellung:**
1.  **Stabilität**: Bessere Unterstützung für TCP-basierte Koordinatoren wie den SLZB-06.
2.  **Performance**: Geringerer Overhead bei der Befehlsübertragung.
3.  **Zukunftssicherheit**: Der `ezsp` Treiber wird in künftigen Z2M-Versionen entfernt.

## 🔗 MQTT-Integration
Der lokale Mosquitto-Broker (`port 1883`) dient als Hub für alle Zigbee-Events. Die Integration in Home Assistant erfolgt automatisch über die aktivierte `homeassistant = true` Option im Zigbee-Stack.

---
*Status: PROVISIONED & STABLE*
