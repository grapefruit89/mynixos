/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-022
 *   title: "Secrets"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-CORE]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
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
        default = "/etc/nixos/00-core/wireguard-privado.conf"; 
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










/**
 * ---
 * technical_integrity:
 *   checksum: sha256:a0e96b0e5a059580ec5919e94e41fd7ff2a465de45777029645a5a68f5f0fc47
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
