# meta:
#   owner: <owner-name>
#   status: draft | active
#   scope: shared | private
#   summary: <Kurze Beschreibung des Dienstes>
#   specIds: [<SPEC-ID-001>, ...] # Falls vorhanden

{ config, lib, pkgs, ... }:

let
  # 1. Konstanten & Lokale Variablen
  # source-id: CFG.identity.domain
  domain = config.my.configs.identity.domain;
  
  # source: 00-core/ports.nix
  servicePort = config.my.ports.<service-name>; # <-- In ports.nix definieren!
  
  serviceName = "<service-name>";
in
{
  # 2. Dienst-Konfiguration
  services.${serviceName} = {
    enable = true;
    # Weitere dienstspezifische Optionen hier...
  };

  # 3. Traefik Reverse-Proxy Integration
  services.traefik.dynamicConfigOptions.http = {
    routers.${serviceName} = {
      rule = "Host(`${serviceName}.${domain}`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secured-chain@file" ];
      service = serviceName;
    };
    services.${serviceName}.loadBalancer.servers = [{
      url = "http://127.0.0.1:${toString servicePort}";
    }];
  };

  # 4. Systemd-Härtung (Security Sandboxing)
  systemd.services.${serviceName}.serviceConfig = {
    # Basis-Schutz
    NoNewPrivileges = lib.mkForce true;
    PrivateTmp = lib.mkForce true;
    PrivateDevices = lib.mkForce true;
    ProtectHome = lib.mkForce true;
    ProtectSystem = lib.mkForce "strict";
    
    # Pfade, in die der Dienst schreiben darf
    ReadWritePaths = [
      "/var/lib/${serviceName}"
    ];

    # Kernel- & Ressourcenschutz
    ProtectKernelTunables = lib.mkForce true;
    ProtectKernelModules = lib.mkForce true;
    ProtectControlGroups = lib.mkForce true;
    RestrictRealtime = lib.mkForce true;
    RestrictSUIDSGID = lib.mkForce true;
    RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
  };
}
