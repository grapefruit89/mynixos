---
title: NixOS Homelab Reverse Proxy Strategy (Caddy)
project: NMS v2.3
last_updated: 2026-03-02
status: Consolidated Migration Strategy
type: Infrastructure Rationale
---

# 🛡️ REVERSE PROXY STRATEGY: CADDY

Dieses Dokument beschreibt die strategische Entscheidung für **Caddy** als primären Reverse Proxy und die daraus resultierenden Architektur-Muster.

## 🏗️ Die Entscheidung: Caddy over Traefik

Nach einer Evaluierungsphase wurde Caddy aufgrund folgender Vorteile zum Standard erhoben:
1.  **Lesbarkeit**: Das Caddyfile-Format ist wesentlich wartungsfreundlicher als die YAML/TOML-Struktur von Traefik.
2.  **Snippet-System**: Wiederkehrende Logiken (SSO, Security Headers) lassen sich modular als Snippets definieren und in vHosts importieren.
3.  **ACME Integration**: Nahtlose Let's Encrypt DNS-01 Challenge via Cloudflare Plugin.

---

## 🔒 Security Architektur (Snippets)

### 1. SSO Integration (PocketID)
Das `sso_auth` Snippet realisiert den Zero-Trust Zugriffsschutz.

> **[NixOS Expert-Einschub: Forward-Auth Pattern]**
> In Caddy v2.5+ ist das `forward_auth` Modul der Goldstandard für PocketID. Es sollte immer `copy_headers X-Forwarded-User X-Forwarded-Email` enthalten, um dem Backend die Identität des Nutzers sicher mitzuteilen.

### 2. Security Headers (Best Practice)
Ein globales Snippet erzwingt Härtung auf Browser-Ebene:

> **[NixOS Expert-Einschub: Production Security Headers]**
> Ein hocheffektives `security_headers` Snippet für Caddy sieht wie folgt aus:
> ```caddy
> header {
>   Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
>   X-Content-Type-Options "nosniff"
>   X-Frame-Options "DENY"
>   Referrer-Policy "strict-origin-when-cross-origin"
>   Permissions-Policy "interest-cohort=()"
> }
> ```
> Dies schaltet HSTS ein, verhindert Content-Sniffing und unterbindet das Clickjacking-Risiko (Frame-Options).

---

## 🚀 Performance & Latenz-Optimierung

Jeder Request durchläuft eine Pipeline:
`Browser` → `Caddy (TLS)` → `GeoIP (optional)` → `forward_auth (PocketID)` → `Backend`.
- **Latenz-Budget**: Ziel ist < 50ms Overhead pro Request.

---

## 🛠️ Service-Anbindung (Standard-Muster)

Dienste werden in NixOS wie folgt an Caddy angebunden:
```nix
services.caddy.virtualHosts."service.${domain}" = {
  extraConfig = ''
    import sso_auth
    reverse_proxy 127.0.0.1:${toString port}
  '';
};
```
Dieses Muster gilt für alle Layer 20 Services.

---

## 🔍 Wartung & Troubleshooting
- **Validation**: `caddy validate --config /run/caddy/Caddyfile`.
- **Reload**: Erfolgt ohne System-Rebuild bei reinen vHost-Änderungen über einen dedizierten systemd-Dienst (`config-hot-reload`).
