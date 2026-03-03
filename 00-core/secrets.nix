{
  config,
  lib,
  pkgs,
  ...
}: let
  # 🚀 NMS v4.1 Metadaten
  nms = {
    id = "NIXH-00-COR-028";
    title = "Secrets (SRE Master Mapper)";
    description = "Centralized secret-to-module mapping with NIXH-ID traceability.";
    layer = 00;
    nixpkgs.category = "system/security";
    capabilities = ["security/secrets" "sops/mapping"];
    audit.last_reviewed = "2026-03-03";
    audit.complexity = 3;
  };

  # 🗺️ Strukturierte Secret-Map (NIXH-ID -> SOPS-Key)
  secretMap = {
    "NIXH-40-MED-017" = "sonarr_api_key";
    "NIXH-40-MED-012" = "radarr_api_key";
    "NIXH-40-MED-013" = "readarr_api_key";
    "NIXH-60-APP-007" = "vaultwarden_env";
    "NIXH-50-KNW-005" = "linkwarden_env";
    "NIXH-10-GTW-002" = "cloudflare_token";
  };
in {
  options.my.meta.secrets = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
  };

  options.my.secrets.files = {
    sharedEnv = lib.mkOption {
      type = lib.types.path;
      default = config.sops.templates."shared-runtime.env".path;
    };
    mediaEnv = lib.mkOption {
      type = lib.types.path;
      default = config.sops.templates."media-stack.env".path;
    };
  };

  config = {
    sops = {
      defaultSopsFile = ../secrets.yaml;
      defaultSopsFormat = "yaml";
      age = {
        sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
      };
      secrets = {
        unraid_root_password = {};
        ssh_github_key = {};
        ssh_unraid_key = {};
        github_token = {};
        cloudflare_token = {};
        tailscale_token = {};
        wg_privado_private_key = {};
        sonarr_api_key = {};
        radarr_api_key = {};
        readarr_api_key = {};
        n8n_enc_key = {};
        vaultwarden_env = {};
        miniflux_admin_password = {};
        paperless_secret_key = {};
        readeck_env = {};
        linkwarden_env = {}; # 🚀 Neu für NIXH-50-KNW-005
      };

      templates."shared-runtime.env" = {
        owner = config.my.configs.identity.user;
        mode = "0400";
        content = ''
          GITHUB_TOKEN="${config.sops.placeholder.github_token}"
          CLOUDFLARE_TOKEN="${config.sops.placeholder.cloudflare_token}"
          TAILSCALE_TOKEN="${config.sops.placeholder.tailscale_token}"
          UNRAID_PASS="${config.sops.placeholder.unraid_root_password}"
        '';
      };

      templates."media-stack.env" = {
        owner = "root";
        group = "media";
        mode = "0440";
        content = ''
          SONARR_API_KEY="${config.sops.placeholder.sonarr_api_key}"
          RADARR_API_KEY="${config.sops.placeholder.radarr_api_key}"
          READARR_API_KEY="${config.sops.placeholder.readarr_api_key}"
        '';
      };

      templates."caddy-env" = {
        owner = "caddy";
        mode = "0400";
        content = ''
          CLOUDFLARE_API_TOKEN="${config.sops.placeholder.cloudflare_token}"
        '';
      };
    };
    environment.systemPackages = [pkgs.age-plugin-tpm];
  };
}
/**
* ---
 * technical_integrity:
 *   checksum: sha256:d49e6af93bb770d4e3327052787d44b5c6784de52de0595b96749aa4fdb66e99
 *   eof_marker: NIXHOME_VALID_EOF* ---
*/

