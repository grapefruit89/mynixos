/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-013
 *   title: "Readeck (SRE Hardened)"
 *   layer: 20
 * summary: Self-hosted 'read-it-later' service, tightly sandboxed with DynamicUser.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/readeck.nix
 * ---
 */
{ config, lib, pkgs, ... }:
let
  port = config.my.ports.readeck;
  domain = config.my.configs.identity.domain;
in
{
  # 🚀 READECK EXHAUSTION
  services.readeck = {
    enable = true;
    
    # ── DEKLARATIVE CONFIG ─────────────────────────────────────────────────
    settings = {
      server.host = "127.0.0.1";
      server.port = port;
      # SRE: Performance & Logging
      log.level = "info";
    };

    # Secret Handling (Secret Key)
    environmentFile = config.sops.secrets.readeck_env.path;
  };

  # ── CADDY INTEGRATION ────────────────────────────────────────────────────
  services.caddy.virtualHosts."read.${domain}" = {
    extraConfig = ''
      import sso_auth
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };

  # ── SRE SANDBOXING (Level: High) ─────────────────────────────────────────
  systemd.services.readeck.serviceConfig = {
    # Aus nixpkgs übernommen: Maximale Isolation
    DynamicUser = true;
    ProtectSystem = "full";
    ProtectHome = true;
    PrivateTmp = true;
    PrivateDevices = true;
    
    # System-Call Filter
    SystemCallFilter = [ "@system-service" "~@privileged" ];
    
    # OOM-Schutz
    OOMScoreAdjust = 300;
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
