{ lib, ... }:
{
  options.my.secrets = {
    # CRITICAL: These paths point to files OUTSIDE the Nix store.
    # Services must read them at runtime (e.g., via EnvironmentFile).
    files = {
      sharedEnv = lib.mkOption { 
        type = lib.types.str; 
        default = "/etc/nixos/secrets.env"; 
      };
      sshGithubKey = lib.mkOption { 
        type = lib.types.str; 
        default = "/etc/nixos/ssh_github.key"; 
      };
      sshUnraidKey = lib.mkOption { 
        type = lib.types.str; 
        default = "/etc/nixos/ssh_unraid.key"; 
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
