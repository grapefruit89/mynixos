# 🏁 SRE Audit Report: Wake-on-Access & Unraid Domain Restoration (2026-03-02)

## 📋 Zusammenfassung
Implementierung von "Wake-on-Access" (Systemd Socket Activation) für ressourcenintensive oder selten genutzte NixOS-Dienste. Vollständige Wiederherstellung der Unraid-Domains auf den Haupt-Namespace (`m7c5.de`).

## 🛠️ Durchgeführte Änderungen

### 1. Wake-on-Access (Socket Activation)
Folgende Dienste wurden so konfiguriert, dass sie im RAM "schlafen" und erst beim ersten Netzwerkzugriff automatisch von systemd gestartet werden:
- **Vaultwarden**: Socket auf Port 20002.
- **OliveTin**: Socket auf Port 10082.
- **Miniflux**: Nutzt natives Miniflux-Socket-Activation-Feature (`fd://3`).
- **Paperless-ngx**: Web-Interface (Port 20981) wird nun via Socket geweckt.

### 2. Unraid Domain Restoration (Chef-Status)
- **Traefik**: Alle Host-Regeln auf Unraid wurden von `.nix.m7c5.de` zurück auf `.m7c5.de` migriert.
- **Homepage**: Alle Links im Unraid-Dashboard wurden verifiziert und auf die Hauptdomain zurückgesetzt.
- **Isolierung**: Nur NixOS-Dienste nutzen ab sofort den Sicherheits-Puffer `*.nix.m7c5.de`.

### 3. Pocket-ID Access
- **Status**: `public_registration` ist weiterhin auf `true` gesetzt (temporär), um die Ersteinrichtung des Admin-Accounts zu ermöglichen.

## 🧬 Traceability
- **Skill**: Ultra-SRE v2.4
- **Compliance**: NMS v2.3 SRE Standard
- **Status**: Resource Efficiency OPTIMIZED.

---
*Status: IMPLEMENTED & VERIFIED*
