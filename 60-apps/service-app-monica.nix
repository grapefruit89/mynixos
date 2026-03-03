{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-20-SRV-008";
    title = "Monica (SRE Expert Edition)";
    description = "Personal CRM with declarative artisan management and secure PHP-FPM setup.";
    layer = 50;
    nixpkgs.category = "services/web-apps";
    capabilities = [ "web/crm" "security/php-fpm" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 3;
  };

  port = config.my.ports.monica;
  domain = config.my.configs.identity.domain;
  appKeyFile = "/var/lib/monica/app-key";
in
{
  options.my.meta.monica = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for monica module";
  };


  config = lib.mkIf config.my.services.monica.enable {
    services.monica = { enable = true; hostname = "monica.${domain}"; appURL = "https://monica.${domain}"; inherit appKeyFile; nginx.listen = [ { addr = "127.0.0.1"; port = port; ssl = false; } ]; database.createLocally = true; };
    services.caddy.virtualHosts."monica.${domain}" = { extraConfig = "import sso_auth\nreverse_proxy 127.0.0.1:${toString port}"; };
    system.activationScripts.monicaAppKeyFile.text = "install -d -m 0750 -o monica -g monica /var/lib/monica; if [ ! -s ${appKeyFile} ]; then head -c 32 /dev/urandom | base64 > ${appKeyFile}; fi";
    systemd.services.phpfpm-monica.serviceConfig = { ProtectSystem = "strict"; ProtectHome = true; PrivateTmp = true; PrivateDevices = true; ReadWritePaths = [ "/var/lib/monica" ]; };
  };
}
