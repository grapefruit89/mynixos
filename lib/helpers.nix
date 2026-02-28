{ lib, ... }:
let
  dnsMap = import ../10-infrastructure/dns-map.nix;
in
{
  # mkService: v3.0 (Caddy Migration)
  mkService = { 
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
    
    # Internal Target
    target = "http://${if netns != null then "10.200.1.2" else "127.0.0.1"}:${toString finalPort}";

  in {
    # ── SYSTEMD ─────────────────────────────────────────────────────────────
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

    # ── CADDY REVERSE PROXY ─────────────────────────────────────────────────
    services.caddy.virtualHosts."${host}" = {
      extraConfig = ''
        # BREAK-GLASS (Tailscale Bypass)
        @tailscale remote_ip 100.64.0.0/10
        handle @tailscale {
          reverse_proxy ${target}
        }

        # STANDARD AUTH (Pocket-ID)
        ${lib.optionalString useSSO "import sso_auth"}
        
        # FINAL PROXY
        reverse_proxy ${target}
      '';
    };
    
    # Deaktiviere Traefik-Konfigurationen, falls sie noch irgendwo existieren
    services.traefik.dynamicConfigOptions.http.routers."${name}" = lib.mkForce null;
    services.traefik.dynamicConfigOptions.http.services."${name}" = lib.mkForce null;
  };
}
