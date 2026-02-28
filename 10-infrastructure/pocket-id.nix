/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-10-NET-INFRA-012
 *   title: "Pocket Id"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   status: audited
 * ---
 */
{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.services.pocket-id;
  domain = config.my.configs.identity.domain;
  port = config.my.ports.pocketId;
in
{
  config = lib.mkIf cfg.enable {
    services.pocket-id = {
      enable = true;
      dataDir = "/var/lib/pocket-id";
      settings = {
        issuer = "https://auth.${domain}";
        title = "m7c5 Login";
      };
    };

    systemd.services.pocket-id = {
      serviceConfig = {
        Restart = "always";
        RestartSec = "5s";
        # Health-Endpoint für Caddy
        ExecStartPost = "${pkgs.coreutils}/bin/sleep 2";
      };
    };

    services.caddy.virtualHosts."auth.${domain}" = {
      extraConfig = ''
        reverse_proxy 127.0.0.1:${toString port}
      '';
    };
  };
}

/**
 * ---
 * technical_integrity:
 *   checksum: sha256:d0b69ae1983cf48e14e6d92745901dcf128dad68e5cd882ac1c977a3012ff68f
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
