/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-029
 *   title: "Recyclarr (SRE Declarative)"
 *   layer: 20
 * summary: Declarative management of Radarr/Sonarr quality profiles and custom formats.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/recyclarr.nix
 * ---
 */
{ config, lib, pkgs, ... }:
let
  domain = config.my.configs.identity.domain;
in
{
  # 🚀 RECYCLARR EXHAUSTION
  services.recyclarr = {
    enable = true;
    
    # ── DEKLARATIVE KONFIGURATION ──────────────────────────────────────────
    # SRE: Wir erzwingen Profile und Formate via Nix
    configuration = {
      sonarr = {
        tv = {
          base_url = "https://sonarr.${domain}";
          api_key = "!env_var SONARR_API_KEY";
          include = [
            { template = "v3-sonarr-web-dl-1080p-v2-remux-720p"; } # Standard SRE Template
          ];
        };
      };
      radarr = {
        movies = {
          base_url = "https://radarr.${domain}";
          api_key = "!env_var RADARR_API_KEY";
          include = [
            { template = "v3-radarr-web-dl-1080p-v2-remux-720p"; } # Standard SRE Template
          ];
        };
      };
    };
  };

  # 🔐 SECRETS WIRING
  # Recyclarr benötigt die API Keys von Sonarr/Radarr
  systemd.services.recyclarr = {
    serviceConfig = {
      LoadCredential = [
        "sonarr_api:${config.sops.secrets.sonarr_api_key.path}"
        "radarr_api:${config.sops.secrets.radarr_api_key.path}"
      ];
      # SRE: Environment Setup für YAML Macro (!env_var)
      Environment = [
        "SONARR_API_KEY_FILE=/run/credentials/recyclarr.service/sonarr_api"
        "RADARR_API_KEY_FILE=/run/credentials/recyclarr.service/radarr_api"
      ];
    };
  };

  # ── SRE SANDBOXING ───────────────────────────────────────────────────────
  systemd.services.recyclarr.serviceConfig = {
    ProtectSystem = "strict";
    PrivateTmp = true;
    NoNewPrivileges = true;
    MemoryMax = "512M"; # Recyclarr ist genügsam
    OOMScoreAdjust = 1000;
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 * ---
 */
