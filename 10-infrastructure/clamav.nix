/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-003
 *   title: "ClamAV (SRE Exhausted)"
 *   layer: 10
 * summary: Professional antivirus protection with resource-aware scheduling and sandboxing.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/security/clamav.nix
 * ---
 */
{ config, lib, pkgs, ... }:
{
  # ── CLAMAV DAEMON & UPDATER (NMS v2.3 Standard) ────────────────────────
  services.clamav = {
    daemon.enable = true;
    updater.enable = true; # freshclam
    
    # 🕵️ SRE SCANNER (Wöchentlicher Scan)
    scanner = {
      enable = true;
      interval = "Sat *-*-* 03:00:00"; # Samstags nachts (Minimale Last)
      scanDirectories = [ "/home" "/var/lib" "/etc" ];
      # SRE: Exclude media (zu groß für wöchentlichen Clam-Scan)
      excludePath = [ "/mnt/media" "/mnt/fast-pool/downloads" ];
    };
    
    # Advanced Options (Aviation Grade)
    daemon.settings = {
      LogTime = true;
      LogVerbose = false;
      MaxScanSize = "100M";
      MaxFileSize = "50M";
      PCREMatchLimit = 10000;
      PCREMaxRecurse = 1000;
    };
  };

  # ── RESSOURCENSCHUTZ (Schutz vor CPU-Heißlaufen auf i3-9100) ─────────────
  # ClamAV kann beim Scannen extrem viel CPU fressen.
  # Wir limitieren den Scan-Prozess auf 'idle' Priorität.
  systemd.services.clamdscan = {
    serviceConfig = {
      CPUWeight = 20;
      IOWeight = 20;
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
      # SRE: Ressourcen-Isolation
      Slice = "system-security.slice";
    };
  };

  # ── SRE SANDBOXING (Level: Exhausted) ──────────────────────────────────
  systemd.services.clamav-daemon.serviceConfig = {
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    PrivateDevices = true;
    NoNewPrivileges = true;
    # ClamAV braucht keine Netzwerk-Capabilities außer DNS für Updates
    CapabilityBoundingSet = [ "" ];
    # OOM-Schutz: ClamAV darf im Zweifel als erstes sterben
    OOMScoreAdjust = 1000;
    
    # Aviation Grade Hardening
    MemoryDenyWriteExecute = true;
    ProtectControlGroups = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 * ---
 */
