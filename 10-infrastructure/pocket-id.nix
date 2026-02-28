/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-012
 *   title: "Pocket Id"
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
 *   checksum: sha256:19cf6ca85be6fa0bd2d249857e165cd3adbeed09b3b68ba8f14cc862f1c93d1a
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
