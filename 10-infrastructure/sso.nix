/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-014
 *   title: "SSO (Pocket-ID Config)"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: [NIXH-00-CORE-006, NIXH-10-INF-012]
 *   downstream: []
 *   status: audited
 * ---
 */
{ config, lib, pkgs, ... }:
let
  cfg          = config.my.profiles.services.pocket-id;
  # source: CFG.identity.domain → 00-core/configs.nix
  domain       = config.my.configs.identity.domain;
  pocketIdPort = config.my.ports.pocketId;
  dnsMap       = import ./dns-map.nix;

  # Alle registrierten URLs als OIDC-Redirect-Whitelist
  allUrls = (map (h: "https://${h}") (lib.attrValues dnsMap.dnsMapping))
    ++ [ "https://auth.${domain}/callback" ];
in
{
  config = lib.mkIf cfg.enable {
    services.pocket-id.settings = {
      issuer                       = "https://auth.${domain}";
      title                        = "m7c5 Login";
      allowed_redirect_urls        = lib.concatStringsSep "," allUrls;
      session_ttl_seconds          = 86400;
      refresh_token_ttl_seconds    = 2592000;
      require_verified_email       = false;
    };

    # FIX: services.caddy.virtualHosts."netdata.${domain}" hier ENTFERNT.
    # Es war ein DUPLIKAT zu 10-infrastructure/netdata.nix!
    # Netdata-VirtualHost gehört in netdata.nix, nicht in sso.nix.

    systemd.services.pocket-id-bootstrap = {
      description = "Pocket-ID Erster-Start Bootstrap";
      after        = [ "pocket-id.service" ];
      wantedBy     = [ "multi-user.target" ];
      unitConfig.ConditionPathExists = "!/var/lib/pocket-id/.bootstrapped";
      serviceConfig = {
        Type             = "oneshot";
        RemainAfterExit  = true;
      };
      script = ''
        set -euo pipefail
        # Warte bis Pocket-ID erreichbar ist
        for i in $(seq 1 30); do
          if ${pkgs.curl}/bin/curl -sf \
            http://127.0.0.1:${toString pocketIdPort}/health >/dev/null 2>&1; then
            echo "Pocket-ID ist bereit."
            break
          fi
          echo "Warte auf Pocket-ID... ($i/30)"
          sleep 2
        done
        touch /var/lib/pocket-id/.bootstrapped
        echo "Bootstrap abgeschlossen."
      '';
    };
  };
}

/**
 * ---
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 *   complexity_score: 2
 *   changes_from_previous:
 *     - BUG FIX: services.caddy.virtualHosts."netdata.*" entfernt (Duplikat zu netdata.nix)
 *     - Bootstrap-Script: seq statt brace expansion (POSIX-kompatibler)
 *     - Architecture-Header ergänzt
 * ---
 */
