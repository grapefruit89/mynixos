/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-10-NET-INFRA-006
 *   title: "Ddns Updater"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
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
 *   checksum: sha256:d26aa0ccaa1035989cb2599cc5a3cfbe5fbc76b7e50fdf69a549370f05c6635a
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
