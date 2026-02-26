{ config, lib, pkgs, ... }:
let
  # source-id: CFG.identity.domain
  domain = config.my.configs.identity.domain;
in
{
  services.n8n = {
    enable = true;
    environment = {
      N8N_PORT = toString config.my.ports.n8n;
      N8N_HOST = "127.0.0.1";
      N8N_EDITOR_BASE_URL = "https://n8n.${domain}";
      EXECUTIONS_DATA_PRUNE = "true";
      EXECUTIONS_DATA_MAX_AGE = "336";  # 14 Tage
    };
  };

  # [SEC-N8N-SVC-001] systemd Härtung für n8n
  systemd.services.n8n.serviceConfig = {
    NoNewPrivileges = lib.mkForce true;
    PrivateTmp = lib.mkForce true;
    PrivateDevices = lib.mkForce true;

    ProtectSystem = lib.mkForce "strict";
    ReadWritePaths = [
      "/data/state/n8n"
    ];
    ProtectHome = lib.mkForce true;

    ProtectKernelTunables = lib.mkForce true;
    ProtectKernelModules = lib.mkForce true;
    ProtectControlGroups = lib.mkForce true;
    RestrictRealtime = lib.mkForce true;
    RestrictSUIDSGID = lib.mkForce true;

    RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];

    SystemCallFilter = [
      "@system-service"
      "@process"
      "~@privileged"
    ];
    SystemCallArchitectures = "native";
  };

  # Traefik Integration für n8n
  services.traefik.dynamicConfigOptions.http = {
    routers.n8n = {
      rule = "Host(`n8n.${domain}`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secured-chain@file" ];
      service = "n8n";
    };
    services.n8n.loadBalancer.servers = [{
      url = "http://127.0.0.1:${toString config.my.ports.n8n}";
    }];
  };
}
