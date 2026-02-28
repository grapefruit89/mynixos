/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-005
 *   title: "Cockpit"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.services.cockpit;
  domain = config.my.configs.identity.domain;
  port = config.my.ports.cockpit;
in
{
  config = lib.mkIf cfg.enable {
    # 🚀 COCKPIT EXHAUSTION
    services.cockpit = {
      enable = true;
      port = port;
      package = pkgs.cockpit; # Standard-Paket
      
      # DEKLARATIVE EINSTELLUNGEN
      settings = {
        WebService = {
          AllowUnencrypted = true;
          ProtocolHeader = "X-Forwarded-Proto";
          MaxStartups = 10;
        };
        Session = {
          IdleTimeout = 15; # 15 Min Inaktivität
          Banner = "/etc/motd";
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
 *   checksum: sha256:edf9770ae7d7a334c4f44c2705fe248ae8134464ffa42f6791fba73a54ec7db3
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
