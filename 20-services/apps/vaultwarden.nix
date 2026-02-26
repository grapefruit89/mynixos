{ config, lib, pkgs, ... }:
let
  # source-id: CFG.identity.domain
  domain = config.my.configs.identity.domain;
in
{
  services.vaultwarden = {
    enable = true;
    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = config.my.ports.vaultwarden;
    };
  };

  # [SEC-VAULTWARDEN-SVC-001] systemd Härtung für Vaultwarden
  systemd.services.vaultwarden.serviceConfig = {
    # Vaultwarden hat keinen DynamicUser — explizite Härtung nötig
    NoNewPrivileges = lib.mkForce true;
    PrivateTmp = lib.mkForce true;
    PrivateDevices = lib.mkForce true;

    ProtectSystem = lib.mkForce "strict";
    ReadWritePaths = [
      "/var/lib/vaultwarden"
    ];
    ProtectHome = lib.mkForce true;

    ProtectKernelTunables = lib.mkForce true;
    ProtectKernelModules = lib.mkForce true;
    ProtectControlGroups = lib.mkForce true;
    RestrictRealtime = lib.mkForce true;
    RestrictSUIDSGID = lib.mkForce true;

    # Vaultwarden braucht nur TCP für localhost
    RestrictAddressFamilies = [ "AF_INET" "AF_UNIX" ];

    MemoryDenyWriteExecute = true;

    # Syscall-Filter
    SystemCallFilter = [
      "@system-service"
      "~@privileged"
      "~@resources"
    ];
    SystemCallArchitectures = "native";
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.vaultwarden = {
      rule = "Host(`vault.${domain}`) || Host(`vaultwarden.${domain}`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [ "secured-chain@file" ];
      service = "vaultwarden";
    };
    services.vaultwarden.loadBalancer.servers = [{
      url = "http://127.0.0.1:${toString config.my.ports.vaultwarden}";
    }];
  };
}
