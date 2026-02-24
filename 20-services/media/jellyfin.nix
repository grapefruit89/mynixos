{ lib, pkgs, config, ... }:
{
  imports = [
    ((import ./_lib.nix { inherit lib; }) {
      name = "jellyfin";
      port = 8096;
      stateOption = "dataDir";
      defaultStateDir = "/var/lib/jellyfin";
    })
  ];

  config = lib.mkIf config.my.media.jellyfin.enable {
    hardware.graphics.enable = true;
    hardware.graphics.extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
    ];

    users.users.jellyfin.extraGroups = [ "video" "render" ];
  };
}
