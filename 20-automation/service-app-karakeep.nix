/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-APP-015
 *   title: "Karakeep (SRE Hardened)"
 *   layer: 20
 * summary: Bookmark management tool with SRE sandboxing.
 * ---
 */
{ config, lib, pkgs, ... }:
let
  port = config.my.ports.karakeep;
  domain = config.my.configs.identity.domain;
in
{
  # 🚀 KARAKEEP EXHAUSTION
  services.karakeep = {
    enable = true;
    extraEnvironment = {
      PORT = toString port;
      # SRE: Privacy & Security
      DISABLE_SIGNUPS = "true";
    };
  };

  # ── CADDY INTEGRATION ────────────────────────────────────────────────────
  services.caddy.virtualHosts."bookmarks.${domain}" = {
    extraConfig = ''
      import sso_auth
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };

}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
