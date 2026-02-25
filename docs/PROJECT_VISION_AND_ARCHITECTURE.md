# Projekt-Vision & Architektur (living document)

> Zweck: Eine zentrale, verständliche Beschreibung für Motivation, Ziele, Architektur und Betriebsmodell.

## 1) Vision
Dieses Repository beschreibt ein sicherheitsorientiertes NixOS-Homelab mit klarer Modularisierung, reproduzierbaren Änderungen und überprüfbaren Sicherheitsleitplanken.

## 2) Leitprinzipien
- **Security first:** SSH nicht öffentlich exponieren, minimale Angriffsfläche.
- **Declarative by default:** Infrastruktur als Code statt ad-hoc Shell-Historie.
- **Idempotenz & Nachvollziehbarkeit:** gleiche Inputs -> gleicher Zustand.
- **Guardrails statt Bauchgefühl:** Assertions verhindern unbemerkte Regressionen.
- **Operateability:** Notfallpfade (z. B. SSH-Fallback) bewusst und sichtbar dokumentieren.

## 3) Architektur-Überblick
### 00-core
Basisbausteine wie Ports, SSH, Firewall, Secrets, User, Host-Defaults.

### 10-infrastructure
Netz/Ingress/Plattform-Bausteine (Traefik, Tailscale, WireGuard, Cloudflare Tunnel, Monitoring).

### 20-services
Anwendungs- und Medien-Services, inklusive shared media factory (`_lib.nix`) und optionalem ARR helper.

### 90-policy
Zentrale Sicherheitsassertions zur Absicherung kritischer Invarianten.

## 4) Security-Baseline (derzeit)
- SSH-Port kommt aus zentraler Port-Registry (`my.ports.ssh`).
- SSH aus Heimnetz-Private-Ranges + Tailnet erlaubt, aus öffentlichem Internet verboten.
- Key-aware SSH-Fallback:
  - Key vorhanden -> Passwort/Kbd-Auth aus.
  - Kein Key -> kontrollierter Fallback an + Warnung im Log.
- `PermitTTY = true` bleibt als Recovery-Kanal aktiv.

## 5) Secrets-Strategie
Kurzfristig bewusst einfach:
- Bootstrapping über feste `.env`-Struktur (`/etc/secrets/homelab-runtime-secrets.env.example`).
- Keine Secret-Werte im Repo.
- Später optional Migration zu sops/agenix, wenn Betriebsroutine stabil ist.

## 6) Betriebsmodell
- Änderungen über Branch + PR.
- Deployment am Host via:
  1. `git pull --ff-only`
  2. `sudo nixos-rebuild test`
  3. `sudo nixos-rebuild switch`

## 7) Inspirationen & Quellen
Diese Datei ist als **living document** gedacht. Externe Inspirationen (Guides, Projekte, eigene Chat-Analysen)
werden hier gesammelt, sobald sie als Dateien im Repo vorliegen und verifiziert referenzierbar sind.

## 8) Nächste sinnvolle Ausbaustufen
- Architekturdiagramm (logisch: ingress -> proxy -> services -> policy).
- Rollenkonzept (`owner`, `status`, `scope`) konsequent auf alle Module ausweiten.
- Optionales "ops runbook" (Incident/Recovery/Rotation Playbooks).


## 9) Referenzdokumente
- Push/Sync-Ablauf: `docs/OPERATIONS_GITHUB_PUSH.md`
- Externe Quellen/Links: `docs/SOURCES_AND_INSPIRATION.md`
- Spec-ID Registry: `90-policy/spec-registry.md`
