/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-10-NET-INFRA-005
 *   title: "Cockpit"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
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
    services.cockpit = {
      enable = true;
      port = port;
      settings = {
        WebService = {
          AllowUnencrypted = true;
          ProtocolHeader = "X-Forwarded-Proto";
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
 *   checksum: sha256:751a03f406f69d4c8f43e33abf1274232f00d4958fa4094ef110a6005f89bf02
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
