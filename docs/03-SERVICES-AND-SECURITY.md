---
title: Services & Sicherheit
author: Moritz
last_updated: 2026-02-26
status: active
source_id: DOC-SEC-001
description: Übersicht der Dienste, Ports und Sicherheitsmechanismen.
---

# 🛡️ Services & Sicherheit

## 1. Dienst-Übersicht (Port Registry)

Alle Ports werden zentral in `00-core/ports.nix` verwaltet, um Kollisionen zu vermeiden.

| Dienst | Port | Zugriff via Traefik |
| :--- | :--- | :--- |
| Traefik (HTTPS) | 443 | - |
| SSH (gehärtet) | 53844 | Nein (Direkt) |
| Jellyfin | 8096 | jellyfin.${domain} |
| Audiobookshelf | 8000 | abs.${domain} |
| Vaultwarden | 2002 | vault.${domain} |
| n8n | 2017 | n8n.${domain} |
| Homepage | 8082 | ${domain} |
| Pocket-ID | 10010 | auth.${domain} |
| AdGuard Home | 3000 | adguard.${domain} |
| Sabnzbd (VPN) | 8080 | sab.${domain} |

## 2. Reverse Proxy (Traefik)

Traefik fungiert als Sicherheits-Gateway:
*   **ACME/LetsEncrypt:** Automatische Zertifikate via Cloudflare DNS-01 Challenge.
*   **Middlewares:** Strikte Security-Headers, Rate-Limiting und IP-Whitelisting für interne Dienste.
*   **Authentifizierung:** Vorbereitet für Forward-Auth via Pocket-ID.

## 3. Sicherheits-Leitplanken

### NFTables VPN Killswitch
Ein nativer Killswitch sorgt dafür, dass die Download-Services (`sabnzbd`, `sonarr`, etc.) niemals am VPN vorbei ins Internet telefonieren.
*   **Regel:** Traffic von Mitgliedern der VPN-Gruppen wird blockiert, es sei denn, er geht über das `privado` Interface oder ins lokale LAN.

### SSH Hardening
*   Port wurde von 22 auf **53844** verschoben.
*   Maximal 3 Login-Versuche, Timeout nach 20s ohne Aktivität.
*   Deaktivierter Root-Login.

### Systemd Sandboxing
Alle Dienste nutzen (wo möglich) moderne systemd-Härtung:
*   `ProtectSystem=strict`
*   `PrivateTmp=true`
*   `NoNewPrivileges=true`
