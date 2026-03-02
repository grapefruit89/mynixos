/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-021
 *   title: "Jellyfin (Expert Edition)"
 *   layer: 20
 * summary: Hardware-accelerated media server with declarative encoding logic.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/jellyfin.nix
 * ---
 */
{ lib, pkgs, config, ... }:
let
  cfg = config.my.media.jellyfin;
  # 🚀 DEKLARATIVES ENCODING (Extrahiert aus nixpkgs Patterns)
  # Dies brennt die optimalen Q958 (UHD 630) Settings direkt ins System.
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
        <string>h264</string>
        <string>hevc</string>
        <string>mpeg2</string>
        <string>vc1</string>
        <string>vp8</string>
        <string>vp9</string>
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
      defaultStateDir = "/var/lib/jellyfin";
    })
  ];

  config = lib.mkIf cfg.enable {
    users.users.jellyfin.extraGroups = [ "video" "render" ];
    
    # ── HARDWARE OPTIMIERUNG ────────────────────────────────────────────────
    systemd.services.jellyfin = {
      environment = {
        OCL_ICD_VENDORS = "intel";
        # Erzwingt den modernen iHD Treiber
        LIBVA_DRIVER_NAME = "iHD";
      };

      # Injektion der encoding.xml beim Start (Single Source of Truth)
      preStart = ''
        mkdir -p /var/lib/jellyfin/config
        if [ ! -f /var/lib/jellyfin/config/encoding.xml ]; then
          cp ${encodingXml} /var/lib/jellyfin/config/encoding.xml
          chown jellyfin:jellyfin /var/lib/jellyfin/config/encoding.xml
        fi
      '';

      # ── SRE SANDBOXING (Aviation Grade) ───────────────────────────────────
      serviceConfig = {
        # Hardware-Zugriff präzise einschränken
        PrivateDevices = lib.mkForce false;
        DeviceAllow = [ "/dev/dri/renderD128 rw" ];
        
        # Kernel & Process Isolation
        ProtectProc = "invisible";
        ProcSubset = "pid";
        RestrictNamespaces = true;
        ProtectControlGroups = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        LockPersonality = true;
        PrivateTmp = true;
        
        # System-Call Filter
        SystemCallFilter = [ "@system-service" "~@privileged" ];
        
        # Network Hardening (Nur interner Proxy-Traffic erlaubt)
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
