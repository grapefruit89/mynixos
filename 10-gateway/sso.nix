{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-10-INF-014";
    title = "SSO (Pocket-ID Config)";
    description = "Standardized SSO configuration using Pocket-ID as the backend.";
    layer = 10;
    nixpkgs.category = "services/security";
    capabilities = [ "security/sso" "identity/config" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

  cfg = config.my.profiles.services.pocket-id;
  domain = config.my.configs.identity.domain;
  pocketIdPort = config.my.ports.pocketId;
  dnsMap = import ./dns-map.nix;
  allUrls = (map (h: "https://${h}") (lib.attrValues dnsMap.dnsMapping)) ++ [ "https://auth.${domain}/callback" ];
in
{
  options.my.meta.sso = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for sso module";
  };

  config = lib.mkIf cfg.enable {
    services.pocket-id.settings = { issuer = "https://auth.${domain}"; title = "m7c5 Login"; allowed_redirect_urls = lib.concatStringsSep "," allUrls; session_ttl_seconds = 86400; refresh_token_ttl_seconds = 2592000; require_verified_email = false; };
    systemd.services.pocket-id-bootstrap = {
      description = "Pocket-ID Erster-Start Bootstrap";
      after = [ "pocket-id.service" ]; wantedBy = [ "multi-user.target" ]; unitConfig.ConditionPathExists = "!/var/lib/pocket-id/.bootstrapped";
      serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
      script = "set -euo pipefail; for i in $(seq 1 30); do if ${pkgs.curl}/bin/curl -sf http://127.0.0.1:${toString pocketIdPort}/health >/dev/null 2>&1; then break; fi; sleep 2; done; touch /var/lib/pocket-id/.bootstrapped";
    };
  };
}
