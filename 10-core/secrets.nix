/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Secrets
 * TRACE-ID:     NIXH-CORE-009
 * REQ-REF:      REQ-CORE
 * LAYER:        10
 * STATUS:       Stable
 * INTEGRITY:    SHA256:89b434a2baafd446e2592fa91f7459eadec9be134b93c28813498cb4c7509c1f
 */

{ config, lib, ... }:
{
  config = {
    sops = {
      defaultSopsFile = ../secrets.yaml;
      defaultSopsFormat = "yaml";
      
      age = {
        sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
      };

      secrets = {
        github_token = { };
        cloudflare_token = { };
        tailscale_token = { };
        wg_privado_private_key = { };
        sonarr_api_key = { };
        radarr_api_key = { };
        readarr_api_key = { };
        homepage_sonarr_key = { };
        homepage_radarr_key = { };
        google_ai_key = { };
        groq_key = { };
        xai_key = { };
        unraid_root_password = { };
        ssh_github_key = { };
        ssh_unraid_key = { };
      };

      templates."secrets.env" = {
        content = ''
          GITHUB_TOKEN="${config.sops.placeholder.github_token}"
          CLOUDFLARE_TOKEN="${config.sops.placeholder.cloudflare_token}"
          TAILSCALE_TOKEN="${config.sops.placeholder.tailscale_token}"
          WG_PRIVADO_PRIVATE_KEY="${config.sops.placeholder.wg_privado_private_key}"
          SONARR_API_KEY="${config.sops.placeholder.sonarr_api_key}"
          RADARR_API_KEY="${config.sops.placeholder.radarr_api_key}"
          READARR_API_KEY="${config.sops.placeholder.readarr_api_key}"
          HOMEPAGE_VAR_SONARR_API_KEY="${config.sops.placeholder.homepage_sonarr_key}"
          HOMEPAGE_VAR_RADARR_API_KEY="${config.sops.placeholder.homepage_radarr_key}"
          GOOGLE_AI_KEY="${config.sops.placeholder.google_ai_key}"
          GROQ_KEY="${config.sops.placeholder.groq_key}"
          XAI_KEY="${config.sops.placeholder.xai_key}"
          UNRAID_ROOT_PASSWORD="${config.sops.placeholder.unraid_root_password}"
        '';
      };
    };
  };

  options.my.secrets = {
    files = {
      sharedEnv = lib.mkOption { 
        type = lib.types.path; 
        default = config.sops.templates."secrets.env".path;
      };
      sshGithubKey = lib.mkOption { 
        type = lib.types.path; 
        default = config.sops.secrets.ssh_github_key.path; 
      };
      sshUnraidKey = lib.mkOption { 
        type = lib.types.path; 
        default = config.sops.secrets.ssh_unraid_key.path; 
      };
      wireguardPrivadoConf = lib.mkOption { 
        type = lib.types.str; 
        default = "/etc/nixos/10-core/wireguard-privado.conf"; 
      };
    };

    vars = {
      wgPrivadoPrivateKeyVarName = lib.mkOption { 
        type = lib.types.str; 
        default = "WG_PRIVADO_PRIVATE_KEY"; 
      };
    };
  };
}
