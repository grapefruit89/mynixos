{ lib, pkgs, config, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-10-INF-003";
    title = "ClamAV (SRE Exhausted)";
    description = "Professional antivirus protection with resource-aware scheduling and sandboxing.";
    layer = 10;
    nixpkgs.category = "services/security";
    capabilities = [ "security/antivirus" "system/protection" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 1;
  };
in
{
  options.my.meta.clamav = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for clamav module";
  };


  config = lib.mkIf config.my.services.clamav.enable {
    services.clamav = {
      daemon.enable = true;
      updater.enable = true;
      scanner = {
        enable = true;
        interval = "Sat *-*-* 03:00:00";
        scanDirectories = [ "/home" "/var/lib" "/etc" ];
        excludePath = [ "/mnt/media" "/mnt/fast-pool/downloads" ];
      };
      daemon.settings = { LogTime = true; LogVerbose = false; MaxScanSize = "100M"; MaxFileSize = "50M"; };
    };

    systemd.services.clamdscan.serviceConfig = {
      CPUWeight = 20; IOWeight = 20; CPUSchedulingPolicy = "idle"; IOSchedulingClass = "idle"; Slice = "system-security.slice";
    };

    systemd.services.clamav-daemon.serviceConfig = {
      ProtectSystem = "strict"; ProtectHome = true; PrivateTmp = true; PrivateDevices = true; NoNewPrivileges = true;
      CapabilityBoundingSet = [ "" ]; OOMScoreAdjust = 1000; MemoryDenyWriteExecute = true;
    };
  };
}
