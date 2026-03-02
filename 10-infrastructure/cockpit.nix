/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-005
 *   title: "Cockpit"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: [NIXH-00-CORE-006, NIXH-00-CORE-018, NIXH-10-INF-002]
 *   downstream: []
 *   status: audited
 * ---
 */
{ config, lib, pkgs, ... }:
let
  cfg    = config.my.profiles.services.cockpit;
  # source: CFG.identity.domain → 00-core/configs.nix
  domain = config.my.configs.identity.domain;
  # source: PORT.cockpit → 00-core/ports.nix  (NEU: Port registrieren!)
  port   = config.my.ports.cockpit;
in
{
  config = lib.mkIf cfg.enable {
    services.cockpit = {
      enable  = true;
      port    = port;
      package = pkgs.cockpit;

      settings = {
        WebService = {
          AllowUnencrypted   = true;         # Caddy übernimmt TLS
          ProtocolHeader     = "X-Forwarded-Proto";
          MaxStartups        = 10;
        };
        Session = {
          IdleTimeout = 15;
          Banner      = "/etc/motd";
        };
      };
    };

    services.caddy.virtualHosts."admin.${domain}" = {
      extraConfig = ''
        import sso_auth
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
 *   complexity_score: 1
 *   changes_from_previous:
 *     - NMS-ID FIX: NIXH-10-INF-010 → NIXH-10-INF-005 (Kollision mit olivetin.nix)
 *     - Architecture-Header ergänzt
 *     - source-id Kommentare für domain und port
 * ---
 */
