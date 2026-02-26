> archive-meta:
> status: consolidated
> curated: 2026-02-25
> scope: Zusammenfassung historischer Ideen, Entscheidungen, Ablehnungen, offenen Fragen
> sources:
>   - docs/archive/MASTER.md
>   - docs/archive/MASTER (1).md
>   - docs/archive/Claude-NixOS-Masterchat.md
>   - docs/archive/Claude-NixOS-Masterchat (1).md
>   - docs/archive/gemin context.md
>   - docs/archive/CONSOLIDATION_NOTES.md
>   - docs/archive/README.md

# Archiv-Konsolidierung – Q958 NixOS (A–Z Überblick)

Diese Datei fasst die Inhalte aus `docs/archive/*` thematisch zusammen. Sie ist kein Ersatz für die Living Docs, sondern dient als komprimierter Kontextspeicher.

Leitidee: klare Architekturentscheidungen, nachvollziehbare Ablehnungen, sicherer Betrieb, wenige zentrale Konfigurationsorte.

---

## 1) Projektziel & Leitlinien

- Ziel: ein stabiles, wartbares Homelab mit klarer Struktur, minimalem Suchaufwand und nachvollziehbaren Entscheidungen.
- Prinzip: zentrale Konfiguration für geteilte Werte, wenige „Single Source of Truth“-Punkte, klare Grenzen zwischen Core/Infra/Services.
- Sicherheit vor Komfort: Zugänge müssen sauber testbar sein (rollback-fähig), aber nicht „hart“ blockieren, wenn Rettung notwendig ist.

Status: Grundsatz (dauerhaft)

---

## 2) Hardware & Basis

- Plattform: Fujitsu Q958, Intel i3-9100 (UHD 630).
- Fokus: leiser Dauerbetrieb, HDD-Spindown, NVMe als Download-Cache.

Status: Bestandsaufnahme

---

## 3) Architektur-Entscheidungen (finale Beschlüsse aus dem Archiv)

### Storage

- ext4 überall.
- Keine Pooling-Dateisysteme (mergerfs weckt alle HDDs auf).
- Atomic Move über `.staging/` auf derselben HDD.
- hd-idle für Spindown (600s).
- NVMe als Download-Cache (SABnzbd -> `/downloads/`).

Status: Entscheidung final

### Reverse Proxy

- Traefik v3 mit NixOS-Modul.
- ACME über Cloudflare DNS-Challenge (kein Port 80 nötig).
- Subdomain pro Service: `service.<domain>`.
- Außen nur 80/443/22.

Status: Entscheidung final

### Auth/SSO

- Pocket ID als OIDC Provider (leichtgewichtig, Passkeys).
- ForwardAuth für Services ohne OIDC.
- Vaultwarden bleibt isoliert (kein SSO).

Status: Entscheidung final

### Secrets

- sops-nix + Age Keys.
- Secrets als `KEY=VALUE` in sops, direkt als `EnvironmentFile` nutzbar.
- SSH Host Key -> Age Private Key in `/var/lib/sops-nix/key.txt` (niemals in Git).

Status: Entscheidung final

### VPN

- VPN-Confinement (Net-Namespaces) für SABnzbd.
- AirVPN/Privado mit statischem Port-Forwarding.

Status: Entscheidung final

### Hardware-Transcoding

- Intel QuickSync aktivieren (OpenGL + iHD + i965 + OpenCL).
- Jellyfin braucht `video` + `render` Gruppen.

Status: Entscheidung final

---

## 4) Abgelehnte Alternativen (begründet)

- mergerfs: weckt alle HDDs bei `readdir()`.
- bcachefs: zu jung, kein klarer Vorteil.
- ZFS: Special vdev zu teuer.
- Docker: viele Services haben native NixOS-Module.
- FreshRSS: nginx-Lock-In im NixOS-Modul.
- Redis: BSL-Lizenz seit 2024, daher Valkey bevorzugt.
- Authelia/Keycloak: Overkill für 1–5 Nutzer.
- Immich: bewusst weggelassen.
- nixarr-Module: zu wenig Kontrolle, nur Referenz.

Status: Abgelehnt

---

## 5) Zugriffskonzept (Service-Tiers)

