/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-APP-015
 *   title: "Karakeep"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-APP]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ config, lib, pkgs, ... }:
let
  port = config.my.ports.karakeep;
  domain = config.my.configs.identity.domain;
  host = "bookmarks.nix.${domain}";
in
{
  services.karakeep = {
    enable = true;
    extraEnvironment = {
      PORT = toString port;
      # Disable signups for security if needed
      # DISABLE_SIGNUPS = "true";
    };
  };

  # Reverse Proxy
  services.caddy.virtualHosts."${host}" = {
    extraConfig = ''
      import sso_auth
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };
}

/**
 * ---
 * technical_integrity:
 *   checksum: sha256:f953c986c9742dbd1fb724cb6403cc6d556ad648b0191dc7e28dbf42ca465c75
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
