{ lib, ... }:
let
  dnsMap = import ../10-infrastructure/dns-map.nix;
in
{
  # mkService: v2.3 (Confinement Ready)
  mkService = { 
    config,
    name, 
    port ? null,
    useSSO ? true, 
    description ? "Managed Service",
    readWritePaths ? [],
    allowNetwork ? true,
    netns ? null # NEW: Optionaler Network-Namespace
  }: let
    finalPort = if port != null then port 
                else if config.my.ports ? ${name} then config.my.ports.${name}
                else throw "mkService: No port defined for ${name}";
  in {
    systemd.services."${name}" = {
      serviceConfig = {
        Description = lib.mkDefault description;
        ProtectSystem = lib.mkDefault "strict";
        ProtectHome = lib.mkDefault true;
        PrivateTmp = lib.mkDefault true;
        PrivateDevices = lib.mkDefault true;
        NoNewPrivileges = lib.mkDefault true;
        Restart = lib.mkDefault "always";
        ReadWritePaths = lib.mkDefault readWritePaths;
        
        # NAMESPACE INJECTION
        NetworkNamespacePath = lib.mkIf (netns != null) "/run/netns/${netns}";
      };
    };

    services.traefik.dynamicConfigOptions.http = {
      routers."${name}" = {
        rule = lib.mkDefault (let
          host = if dnsMap.dnsMapping ? ${name} 
                 then dnsMap.dnsMapping.${name} 
                 else "${name}.nix.${dnsMap.baseDomain}";
        in "Host(`${host}`)");
        service = name;
        entryPoints = lib.mkDefault [ "websecure" ];
        tls.certResolver = lib.mkDefault "letsencrypt";
        middlewares = lib.mkDefault (if useSSO then [ "sso-chain@file" ] else [ "secured-chain@file" ]);
      };
      # ROUTING HINWEIS: Wenn netns aktiv ist, muss die IP hier auf das veth-Interface (10.200.1.2) zeigen.
      services."${name}".loadBalancer.servers = lib.mkDefault [{ 
        url = "http://${if netns != null then "10.200.1.2" else "127.0.0.1"}:${toString finalPort}"; 
      }];
    };
  };
}
