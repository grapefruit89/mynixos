{
  config,
  lib,
  ...
}: let
  # 🚀 NMS v4.2 Metadaten
  nms = {
    id = "NIXH-10-GTW-009";
    title = "Pocket-ID (OIDC Provider)";
    description = "Self-hosted OIDC identity provider for secure SSO with Caddy integration.";
    layer = 10;
    nixpkgs.category = "services/security";
    capabilities = ["security/oidc" "identity/provider"];
    audit.last_reviewed = "2026-03-03";
    audit.complexity = 2;
  };

  cfg = config.my.services.pocketId;
  domain = config.my.configs.identity.domain;
  subdomain = config.my.configs.identity.subdomain;
  port = config.my.ports.pocketId;
in {
  # 🧬 Audit-Compliance: Metadaten als echtes Nix-Attribut
  options.my.meta.pocketId = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
  };

  config = lib.mkIf cfg.enable {
    # SRE-Safety: SSO-Provider darf nur mit Reverse Proxy laufen.
    assertions = [
      {
        assertion = config.my.profiles.networking.reverseProxy == "caddy";
        message = "Pocket-ID requires Caddy as reverseProxy.";
      }
    ];

    warnings = ["pocket-id: public_registration = true ist aktiv!"];

    services.pocket-id = {
      enable = true;
      dataDir = "/var/lib/pocket-id";
      settings = {
        issuer = lib.mkForce "https://auth.${subdomain}.${domain}";
        title = "NixHome Identity";
        public_registration = true; # Für erste Einrichtung OK
      };
    };

    systemd.services.pocket-id.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      Restart = "always";
      RestartSec = "5s";
      OOMScoreAdjust = -100;
    };

    services.caddy.virtualHosts."auth.${subdomain}.${domain}" = {
      extraConfig = "reverse_proxy 127.0.0.1:${toString port}";
    };
  };
}
/**
* ---
 * technical_integrity:
 *   checksum: sha256:de8a637dd05ea65f391b52bd213e2344185d5094e7a07eae0c37d4c95509789d
 *   eof_marker: NIXHOME_VALID_EOF* ---
*/

