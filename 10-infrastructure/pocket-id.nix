/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-012
 *   title: "Pocket-ID (SRE Exhausted)"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: [NIXH-00-CORE-006, NIXH-00-CORE-018, NIXH-10-INF-002]
 *   downstream: [NIXH-10-INF-014]
 *   status: audited
 * summary: OIDC identity provider with automated bootstrap and aviation-grade hardening.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/pocket-id.nix
 * ---
 */
{ config, lib, ... }:
let
  cfg       = config.my.profiles.services.pocket-id;
  # source: CFG.identity.domain    → 00-core/configs.nix
  domain    = config.my.configs.identity.domain;
  # source: CFG.identity.subdomain → 00-core/configs.nix
  subdomain = config.my.configs.identity.subdomain;
  # source: PORT.pocketId → 00-core/ports.nix
  port      = config.my.ports.pocketId;
in
{
  config = lib.mkIf cfg.enable {
    # ⚠️ SECURITY TODO: public_registration = true nach Ersteinrichtung auf false setzen!
    # Schritt: Alle Admin-Accounts anlegen → dann hier auf false → nixos-rebuild switch
    warnings = lib.optional true
      "pocket-id: public_registration = true ist aktiv! Nach Ersteinrichtung auf false setzen.";

    services.pocket-id = {
      enable  = true;
      dataDir = "/var/lib/pocket-id";
      settings = {
        issuer              = lib.mkForce "https://auth.${subdomain}.${domain}";
        title               = "m7c5 Login";
        # TODO: Nach Ersteinrichtung auf false setzen (siehe Warning oben)
        public_registration = true;
      };
    };

    systemd.services.pocket-id.serviceConfig = {
      ProtectSystem         = "strict";
      ProtectHome           = true;
      PrivateTmp            = true;
      PrivateDevices        = true;
      NoNewPrivileges       = true;
      LockPersonality       = true;
      ProtectControlGroups  = true;
      ProtectKernelModules  = true;
      ProtectKernelTunables = true;
      RestrictRealtime      = true;
      RestrictSUIDSGID      = true;
      Restart               = "always";
      RestartSec            = "5s";
      OOMScoreAdjust        = -100;
    };

    services.caddy.virtualHosts."auth.${subdomain}.${domain}" = {
      extraConfig = ''
        # Pocket-ID: Kein SSO-Wrapper (ist selbst der Identity Provider)
        reverse_proxy 127.0.0.1:${toString port}
      '';
    };
  };
}

/**
 * ---
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 *   complexity_score: 2
 *   changes_from_previous:
 *     - SECURITY: warnings[] für public_registration = true ergänzt
 *     - TODO-Kommentar für Post-Setup Deaktivierung
 *     - Architecture-Header downstream → sso.nix
 *     - source-id Kommentare ergänzt
 * ---
 */
