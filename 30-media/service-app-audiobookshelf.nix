/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-002
 *   title: "Audiobookshelf (SRE Hardened)"
 *   layer: 20
 * summary: Purposed-built audiobook and podcast server with standardized storage paths.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/audiobookshelf.nix
 * ---
 */
{ config, lib, ... }:
let
  port = config.my.ports.audiobookshelf;
  domain = config.my.configs.identity.domain;
in
{
  # 🚀 AUDIOBOOKSHELF EXHAUSTION
  services.audiobookshelf = {
    enable = true;
    host = "127.0.0.1";
    port = port;
    group = "media"; # SRE Standard Gruppe
  };

  # ── CADDY INTEGRATION ────────────────────────────────────────────────────
  services.caddy.virtualHosts."abs.${domain}" = {
    extraConfig = ''
      import sso_auth
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };

  # ── SRE SANDBOXING (Level: High) ─────────────────────────────────────────
  systemd.services.audiobookshelf.serviceConfig = {
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    PrivateDevices = true;
    
    # 🚀 ZUGRIFFSPFADE (Standardisiert)
    ReadWritePaths = [ 
      "/var/lib/audiobookshelf" 
      "/mnt/media/books" 
      "/mnt/media/podcasts" 
    ];
    
    NoNewPrivileges = true;
    SystemCallFilter = [ "@system-service" "~@privileged" ];
    
    OOMScoreAdjust = -100;
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
