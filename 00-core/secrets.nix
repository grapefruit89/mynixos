{ config, lib, ... }:
let
  secrets = import ../.local-secrets.nix;
in
{
  options.my.secrets = {
    sonarr_api_key = lib.mkOption { type = lib.types.str; default = secrets.sonarr_api_key; };
    radarr_api_key = lib.mkOption { type = lib.types.str; default = secrets.radarr_api_key; };
    readarr_api_key = lib.mkOption { type = lib.types.str; default = secrets.readarr_api_key; };
    cloudflare_token = lib.mkOption { type = lib.types.str; default = secrets.cloudflare; };
    
    files = {
      wireguardPrivadoConf = lib.mkOption { type = lib.types.str; default = "/etc/nixos/00-core/wireguard-privado.conf"; };
      sharedEnv = lib.mkOption { type = lib.types.str; default = "/etc/nixos/.env"; };
      traefikEnv = lib.mkOption { type = lib.types.str; default = "/etc/nixos/.env"; };
    };

    vars = {
      wgPrivadoPrivateKeyVarName = lib.mkOption { 
        type = lib.types.str; 
        default = "WG_PRIVADO_PRIVATE_KEY"; 
      };
    };
  };
}
