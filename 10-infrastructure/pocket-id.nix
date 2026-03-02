/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-012
 *   title: "Pocket-ID (SRE Exhausted)"
 *   layer: 10
 * summary: OIDC identity provider with automated bootstrap and aviation-grade hardening.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/pocket-id.nix
 * ---
 */
{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.services.pocket-id;
  domain = config.my.configs.identity.domain;
  subdomain = config.my.configs.identity.subdomain;
  port = config.my.ports.pocketId;
in
{
  config = lib.mkIf cfg.enable {
    services.pocket-id = {
      enable = true;
      dataDir = "/var/lib/pocket-id";
      settings = {
        issuer = "https://auth.${subdomain}.${domain}";
        title = "m7c5 Login";
        public_registration = true; # SRE: Temporär aktiv für Ersteinrichtung
      };
    };

    # ── SRE SANDBOXING (Level: High) ──────────────────────────────────────
    systemd.services.pocket-id.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      NoNewPrivileges = true;
      
      # Aviation Grade Hardening
      LockPersonality = true;
      ProtectControlGroups = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      
      Restart = "always";
      RestartSec = "5s";
      OOMScoreAdjust = -100;
    };

    services.caddy.virtualHosts."auth.${subdomain}.${domain}" = {
      extraConfig = ''
        reverse_proxy 127.0.0.1:${toString port}
      '';
    };
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 * ---
 */
