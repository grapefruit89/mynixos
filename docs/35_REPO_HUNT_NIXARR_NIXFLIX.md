---
title: Repo-Hunt: Nixarr & Nixflix Goldnuggets
project: NMS v2.3
last_updated: 2026-03-02
status: Analysis Complete
type: Research Report
---

# 🕵️ REPO-HUNT: GOLDNUGGETS AUS DER SAMMLUNG

Ich habe die lokalen Kopien von **Nixarr** und **Nixflix** seziert. Hier sind die wertvollsten Architektur-Ideen und "Goldnuggets" für dein System.

## 💎 Goldnugget 1: Automatisierte API-Verkabelung (Nixarr)
Nixarr nutzt ein geniales Pattern: Anstatt API-Keys manuell in `sops` zu pflegen, extrahiert ein systemd-Dienst (`api-key-extractor`) die Keys nach dem ersten Start direkt aus den Config-Dateien (`config.xml`, `settings.json`) der Dienste.
- **Nutzen**: Wir könnten unseren `arr-wire.service` so aufbohren, dass er Keys nicht nur setzt, sondern bei Bedarf auch liest und zwischen den Diensten synchronisiert (z.B. Prowlarr -> Sonarr).

## 💎 Goldnugget 2: Deklarative App-Konfiguration (Nixflix)
Nixflix geht extrem weit: Es nutzt Nix-Optionen, um POST-Requests an die APIs von Jellyfin und Sonarr zu senden, sobald diese laufen.
- **Nutzen**: Wir könnten Dinge wie "Qualitätsprofile" oder "Root-Ordner" direkt im Nix-Code definieren, anstatt sie in der Web-UI anzuklicken.

## 💎 Goldnugget 3: VPN Confinement (Nixarr Standard)
Anstatt nur per Firewall zu blockieren, nutzt Nixarr echte **Netzwerk-Namespaces**. Ein Dienst wie SABnzbd "sieht" physisch nur den VPN-Tunnel.
- **Nutzen**: Absolute Sicherheit vor Leaks, auch wenn die Firewall-Regeln versagen.

---

# 🔐 SOPS SECRETS MASTERPLAN

Der github-mcp-server mag nerven, aber wir bauen jetzt unsere eigene "Secret-Festung". Wir strukturieren die `secrets.yaml` so um, dass jedes Programm seinen eigenen, logischen Platz hat.

## 📐 Vorgeschlagene Sops-Struktur (Hierarchie)

```yaml
identity:
  admin_pass: ENC[...] # Globaler Admin
  
infrastructure:
  cloudflare:
    dns_token: ENC[...]
  tailscale:
    auth_key: ENC[...]
  restic:
    repo_pass: ENC[...]
  postgres:
    superuser_pass: ENC[...]

apps:
  media:
    sonarr_api: ENC[...]
    radarr_api: ENC[...]
    prowlarr_api: ENC[...]
    sabnzbd_api: ENC[...]
  automation:
    n8n_enc_key: ENC[...]
  security:
    vaultwarden_admin: ENC[...]
```

## 🚀 Nächste Schritte
1. **Zentralisierung**: Wir sammeln alle Keys aus deinen `.env` Dateien und überführen sie in diese Struktur.
2. **Template-Migration**: Wir stellen die Dienste auf `sops.templates` um, damit die Keys nur im RAM (`/run/secrets`) landen.
