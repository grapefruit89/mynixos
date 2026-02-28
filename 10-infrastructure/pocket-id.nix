{ config, lib, ... }:
let
  cfg = config.my.profiles.services.pocket-id;
  domain = config.my.configs.identity.domain;
  port = config.my.ports.pocketId;
in
{
  config = lib.mkIf cfg.enable {
    services.pocket-id = {
      enable = true;
      dataDir = "/var/lib/pocket-id";
      settings = {
        issuer = "https://auth.${domain}";
        title = "m7c5 Login";
      };
    };

    services.caddy.virtualHosts."auth.${domain}" = {
      extraConfig = ''
        reverse_proxy 127.0.0.1:${toString port}
      '';
    };
  };
}
