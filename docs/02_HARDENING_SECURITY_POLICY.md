---
title: NixOS Homelab Hardening & Security Policy
project: NMS v2.3
last_updated: 2026-03-02
status: Consolidated (NixOS Expert Edition)
type: Security & Hardening
---

# 🔒 HARDENING & SECURITY POLICY

Dieses Dokument definiert den Sicherheits-Standard des Homelabs unter Nutzung fortgeschrittener NixOS-Features.

## 🛡️ System-Härtung (NixOS Native)

### 1. Systemd Service Sandboxing
Jeder Dienst in `20-services` MUSS folgende Flags in seiner `serviceConfig` evaluieren:
```nix
serviceConfig = {
  ProtectSystem = "strict";      # Verhindert Schreibzugriff auf /usr, /boot, /etc
  ProtectHome = true;            # Isoliert /home
  PrivateTmp = true;             # Eigener /tmp Namespace
  PrivateDevices = true;         # Kein Zugriff auf physische Hardware (außer Jellyfin)
  NoNewPrivileges = true;        # Verhindert sudo innerhalb des Services
  MemoryDenyWriteExecute = true; # Schutz vor Pufferüberläufen (W^X)
  CapabilityBoundingSet = "";    # Entzieht alle Kernel-Capabilities
};
```

### 2. Network Isolation (nftables)
- Umstellung auf `networking.nftables.enable = true`.
- Nutzung von `networking.firewall.extraInputRules` für Interface-spezifisches Whitelisting (Tailscale-only SSH).

---

## 🔑 Secret Management (SOPS-nix)

Das "Source-ID" System wird durch `sops-nix` technologisch untermauert:
- Secrets landen niemals im Nix-Store.
- **Standard**: `sops.secrets."api/key" = { owner = "service-user"; };`.
- **Integration**: Services laden Secrets via `EnvironmentFile = config.sops.secrets."name".path;`.

> **[NixOS Expert-Einschub: SOPS Templates & Rotation]**
> Für Dienste, die komplexe Konfigurationsdateien mit eingebetteten Secrets benötigen (z.B. Caddyfile oder Home Assistant), sollte das `sops.templates` Feature genutzt werden. Dies erlaubt die deklarative Generierung von Files im RAM-Disk (`/run/secrets/`). 
> **Tipp**: `sops.secrets."name".restartUnits = [ "service.service" ];` automatisiert den Neustart von Diensten bei Key-Rotationen.

---

## ☁️ Edge & Ingress Security
- **Cloudflare DNS-01**: Automatisches Wildcard-Cert Handling via `security.acme`.
- **SSO Enforcement**: Caddy Snippet `import sso_auth` ist Pflicht für alle Web-UIs.
- **Tailscale Tailnet**: Einzige Route für administrative Backends (Cockpit, Netdata).

---
*Dokument Ende.*
