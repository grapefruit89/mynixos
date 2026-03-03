{ lib, pkgs, config, ... }:
let
  nms = {
    id = "NIXH-20-INF-001";
    title = "ClamAV (SRE Exhausted)";
    description = "Professional antivirus protection.";
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
    description = "NMS metadata";
  };

  config = lib.mkIf (config.my.services.clamav.enable or true) {
    services.clamav = {
      daemon.enable = true;
      updater.enable = true;
      scanner = {
        enable = true;
        interval = "Sat *-*-* 03:00:00";
        scanDirectories = [ "/home" "/var/lib" "/etc" ];
      };
      daemon.settings = {
        LogTime = true;
        LogVerbose = false;
        MaxScanSize = "100M";
        MaxFileSize = "50M";
        # ExcludePath wird oft direkt in den Daemon-Settings definiert
        ExcludePath = [ "^/mnt/media" "^/mnt/fast-pool/downloads" ];
      };
    };

    systemd.services.clamdscan.serviceConfig = {
      CPUWeight = 20; IOWeight = 20; CPUSchedulingPolicy = "idle"; IOSchedulingClass = "idle";
    };
  };
}
