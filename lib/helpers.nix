/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Global Service Helpers
 * TRACE-ID:     NIXH-CORE-033
 * PURPOSE:      Zentrale Abstraktion für die Erstellung von Diensten (mkService).
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [20-infrastructure/dns-map.nix, 10-core/configs.nix]
 * LAYER:        10-core
 * STATUS:       Stable
 */

{ lib, ... }:
let
  dnsMap = import ../20-infrastructure/dns-map.nix;
in
{
  # mkService: v3.1 (Caddy Migration + Metadata)
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
        # PRIORITÄT 1: LAN/Tailscale immer durchlassen (auth-unabhängig)
        @trusted_network remote_ip 127.0.0.1 100.64.0.0/10 ${lib.concatStringsSep " " config.my.configs.network.lanCidrs}
        handle @trusted_network {
          reverse_proxy ${target}
        }

        # PRIORITÄT 2: SSO für alle anderen (nur wenn useSSO)
        ${lib.optionalString useSSO ''
          import sso_auth
        ''}
        
        # FALLBACK
        reverse_proxy ${target}
      '';
    };
  };
}
