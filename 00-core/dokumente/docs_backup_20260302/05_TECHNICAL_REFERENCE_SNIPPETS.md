---
title: NixOS Homelab Technical Reference & Snippets
project: NMS v2.3
last_updated: 2026-03-02
status: Consolidated (NixOS Expert Edition)
type: Technical Reference
---

# 🛠️ TECHNICAL REFERENCE & SNIPPETS

Der "Code-Tresor" für NMS v2.3 mit fokus auf Q958 Hardware-Exhaustion.

## 📺 Intel QuickSync (QSV) & VAAPI
Optimale Treiber für i3-9100 (UHD 630).
```nix
hardware.graphics = {
  enable = true;
  extraPackages = with pkgs; [
    intel-media-driver # Modern iHD driver
    vpl-gpu-rt         # OneVPL for modern QSV
    intel-compute-runtime # OpenCL for Tone-Mapping
  ];
};
# Wichtig für Jellyfin Environment:
# LIBVA_DRIVER_NAME = "iHD"
```

## 🔋 HDD Spindown (hd-idle)
Präzise Steuerung für Western Digital / Seagate Mischbetrieb.
```nix
systemd.services.hd-idle = {
  description = "Hard Drive Idle Spindown Daemon";
  wantedBy = [ "multi-user.target" ];
  serviceConfig = {
    ExecStart = "${pkgs.hd-idle}/bin/hd-idle -i 0 -a /dev/disk/by-id/ata-WDC_... -i 600";
  };
};
```

## 🔀 MergerFS Spindown-Scharfstellung
Optionen für maximalen HDD-Schlaf in `storage.nix`.
```nix
fileSystems."/mnt/storage" = {
  device = "/mnt/cache:/mnt/hdd*";
  fsType = "fuse.mergerfs";
  options = [
    "defaults"
    "cache.readdir=true"     # RAM-Inhalt für ls
    "dropcacheonclose=true"  # Schont RAM & HDD
    "category.create=ff"     # First-Found (schreibt immer auf SSD)
    "noatime"                # Keine Writes beim Lesen
  ];
};
```

## 🛡️ Caddy SSO Snippet (PocketID)
```nix
services.caddy.extraConfig = ''
  (sso_auth) {
    forward_auth localhost:3000 {
      uri /api/auth/verify
      copy_headers X-Forwarded-User X-Forwarded-Groups
    }
  }
'';
```

---
*Dokument Ende.*
