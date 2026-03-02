---
title: IMPLEMENTATION_REPORT_PHASE3
category: Betrieb
status: done
trace_ids: []
last_reviewed: 2026-02-28
checksum: 71298bb6693dbc85b3c7021b9cbd702694647c4a19113bee0c26f6d09db82007
---
# SRE Implementation Report - Phase 3: Zero-Trust Confinement & Secret Ingest

**Datum:** 27. Februar 2026  
**Zielsystem:** Intel i3-9100 (`nixhome`)  
**Status:** Erfolgreich implementiert & verifiziert

---

## 1. System-Identität & mDNS (Hostname Fix)
*   **Problem:** Der Hostname hing auf dem generierten Wert `q958` fest, was zu mDNS-Inkonsistenzen führte.
*   **Lösung:** Der Hostname wurde in der zentralen Konfiguration (`00-core/configs.nix`) forciert auf `nixhome` gesetzt.
*   **Ergebnis:** Das System ist nun im gesamten lokalen Netzwerk verlässlich über Avahi unter `nixhome.local` erreichbar.

## 2. Secret Landing Zone UI & Auto-Ingest
*   **Architektur:** Implementierung einer minimalistischen, isolierten Web-Drop-Zone (Python 3.11 `http.server`) für das sichere Hochladen von VPN-Konfigurationen.
*   **Erreichbarkeit:** Die UI ist via Traefik direkt über `http://nixhome.local` (Port 80) sowie `http://192.168.2.73` erreichbar. Der interne Port wurde auf `10023` gelegt, um Socket-Konflikte zu vermeiden.
*   **Auto-Ingest Agent:** Ein inotify-basierter Daemon (`secret-ingest.service`) überwacht den Ordner `/etc/nixos/secret-landing-zone/`.
*   **Key-Sideloading (SOPS-Bypass):** Um Entschlüsselungsprobleme in der Root-Umgebung zu umgehen, extrahiert der Agent den `PrivateKey` und schreibt ihn temporär in eine sichere Datei (`/etc/nixos/secret-ingest-agent-key.txt`, `chmod 600`), während die öffentlichen Parameter in die `vpn-live-config.nix` injiziert werden. Die Originaldatei wird per `shred -u` vernichtet.

## 3. Network Namespace Confinement (`media-vault`)
*   **Architektur:** Physische Netzwerkisolation anstelle von "Selective Proxying". Alle Media-Dienste (`sonarr`, `radarr`, `prowlarr`, `sabnzbd`) wurden in den Linux Network Namespace `media-vault` verschoben.
*   **Bridging:** Traefik kommuniziert mit den isolierten Diensten über ein VETH-Paar (`veth-host: 10.200.1.1` <-> `veth-vault: 10.200.1.2`).
*   **Killswitch:** Das WireGuard-Interface (`privado`) wird direkt im Namespace verankert. Die Default-Route des Namespaces zeigt zwingend auf dieses Interface. Fällt das VPN aus, gibt es keinen Fallback in das Host-Netzwerk (Hard-Killswitch).
*   **Verifikation:** Ein Test per `ip netns exec media-vault curl https://ipinfo.io` lieferte erfolgreich die niederländische VPN-IP, was die vollständige Kapselung bestätigt.

## 4. Traefik Security & IP Whitelisting
*   **Sicherung der internen Routen:** Die `local-ip-whitelist` Middleware in `traefik-core.nix` wurde erweitert, um den Zugriff auf interne Dienste (wie die Landing Zone UI) streng zu limitieren.
*   **Erlaubte Netzbereiche:**
    *   `127.0.0.0/8` (Loopback)
    *   `169.254.0.0/16` (Link-Local)
    *   `192.168.0.0/16`, `10.0.0.0/8`, `172.16.0.0/12` (RFC 1918 LAN)
    *   `100.64.0.0/10` (RFC 6598 Shared Address Space / Tailscale)
*   **Ergebnis:** Lokale Dienste sind nahtlos aus dem Heimnetzwerk und via Tailscale erreichbar, jedoch vollständig gegen externe Zugriffe abgeschirmt.

---
**Fazit:** Phase 3 der Architektur-Roadmap ist abgeschlossen. Das System verfügt nun über ein Level 99 SRE Confinement für den Media-Stack mit einem hochgradig automatisierten, sicheren Secret-Ingest-Prozess.