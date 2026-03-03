{ config, lib, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-60-APP-003";
    title = "Filebrowser (SRE Hardened)";
    description = "Web-based file manager with strict path restrictions and sandboxing.";
    layer = 60;
    nixpkgs.category = "services/web-apps";
    capabilities = [ "web/file-management" "security/sandboxing" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

  port = config.my.ports.filebrowser;
  domain = config.my.configs.identity.domain;
in
{
  options.my.meta.filebrowser = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for filebrowser module";
  };


  config = lib.mkIf config.my.services.filebrowser.enable {
    services.filebrowser = { enable = true; settings = { port = port; address = "127.0.0.1"; root = "/mnt/storage"; }; };
    services.caddy.virtualHosts."files.${domain}" = { extraConfig = "import sso_auth\nreverse_proxy 127.0.0.1:${toString port}"; };
    systemd.services.filebrowser.serviceConfig = { ProtectSystem = "strict"; ProtectHome = true; PrivateTmp = true; PrivateDevices = true; ReadWritePaths = [ "/var/lib/filebrowser" "/mnt/storage" ]; NoNewPrivileges = true; SystemCallFilter = [ "@system-service" "~@privileged" ]; };
  };
}
