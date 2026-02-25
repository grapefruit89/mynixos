{ lib, config, ... }:
{
  imports = [
    ((import ./_lib.nix { inherit lib; }) {
      name = "jellyseerr";
      port = config.my.ports.jellyseerr;
      stateOption = "configDir";
      defaultStateDir = "/var/lib/jellyseerr/config";
      supportsUserGroup = false;
    })
  ];

  # Ensure stable user/group for Jellyseerr (DynamicUser causes UID drift -> EACCES).
  users.groups.jellyseerr = { };
  users.users.jellyseerr = {
    isSystemUser = true;
    group = "jellyseerr";
  };

  systemd.services.jellyseerr.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "jellyseerr";
    Group = "jellyseerr";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/jellyseerr 0750 jellyseerr jellyseerr - -"
    "d /var/lib/jellyseerr/config 0750 jellyseerr jellyseerr - -"
    "d /var/lib/jellyseerr/config/logs 0750 jellyseerr jellyseerr - -"
    "z /var/lib/jellyseerr - jellyseerr jellyseerr - -"
    "z /var/lib/jellyseerr/config - jellyseerr jellyseerr - -"
    "z /var/lib/jellyseerr/config/logs - jellyseerr jellyseerr - -"
  ];
}
