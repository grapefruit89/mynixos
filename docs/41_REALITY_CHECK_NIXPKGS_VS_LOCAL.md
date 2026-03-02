---
title: Reality Check: nixpkgs Patterns vs. Local Config
project: NMS v2.3
last_updated: 2026-03-02
status: Analysis Complete
type: Comparison Report
---

# 🕵️ REALITY CHECK: NIXPKGS VS. LOCAL CONFIG

In diesem Dokument gleichen wir deine "Gehversuche" mit den offiziellen Best-Practices aus dem NixOS-Repository ab. 

## 🎬 Jellyfin: Lokaler Stand vs. Profi-Liga

| Feature | Dein Stand | nixpkgs Standard | Bewertung |
|---|---|---|---|
| **Sandboxing** | `PrivateDevices`, `IPAddressAllow` | `ProtectProc`, `RestrictNamespaces`, `SystemCallFilter` | **Gut**, aber nixpkgs isoliert den Kernel noch stärker. |
| **GPU-Treiber** | `OCL_ICD_VENDORS = "intel"` | `vpl-gpu-rt` + `intel-media-driver` | **Lücke**: OneVPL (QSV) fehlt für modernste Codecs. |
| **Config-Integrität** | Manuell / Web-UI | Deklarative `encoding.xml` | **Geheimtipp**: nixpkgs erlaubt es, Transcoding-Settings in Nix zu fixieren. |

---

## 🛡️ Caddy: Der Edge-Proxy Check

Deine Caddy-Konfiguration ist durch die **Snippet-Architektur** (`security_headers`, `sso_auth`) bereits auf einem extrem hohen Niveau. 

**Was fehlt noch zum "Endgegner-Status"?**
- **QUIC/UDP Tuning**: nixpkgs setzt automatisch `net.core.rmem_max = 2500000`. Ohne diesen Kernel-Tweak kann HTTP/3 bei hoher Last instabil werden.
- **mTLS Integration**: Du nutzt bereits `tls internal` für LAN-Fallbacks – das ist exakt der empfohlene Weg für hybride Setups.

---

## 🔑 Vaultwarden & General Sandboxing

Hier bist du **über dem Standard** von vielen nixpkgs-Modulen! 
- Deine Nutzung von `MemoryDenyWriteExecute = true` und `SystemCallFilter = [ "@system-service" ... ]` für Vaultwarden ist vorbildlich und entspricht "Aviation Grade" Security.

---

## 🛠️ Optimierungspotenzial (Die nächsten Schritte)

1. **Service-Hardening-Upgrade**: Übernimm das Sandboxing-Paket (Gruppe 40) für Dienste wie `n8n` oder `paperless`, die oft weniger gehärtet ausgeliefert werden.
2. **OneVPL Integration**: Ergänze `vpl-gpu-rt` in deiner Hardware-Config, um die UHD 630 voll auszureizen.
3. **Tailscale Zero-Downtime**: Setze `stopIfChanged = false;` in `tailscale.nix`, damit du dich bei einem Rebuild nicht selbst aussperrst.

---
*Fazit: Deine "bescheidenen Gehversuche" sind bereits auf einem SRE-Niveau, von dem viele andere Setups nur träumen können. Die Unterschiede liegen im Detail der Kernel-Isolation.*
