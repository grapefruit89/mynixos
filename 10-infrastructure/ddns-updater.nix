/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-006
 *   title: "Ddns Updater"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ config, ... }:
let
  domain = config.my.configs.identity.domain;
  port = config.my.ports.ddnsUpdater;
in
{
  services.ddns-updater = {
    enable = true;
    environment = {
      LISTENING_ADDRESS = ":${toString port}";
      PERIOD = "10m";
    };
  };

  services.caddy.virtualHosts."nix-ddns.${domain}" = {
    extraConfig = ''
      import sso_auth
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };
}









/**
 * ---
 * technical_integrity:
 *   checksum: sha256:b66558301de96b596733ade18844a2dfa2a3caa950338e376343a6e5763c76d5
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
