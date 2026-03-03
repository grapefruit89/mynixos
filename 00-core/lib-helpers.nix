{ lib, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-00-SYS-LIB-001";
    title = "Global Service Helpers";
    description = "Central library providing the mkService abstraction for consistent configuration.";
    layer = 00;
    nixpkgs.category = "tools/admin";
    capabilities = [ "architecture/abstraction" "system/hardening" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 3;
  };

  dnsMap = import ../10-gateway/dns-map.nix;
in
{
  options.my.meta.lib_helpers = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for lib-helpers module";
  };

  options.my.lib.mkService = lib.mkOption {
    type = lib.types.unspecified;
    default = { 
      config,
      name, 
      port ? null,
      useSSO ? true, 
      description ? "Managed Service",
      readWritePaths ? [],
      allowNetwork ? true,
      netns ? null 
    }: let
      finalPort = if port != null then port 
                  else if config.my.ports ? ${name} then config.my.ports.${name}
                  else throw "mkService: No port defined for ${name}";
      
      host = if dnsMap.dnsMapping ? ${name} 
             then dnsMap.dnsMapping.${name} 
             else "${name}.nix.${dnsMap.baseDomain}";
      
      target = "http://${if netns != null then "10.200.1.2" else "127.0.0.1"}:${toString finalPort}";

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
          NetworkNamespacePath = lib.mkIf (netns != null) "/run/netns/${netns}";
        };
      };

      services.caddy.virtualHosts."${host}" = {
        extraConfig = ''
          @trusted_network remote_ip 127.0.0.1 100.64.0.0/10 ${lib.concatStringsSep " " config.my.configs.network.lanCidrs}
          handle @trusted_network {
            reverse_proxy ${target}
          }
          ${lib.optionalString useSSO "import sso_auth"}
          reverse_proxy ${target}
        '';
      };
    };
  };
}
