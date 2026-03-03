{ config, lib, pkgs, ... }:
let
  nms = { id = "NIXH-00-CORE-022"; title = "Secrets"; description = "Secure secret management."; layer = 00; nixpkgs.category = "system/security"; capabilities = [ "security/secrets" ]; audit.last_reviewed = "2026-03-02"; audit.complexity = 3; };
in
{
  options.my.meta.secrets = lib.mkOption { type = lib.types.attrs; default = nms; readOnly = true; };
  options.my.secrets.files = {
    sharedEnv = lib.mkOption { type = lib.types.path; default = config.sops.templates."shared-runtime.env".path; };
    mediaEnv = lib.mkOption { type = lib.types.path; default = config.sops.templates."media-stack.env".path; };
  };
  config = {
    sops = {
      defaultSopsFile = ../secrets.yaml; defaultSopsFormat = "yaml";
      age = { sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ]; keyFile = "/var/lib/sops-nix/key.txt"; generateKey = true; };
      secrets = {
        unraid_root_password = { }; ssh_github_key = { }; ssh_unraid_key = { };
        github_token = { }; cloudflare_token = { }; tailscale_token = { }; wg_privado_private_key = { };
        sonarr_api_key = { }; radarr_api_key = { }; readarr_api_key = { };
        n8n_enc_key = { }; vaultwarden_env = { }; miniflux_admin_password = { }; paperless_secret_key = { }; readeck_env = { };
      };
      templates."shared-runtime.env" = { owner = config.my.configs.identity.user; mode = "0400"; content = "GITHUB_TOKEN=\"${config.sops.placeholder.github_token}\"\nCLOUDFLARE_TOKEN=\"${config.sops.placeholder.cloudflare_token}\"\nTAILSCALE_TOKEN=\"${config.sops.placeholder.tailscale_token}\"\nUNRAID_PASS=\"${config.sops.placeholder.unraid_root_password}\""; };
      templates."media-stack.env" = { owner = "root"; group = "media"; mode = "0440"; content = "SONARR_API_KEY=\"${config.sops.placeholder.sonarr_api_key}\"\nRADARR_API_KEY=\"${config.sops.placeholder.radarr_api_key}\"\nREADARR_API_KEY=\"${config.sops.placeholder.readarr_api_key}\""; };
    };
    environment.systemPackages = [ pkgs.age-plugin-tpm ];
  };
}
