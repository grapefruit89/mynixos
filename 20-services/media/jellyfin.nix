/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-021
 *   title: "Jellyfin (Expert Exhaustion)"
 *   layer: 20
 * summary: Hardware-accelerated media server with declarative QSV encoding and strict SRE isolation.
 * ---
 */
{ lib, pkgs, config, ... }:
let
  cfg = config.my.media.jellyfin;
  srePaths = config.my.configs.paths;
  # 🚀 SSoT: Encoding Config
  encodingXml = pkgs.writeText "encoding.xml" ''
    <?xml version="1.0" encoding="utf-8"?>
    <EncodingOptions xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
      <HardwareAccelerationType>qsv</HardwareAccelerationType>
      <OpenclDevice>/dev/dri/renderD128</OpenclDevice>
      <EnableThrottling>true</EnableThrottling>
      <EnableTonemapping>true</EnableTonemapping>
      <EnableSubtitleExtraction>true</EnableSubtitleExtraction>
      <EnableHardwareEncoding>true</EnableHardwareEncoding>
      <EnableIntelLowPowerH264HwEncoder>true</EnableIntelLowPowerH264HwEncoder>
      <EnableIntelLowPowerHevcHwEncoder>true</EnableIntelLowPowerHevcHwEncoder>
      <HardwareDecodingCodecs>
        <string>h264</string><string>hevc</string><string>mpeg2</string>
        <string>vc1</string><string>vp8</string><string>vp9</string>
        <string>hevc10bit</string>
      </HardwareDecodingCodecs>
    </EncodingOptions>
  '';
in
{
  imports = [
    ((import ./_lib.nix { inherit lib pkgs; }) {
      name = "jellyfin";
      port = config.my.ports.jellyfin;
      stateOption = "dataDir";
      defaultStateDir = "${srePaths.stateDir}/jellyfin";
    })
  ];

  config = lib.mkIf cfg.enable {
    services.jellyfin = {
      # 🚀 Option Exhaustion
      group = "media";
    };

    systemd.services.jellyfin = {
      environment = {
        OCL_ICD_VENDORS = "intel";
        LIBVA_DRIVER_NAME = "iHD";
      };

      preStart = ''
        mkdir -p ${srePaths.stateDir}/jellyfin/config
        if [ ! -f ${srePaths.stateDir}/jellyfin/config/encoding.xml ]; then
          cp ${encodingXml} ${srePaths.stateDir}/jellyfin/config/encoding.xml
          chown jellyfin:media ${srePaths.stateDir}/jellyfin/config/encoding.xml
        fi
      '';

      serviceConfig = {
        # 🛡️ SRE Hardware Isolation
        PrivateDevices = lib.mkForce false;
        DeviceAllow = [ "/dev/dri/renderD128 rw" ];
        
        # Resources (Jellyfin braucht mehr RAM für Transcoding)
        MemoryMax = lib.mkForce "4G";
        CPUWeight = lib.mkForce 80;
        
        # Network Hardening (Jellyfin ist NICHT via VPN isoliert für lokale Discovery)
        IPAddressDeny = [ "any" ];
        IPAddressAllow = [ "127.0.0.1/8" "::1/128" "10.0.0.0/8" "192.168.0.0/16" "100.64.0.0/10" ];
      };
    };
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
