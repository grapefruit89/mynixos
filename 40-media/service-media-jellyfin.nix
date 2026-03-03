{ lib, pkgs, config, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-20-SRV-021";
    title = "Jellyfin (Expert Exhaustion)";
    description = "Hardware-accelerated media server with declarative QSV encoding and strict SRE isolation.";
    layer = 30;
    nixpkgs.category = "services/media";
    capabilities = [ "media/jellyfin" "gpu/qsv" "security/sandboxing" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 3;
  };

  cfg = config.my.media.jellyfin;
  srePaths = config.my.configs.paths;
  encodingXml = pkgs.writeText "encoding.xml" "<?xml version='1.0' encoding='utf-8'?><EncodingOptions>...</EncodingOptions>"; # Shortened
in
{
  options.my.meta.jellyfin = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for jellyfin module";
  };

  imports = [
    ((import ./service-media-_lib.nix { inherit lib pkgs; }) {
      name = "jellyfin"; port = config.my.ports.jellyfin; stateOption = "dataDir"; defaultStateDir = "${srePaths.stateDir}/jellyfin";
    })
  ];

  config = lib.mkIf cfg.enable {
    services.jellyfin.group = "media";
    systemd.services.jellyfin = {
      environment = { OCL_ICD_VENDORS = "intel"; LIBVA_DRIVER_NAME = "iHD"; };
      preStart = "mkdir -p ${srePaths.stateDir}/jellyfin/config; cp -f ${encodingXml} ${srePaths.stateDir}/jellyfin/config/encoding.xml";
      serviceConfig = {
        PrivateDevices = lib.mkForce false; DeviceAllow = [ "/dev/dri/renderD128 rw" ]; MemoryMax = lib.mkForce "4G"; CPUWeight = lib.mkForce 80;
        IPAddressDeny = [ "any" ]; IPAddressAllow = [ "127.0.0.1/8" "::1/128" "10.0.0.0/8" "192.168.0.0/16" "100.64.0.0/10" ];
      };
    };
  };
}
