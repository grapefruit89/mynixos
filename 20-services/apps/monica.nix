{ config, ... }:
let
  port = config.my.ports.monica;
  host = "nix-monica.m7c5.de";
  appKeyFile = "/var/lib/monica/app-key";
in
{
  # source: my.ports.monica + ${appKeyFile}
  # sink: services.monica (phpfpm+nginx localhost) + services.traefik router/service
  services.monica = {
    enable = true;
    hostname = host;
    appURL = "https://${host}";
    inherit appKeyFile;

    # Monica's upstream module uses nginx; keep it local-only behind Traefik.
    nginx = {
      forceSSL = false;
      enableACME = false;
      addSSL = false;
      onlySSL = false;
      listen = [
        {
          addr = "127.0.0.1";
          inherit port;
          ssl = false;
        }
      ];
    };
  };

  # source: appKeyFile path
  # sink: readable by monica-setup service user
  system.activationScripts.monicaAppKeyFile.text = ''
    set -eu
    install -d -m 0750 -o monica -g monica /var/lib/monica
    if [ ! -s ${appKeyFile} ]; then
      head -c 32 /dev/urandom | base64 > ${appKeyFile}
    fi
    chown monica:monica ${appKeyFile}
    chmod 0600 ${appKeyFile}
  '';

  services.traefik.dynamicConfigOptions.http = {
    routers.monica = {
      rule = "Host(`${host}`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secure-headers@file" ];
      service = "monica";
    };
    services.monica.loadBalancer.servers = [
      { url = "http://127.0.0.1:${toString port}"; }
    ];
  };
}
