{ lib, pkgs, config, ... }:
{
  imports = [
    ((import ./_lib.nix { inherit lib; }) {
      name = "jellyfin";
      port = config.my.ports.jellyfin;
      stateOption = "dataDir";
      defaultStateDir = "/var/lib/jellyfin";
    })
  ];

  config = lib.mkIf config.my.media.jellyfin.enable {
    hardware.graphics.enable = true;
    hardware.graphics.extraPackages = with pkgs; [
      intel-media-driver    # iHD für UHD 630 (Gen 9.5)
      intel-compute-runtime # OpenCL für tone-mapping
    ];

    # LIBVA_DRIVER_NAME explizit setzen — verhindert Driver-Confusion
    environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

    users.users.jellyfin.extraGroups = [ "video" "render" ];

    # [SEC-JELLYFIN-SVC-001] systemd Härtung für Jellyfin
    systemd.services.jellyfin.serviceConfig = {
      NoNewPrivileges = lib.mkForce true;
      PrivateTmp = lib.mkForce true;

      # Jellyfin braucht /dev/dri/* für Hardware-Transcoding
      DeviceAllow = [
        "/dev/dri rw"
        "/dev/dri/renderD128 rw"
      ];

      ProtectSystem = lib.mkForce "strict";
      ReadWritePaths = [
        "/var/lib/jellyfin"
        "/data/media"
      ];
      ProtectHome = lib.mkForce true;

      ProtectKernelTunables = lib.mkForce true;
      ProtectKernelModules = lib.mkForce true;
      ProtectControlGroups = lib.mkForce true;
      RestrictRealtime = lib.mkForce true;
      RestrictSUIDSGID = lib.mkForce true;

      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
    };
  };
}
