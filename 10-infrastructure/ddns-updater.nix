/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-006
 *   title: "Ddns Updater"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: [NIXH-00-CORE-006, NIXH-00-CORE-018, NIXH-10-INF-002]
 *   downstream: []
 *   status: audited
 * ---
 */
{ config, ... }:
let
  # source: CFG.identity.domain → 00-core/configs.nix
  domain = config.my.configs.identity.domain;
  # source: PORT.ddnsUpdater → 00-core/ports.nix  (ERGÄNZEN: ddnsUpdater = 10100)
  port   = config.my.ports.ddnsUpdater;
in
{
  services.ddns-updater = {
    enable = true;
    environment = {
      LISTENING_ADDRESS = ":${toString port}";
      PERIOD            = "10m";
      # Secrets via environmentFile — nicht hier hardkodieren
      # Cloudflare-Token wird via DDNS_UPDATER__CLOUDFLARE_TOKEN gesetzt
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
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 *   complexity_score: 1
 *   changes_from_previous:
 *     - source-id Kommentar für PORT.ddnsUpdater (Port muss in ports.nix ergänzt werden)
 *     - Architecture-Header ergänzt
 *     - Hinweis auf secrets via environmentFile
 * ---
 */
