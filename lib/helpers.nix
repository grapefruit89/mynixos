{ lib, ... }:
let
  dnsMap = import ../10-infrastructure/dns-map.nix;
in
{
  # mkService: Der isomorphe Dienst-Generator
  mkService = { 
    config,
    name, 
    port, 
    useSSO ? true, 
    vpn ? false, 
    description ? "Managed Service" 
  }: {
    # Systemd Hardening (Aviation Grade)
    systemd.services."${name}".serviceConfig = {
      Description = lib.mkDefault description;
      ProtectSystem = lib.mkDefault "full";
      PrivateTmp = lib.mkDefault true;
      NoNewPrivileges = lib.mkDefault true;
      Restart = lib.mkDefault "always";
    };

    # Automatische Traefik-Konfiguration
    services.traefik.dynamicConfigOptions.http = {
      routers."${name}" = {
        rule = lib.mkDefault (let
          host = if dnsMap.dnsMapping ? ${name} 
                 then dnsMap.dnsMapping.${name} 
                 else "${name}.nix.${dnsMap.baseDomain}";
        in "Host(`${host}`)");
        service = lib.mkDefault name;
        entryPoints = lib.mkDefault [ "websecure" ];
        tls.certResolver = lib.mkDefault "letsencrypt";
        middlewares = lib.mkDefault (if useSSO then [ "sso-chain@file" ] else [ "secured-chain@file" ]);
      };
      services."${name}".loadBalancer.servers = lib.mkDefault [{ url = "http://127.0.0.1:${toString port}"; }];
    };
  };
}
