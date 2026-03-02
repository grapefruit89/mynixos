---
title: NixOS pkgs Best Practices & Official Patterns
project: NMS v2.3
last_updated: 2026-03-02
status: Initial Draft (Extracted from NixOS/nixpkgs)
type: Technical Reference
---

# 📦 NIXOS PKGS BEST PRACTICES

Dieses Dokument bündelt "Goldnuggets" aus dem offiziellen `NixOS/nixpkgs` Repository. Diese Patterns dienen als Vorlage für eigene, hochprofessionelle Module.

## 🛡️ Standard Sandboxing Pattern (Level: High)
Offizielle Module (z.B. Jellyfin) nutzen eine extrem restriktive `serviceConfig`. Dies sollte der Standard für alle Layer-20 Dienste sein:

```nix
serviceConfig = {
  # Volle Isolation
  CapabilityBoundingSet = [ "" ];
  NoNewPrivileges = true;
  ProtectSystem = "strict";
  ProtectHome = true;
  PrivateTmp = true;
  PrivateDevices = true;
  PrivateUsers = true;
  RemoveIPC = true;
  
  # Kernel & Proc Härtung
  ProcSubset = "pid";
  ProtectProc = "invisible";
  ProtectKernelLogs = true;
  ProtectKernelModules = true;
  ProtectKernelTunables = true;
  ProtectControlGroups = true;
  ProtectClock = true;
  ProtectHostname = true;
  LockPersonality = true;
  
  # Netzwerk-Beschränkung
  RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
  RestrictNamespaces = true;
  RestrictRealtime = true;
  RestrictSUIDSGID = true;
  
  # System-Call Filter (Der ultimative Schutz)
  SystemCallFilter = [ "@system-service" "~@privileged" ];
  SystemCallErrorNumber = "EPERM";
};
```

## 🎥 Hardware Acceleration Pattern (QSV/VAAPI)
Aus dem Jellyfin-Modul extrahiert:
- **Device-Mapping**: Nutze `DeviceAllow = [ "${cfg.device} rw" ];` anstatt die Sandbox für Devices komplett zu öffnen.
- **Treiber-Erzwingung**: `environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";` ist der korrekte Weg für Coffee Lake (Q958).
- **OneVPL**: Füge `pkgs.vpl-gpu-rt` zu `hardware.graphics.extraPackages` hinzu, um QSV-Funktionen für moderne Apps zu aktivieren.

## 🌐 Networking & Ingress Patterns
- **QUIC Performance**: Caddy setzt `net.core.rmem_max = 2500000` automatisch. Dies verbessert HTTP/3 Stabilität massiv.
- **Tailscale Autoconnect**: Nutze ein `oneshot` oder `notify` Service-Pattern (wie `tailscaled-autoconnect.service`), um Keys deklarativ zu verarbeiten, anstatt sie manuell einzugeben.
- **Zero-Downtime Updates**: Setze `stopIfChanged = false;` für kritische Dienste wie SSH oder Tailscale, damit die Verbindung bei einem Rebuild nicht abreißt.

## 📝 Deklarative Config-Injection
Das Jellyfin-Modul zeigt, wie man XML/JSON Configs direkt aus Nix generiert:
1. Erzeuge einen Text-Block mit `pkgs.writeText`.
2. Kopiere ihn im `preStart` an die Zielstelle.
3. **Vorteil**: Die Nix-Config bleibt die "Single Source of Truth", aber die App erhält ihre gewohnte Datei.

---
*Quelle: Extracted from NixOS/nixpkgs (nixos/modules/services/)*
