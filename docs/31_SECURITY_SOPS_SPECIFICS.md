---
title: NixOS Homelab Security & SOPS Specifics
project: NMS v2.3
last_updated: 2026-03-02
status: Consolidated (NixOS Expert Enriched)
type: Security Documentation
---

# 🛡️ SECURITY & SOPS SPECIFICS

## 🚥 Das 10k/20k Port-Register
Zentrale Verwaltung in `00-core/ports.nix`:
- **10xxx (Infra)**: AdGuard (10000), Pocket-ID (10010), Homepage (10082).
- **20xxx (Apps)**: Audiobookshelf (20000), Vaultwarden (20002), Jellyfin (20096).

## 🔐 SOPS-Nix & Zero-Store Management
- **Konzept**: TPM + Age (Asymmetrische Verschlüsselung).
- **Safe-Schlüssel**: Der hardware-gebundene SSH-Host-Key entschlüsselt zur Runtime nach `/run/secrets/`.
- **Notfall**: Ein separater Offline-Age-Key erlaubt die Recovery ohne Server-Zugriff.

> **[NixOS Expert-Einschub: SOPS Tunnels & Templates]**
> Für maximale Sicherheit sollten Secrets niemals als Umgebungsvariablen (`EnvironmentFile`) geladen werden, wenn die App dies unterstützt. Nutze stattdessen das **Template-Feature** von SOPS-nix:
> ```nix
> sops.templates."app-config.yaml".content = ''
>   database:
>     password: "${config.sops.placeholder.db_pass}"
> '';
> ```
> Die Datei liegt dann unter `/run/secrets/app-config.yaml` (im RAM-Disk) und ist für den Nix-Store unsichtbar.

## 🚧 VPN Killswitch vs. Confinement
Ein nativer Killswitch in der Firewall stellt sicher, dass Download-Dienste (`sabnzbd`, `sonarr`) niemals am VPN vorbeischleusen.

> **[NixOS Expert-Einschub: Network Namespaces (VPN Confinement)]**
> Der Goldstandard für 2026 ist das **VPN-Confinement** Modul (z.B. von Maroka-chan). Anstatt nur per Firewall zu blockieren, wird der Dienst in einen eigenen Netzwerk-Namespace verschoben, der *physisch nur das VPN-Interface* sieht. 
> **Vorteil**: Absolute Leaksicherheit, selbst wenn nftables abstürzt. Tailscale bleibt im Root-Namespace unbeeinträchtigt.
