{ config, lib, ... }:
let
  myLib = import ../../lib/helpers.nix { inherit lib; };
  port = config.my.ports.n8n;
  serviceBase = myLib.mkService {
    inherit config;
    name = "n8n";
    port = port;
    useSSO = false;
    description = "Workflow Automation";
  };
in
lib.mkMerge [
  serviceBase
  {
    services.n8n = {
      enable = true;
      environment = {
        N8N_PORT = toString port;
        N8N_HOST = "127.0.0.1";
        N8N_EDITOR_BASE_URL = "https://n8n.${config.my.configs.identity.domain}";
        EXECUTIONS_DATA_PRUNE = "true";
        EXECUTIONS_DATA_MAX_AGE = "336";
      };
    };

    systemd.services.n8n.serviceConfig = {
      ProtectSystem = lib.mkForce "strict";
      ReadWritePaths = [ "/data/state/n8n" ];
    };
  }
]
