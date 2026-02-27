{ lib, ... }:
let
  dnsMap = import ../10-infrastructure/dns-map.nix;
in
{
  # mkService: The Isomorphic Service Generator (v2.2)
  # Standards: Zero-Trust Hardening, Auto-Port Injection, Traefik & SSO.
  mkService = { 
    config,
    name, 
    port ? null, # Optional: Auto-injected from config.my.ports if null
    useSSO ? true, 
    description ? "Managed Service",
    readWritePaths ? [],
    allowNetwork ? true
  }: let
    # AUTOMATIC PORT INJECTION (Fixes VIO-01)
    # Priority: 1. Explicit argument, 2. Port Registry, 3. Error
    finalPort = if port != null then port 
                else if config.my.ports ? ${name} then config.my.ports.${name}
                else throw "mkService: No port defined for service '${name}' in config.my.ports or as argument.";
  in {
    # Systemd Hardening (Aviation Grade)
    systemd.services."${name}".serviceConfig = {
      Description = lib.mkDefault description;
      ProtectSystem = lib.mkDefault "strict";
      ProtectHome = lib.mkDefault true;
      PrivateTmp = lib.mkDefault true;
      PrivateDevices = lib.mkDefault true;
      NoNewPrivileges = lib.mkDefault true;
      Restart = lib.mkDefault "always";
      
      # Security Toggles
      ProtectKernelTunables = lib.mkDefault true;
      ProtectKernelModules = lib.mkDefault true;
      ProtectControlGroups = lib.mkDefault true;
      RestrictRealtime = lib.mkDefault true;
      RestrictSUIDSGID = lib.mkDefault true;
      MemoryDenyWriteExecute = lib.mkDefault true;
      LockPersonality = lib.mkDefault true;
      
      # Sandbox dynamic paths
      ReadWritePaths = lib.mkDefault readWritePaths;
      
      # Network restriction
      RestrictAddressFamilies = lib.mkDefault (if allowNetwork then [ "AF_INET" "AF_INET6" "AF_UNIX" ] else [ "AF_UNIX" ]);
    };

    # Automatic Traefik Configuration
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
      services."${name}".loadBalancer.servers = lib.mkDefault [{ url = "http://127.0.0.1:${toString finalPort}"; }];
    };
  };
}
