/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-003
 *   title: "ClamAV (SRE Exhausted)"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: []
 *   downstream: []
 *   status: audited
 * summary: Professional antivirus protection with resource-aware scheduling and sandboxing.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/security/clamav.nix
 * ---
 */
{ lib, ... }:
{
  services.clamav = {
    daemon.enable  = true;
    updater.enable = true;

    scanner = {
      enable     = true;
      interval   = "Sat *-*-* 03:00:00";
      scanDirectories = [ "/home" "/var/lib" "/etc" ];
      # Media-Verzeichnisse ausschließen (zu groß für wöchentlichen Scan)
      excludePath = [ "/mnt/media" "/mnt/fast-pool/downloads" ];
    };

    daemon.settings = {
      LogTime          = true;
      LogVerbose       = false;
      MaxScanSize      = "100M";
      MaxFileSize      = "50M";
      PCREMatchLimit   = 10000;
      PCREMaxRecurse   = 1000;
    };
  };

  # ClamAV auf idle-Priorität: darf System nicht blockieren
  systemd.services.clamdscan.serviceConfig = {
    CPUWeight             = 20;
    IOWeight              = 20;
    CPUSchedulingPolicy   = "idle";
    IOSchedulingClass     = "idle";
    Slice                 = "system-security.slice";
  };

  systemd.services.clamav-daemon.serviceConfig = {
    ProtectSystem          = "strict";
    ProtectHome            = true;
    PrivateTmp             = true;
    PrivateDevices         = true;
    NoNewPrivileges        = true;
    CapabilityBoundingSet  = [ "" ];
    OOMScoreAdjust         = 1000;  # ClamAV stirbt als erstes bei OOM
    MemoryDenyWriteExecute = true;
    ProtectControlGroups   = true;
    ProtectKernelModules   = true;
    ProtectKernelTunables  = true;
    RestrictRealtime       = true;
    RestrictSUIDSGID       = true;
  };
}

/**
 * ---
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 *   complexity_score: 1
 * ---
 */
