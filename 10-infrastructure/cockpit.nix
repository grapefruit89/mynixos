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
 *   checksum: sha256:2ac06417471350b467324c43e849366a08e09bf42e7df6726ed88a9bf317d3aa
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
