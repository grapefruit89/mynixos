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
 *   checksum: sha256:2dbe19571467d45f61a1383bbbf96e19708e899aa72e8afeb659d60c77bc303a
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
