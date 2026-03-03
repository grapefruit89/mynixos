{ config, lib, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-20-SRV-007";
    title = "Miniflux (SRE Exhausted)";
    description = "Minimalist RSS reader with Wake-on-Access (Socket Activation).";
    layer = 40;
    nixpkgs.category = "services/web-apps";
    capabilities = [ "web/rss" "security/socket-activation" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

  port = config.my.ports.miniflux;
  domain = config.my.configs.identity.domain;
in
{
  options.my.meta.miniflux = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for miniflux module";
  };


  config = lib.mkIf config.my.services.miniflux.enable {
    services.miniflux = {
      enable = true; config = { LISTEN_ADDR = "fd://3"; WATCHDOG = 1; RUN_MIGRATIONS = 1; ADMIN_USERNAME = "admin"; };
      createDatabaseLocally = true; adminCredentialsFile = config.sops.secrets.miniflux_admin_password.path;
    };
    systemd.sockets.miniflux = { description = "Miniflux Socket"; wantedBy = [ "sockets.target" ]; listenStreams = [ (toString port) ]; };
    systemd.services.miniflux = {
      wantedBy = lib.mkForce [ ]; requires = [ "miniflux.socket" ]; after = [ "miniflux.socket" ];
      serviceConfig = { DynamicUser = true; ProtectSystem = "strict"; ProtectHome = true; PrivateTmp = true; PrivateDevices = true; SystemCallFilter = [ "@system-service" "~@privileged" ]; OOMScoreAdjust = 500; };
    };
  };
}
