{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-00-CORE-022";
    title = "Secrets (SRE Flat Source)";
    description = "Secure secret management using SOPS-nix with TPM integration and runtime environment templates.";
    layer = 00;
    nixpkgs.category = "system/security";
    capabilities = [ "security/secrets" "sops/nix" "tpm/integration" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 3;
  };
in
{
  options.my.meta.secrets = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for secrets module";
  };

  options.my.secrets = {
    files = {
      sharedEnv = lib.mkOption { type = lib.types.path; default = config.sops.templates."shared-runtime.env".path; };
      mediaEnv = lib.mkOption { type = lib.types.path; default = config.sops.templates."media-stack.env".path; };
    };
  };

  config = {
    sops = {
      defaultSopsFile = ../secrets.yaml;
      defaultSopsFormat = "yaml";
      age = { sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ]; keyFile = "/var/lib/sops-nix/key.txt"; generateKey = true; };
      secrets = {
        unraid_root_password = { owner = "root"; };
        ssh_github_key = { owner = "moritz"; };
        ssh_unraid_key = { owner = "moritz"; };
        github_token = { }; cloudflare_token = { }; tailscale_token = { }; wg_privado_private_key = { };
        sonarr_api_key = { owner = "sonarr"; }; radarr_api_key = { owner = "radarr"; }; readarr_api_key = { owner = "readarr"; };
        n8n_enc_key = { }; vaultwarden_env = { }; miniflux_admin_password = { }; paperless_secret_key = { };
      };
      templates."shared-runtime.env" = {
        owner = "moritz"; mode = "0400";
        content = ''
          GITHUB_TOKEN="${config.sops.placeholder.github_token}"
          CLOUDFLARE_TOKEN="${config.sops.placeholder.cloudflare_token}"
          TAILSCALE_TOKEN="${config.sops.placeholder.tailscale_token}"
          UNRAID_PASS="${config.sops.placeholder.unraid_root_password}"
        '';
      };
      templates."media-stack.env" = {
        owner = "root"; group = "media"; mode = "0440";
        content = ''
          SONARR_API_KEY="${config.sops.placeholder.sonarr_api_key}"
          RADARR_API_KEY="${config.sops.placeholder.radarr_api_key}"
          READARR_API_KEY="${config.sops.placeholder.readarr_api_key}"
        '';
      };
    };
    environment.systemPackages = [ pkgs.age-plugin-tpm ];
  };
}
