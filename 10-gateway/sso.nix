{ config, lib, pkgs, ... }:
let
  nms = { id = "NIXH-10-INF-014"; title = "SSO"; description = "SSO config."; layer = 10; nixpkgs.category = "services/security"; capabilities = [ "security/sso" ]; audit.last_reviewed = "2026-03-02"; audit.complexity = 2; };
  cfg = config.my.services.pocketId;
  domain = config.my.configs.identity.domain;
  pocketIdPort = config.my.ports.pocketId;
  dnsMap = import ./dns-map.nix;
  allUrls = (map (h: "https://${h}") (lib.attrValues dnsMap.dnsMapping)) ++ [ "https://auth.${domain}/callback" ];
in
{
  options.my.meta.sso = lib.mkOption { type = lib.types.attrs; default = nms; readOnly = true; };
  config = lib.mkIf cfg.enable {
    services.pocket-id.settings = { issuer = "https://auth.${domain}"; title = "m7c5 Login"; allowed_redirect_urls = lib.concatStringsSep "," allUrls; session_ttl_seconds = 86400; };
    systemd.services.pocket-id-bootstrap = {
      description = "Pocket-ID Bootstrap"; after = [ "pocket-id.service" ]; wantedBy = [ "multi-user.target" ]; unitConfig.ConditionPathExists = "!/var/lib/pocket-id/.bootstrapped";
      serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
      script = "sleep 2; touch /var/lib/pocket-id/.bootstrapped";
    };
  };
}
