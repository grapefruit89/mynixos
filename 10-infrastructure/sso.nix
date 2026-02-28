/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-014
 *   title: "Sso"
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
  pocketIdPort = config.my.ports.pocketId;
  dnsMap = import ./dns-map.nix;
  allUrls = (map (h: "https://${h}") (lib.attrValues dnsMap.dnsMapping)) ++ [
    "https://auth.${domain}/callback"
    "https://*.nix.${domain}/*"
  ];
in
{
  config = lib.mkIf cfg.enable {
    services.pocket-id.settings = {
      issuer = "https://auth.${domain}";
      title = "m7c5 Login";
      allowed_redirect_urls = lib.concatStringsSep "," allUrls;
      session_ttl_seconds = 86400;
      refresh_token_ttl_seconds = 2592000;
      require_verified_email = false;
    };
    
    services.caddy.virtualHosts."netdata.${domain}" = {
      extraConfig = ''
        import sso_auth
        reverse_proxy 127.0.0.1:${toString config.my.ports.netdata}
      '';
    };
    
    systemd.services.pocket-id-bootstrap = {
      description = "Pocket-ID Admin User Bootstrap";
      after = [ "pocket-id.service" ];
      wantedBy = [ "multi-user.target" ];
      unitConfig.ConditionPathExists = "!/var/lib/pocket-id/.bootstrapped";
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
      script = ''
        set -euo pipefail
        for i in {1..30}; do
          if ${pkgs.curl}/bin/curl -sf http://127.0.0.1:${toString pocketIdPort}/health >/dev/null 2>&1; then
            break
          fi
          sleep 2
        done
        ${pkgs.coreutils}/bin/touch /var/lib/pocket-id/.bootstrapped
      '';
    };
  };
}












/**
 * ---
 * technical_integrity:
 *   checksum: sha256:7e6bb4918b741420eba55f33b6169e1da8656271fc75578ebbb965880bae7de7
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
