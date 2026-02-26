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

Alle Ports werden zentral in `00-core/ports.nix` verwaltet. Wir nutzen das **10k/20k-Schema**:
- **10xxx:** Infrastruktur-Dienste.
- **20xxx:** Anwendungs-Services.

| Dienst | Port | Zugriff via Traefik |
| :--- | :--- | :--- |
| Traefik (HTTPS) | 443 | - |
| SSH (gehärtet) | 53844 | Nein (Direkt) |
| **Infrastruktur** | | |
| AdGuard Home | 10000 | adguard.${domain} |
| Pocket-ID | 10010 | auth.${domain} |
| Homepage | 10082 | ${domain} |
| Netdata | 10999 | netdata.${domain} |
| **Services** | | |
| Audiobookshelf | 20000 | abs.${domain} |
| Vaultwarden | 20002 | vault.${domain} |
| Readeck | 20007 | readeck.${domain} |
| Miniflux | 20016 | rss.${domain} |
| n8n | 20017 | n8n.${domain} |
| Scrutiny | 20020 | scrutiny.${domain} |
| Monica | 20031 | monica.${domain} |
| Jellyseerr | 20055 | requests.${domain} |
| Sabnzbd (VPN) | 20080 | sab.${domain} |
| Jellyfin | 20096 | jellyfin.${domain} |
| Paperless-ngx | 20981 | docs.${domain} |

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