- Tier 0 (nur Tailscale): Homepage, Semaphore, Netdata, Scrutiny, Uptime Kuma, AdGuard, n8n
- Tier 1 (Tailscale + LAN): Prowlarr, Sonarr, Radarr, Readarr, SABnzbd, Jellyseerr, Lidarr
- Tier 2 (Internet + Pocket ID OIDC): Jellyfin, Audiobookshelf, Miniflux, Paperless, Linkding, Readeck
- Tier 3 (eigener Login): Vaultwarden, Pocket ID, CouchDB, Home Assistant

Status: Architekturprinzip

---

## 6) SSH/Firewall Rettung & Hardening (Lessons Learned)

Aus den Chats kristallisieren sich klare Muster:

- Root Cause bei Lockouts: Kombination aus Firewall-Regeln, Assertions und SSH-Settings.
- Korrekte Reihenfolge beim Port-Wechsel wichtig.
- `openFirewall = lib.mkForce true` kann mit zentralen Regeln kollidieren.
- Match-Address-Negationen sind riskant, wenn LAN-Interface nicht sicher bestimmt ist.
- Port-Freigabe muss explizit im zentralen Firewall-Modul passieren (nicht in Service-Modulen verstreut).

Status: Lessons Learned

---

## 7) NixOS-Module vs. Custom Services

Native Module verfügbar (Beispiele): Traefik, Tailscale, fail2ban, Jellyfin, Audiobookshelf, AdGuard, n8n, Netdata, Scrutiny, Home Assistant, CouchDB, usw.

Nicht in nixpkgs (Custom systemd nötig): linkding, readeck, semaphore, uptime-kuma.

Status: Kategorisierung

---

## 8) sops-nix Referenz (aus Archiv übernommen)

Wichtige Lehre: `KEY=VALUE` direkt in sops speichern. Dann kann systemd `EnvironmentFile` ohne Wrapper nutzen.

sops-nix als flake input war im Archiv noch offen. (Falls nicht schon umgesetzt: weiter oben einplanen.)

Status: Vorgehensstandard

---

## 9) Traefik Patterns

- Router-Muster pro Service (Subdomain).
- ACME holt Zertifikate erst, wenn Router existiert.
- DNS-Challenge via Cloudflare als Standard.

Status: Muster/Best Practice

---

## 10) Operations & Workflow (aus Archiv)

- Erst `nix-test`, dann `nix-switch`.
- Secrets verwalten über sops.
- Regelmäßig Nix-Store aufräumen.
- Logs/Status prüfen (Traefik, SSH, Services).

Status: Betriebsstandard

---

## 11) Sicherheitshinweise (historisch, kritisch)

- WireGuard-Key im Repo gefunden: entfernen und Git-History bereinigen.
- Cloudflare API Token in Chat-Verlauf: als kompromittiert betrachten, revoken, neu erstellen.

Status: Sicherheits-Hotfix erforderlich (historischer Hinweis)

---

## 12) Tech Debt (aus Archiv, Stand Feb 2026)

- sops-nix nicht als flake input.
- traefik ACME Provider/Secret auskommentiert.
- SSH-Port widersprüchlich (firewall vs ssh).
- Struktur-Fragen: `90-services-enabled` vs Plan.
- Traefik Docker Provider aktiv ohne Docker.
- open-webui nixpkgs Bugs.

Status: Tech Debt Liste (historisch)

---

## 13) Offene Fragen & Diskussionspunkte

- Flakes: Nutzen vs. Komplexität. Archiv enthält Argumente pro Stabilität durch flake.lock, aber auch Gründe gegen Umstieg.
- nftables: im Archiv als „fehlend/legacy“ diskutiert; iptables wurde als Standardwerkzeug genutzt.
- Assertions: Schutz vs. Blockade; Strategien für sichere Rollbacks sind erforderlich.

Status: Diskussion offen

---

## 14) Referenzen & Quellen

- referenzierte Repos und Dokuquellen finden sich im Archiv unter „Referenz-Repositories“ und „Wichtige Befehle“.

Status: Archiv-Referenz

---

## 15) Was nicht automatisch übernommen wird

Diese Datei ist eine konsolidierte Sicht auf historische Quellen. Sie ersetzt keine Living Docs und darf nicht als autoritativer Betriebsstandard gelten.

Status: Metahinweis
