{ config, lib, pkgs, ... }:
let
  user = config.my.configs.identity.user;
  secretsFile = ./../.local-secrets.nix;
  secrets = if builtins.pathExists secretsFile then import secretsFile else { 
    github = ""; cloudflare = ""; tailscale = ""; 
  };
in
{
  imports = [ <home-manager/nixos> ];
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hm-backup";
  home-manager.users.${user} = { ... }: {
    imports = [ (./.. + "/users/${user}/home.nix") ];
    home.sessionVariables = {
      GITHUB_TOKEN = secrets.github;
      GITHUB_PERSONAL_ACCESS_TOKEN = secrets.github;
      CLOUDFLARE_API_TOKEN = secrets.cloudflare;
      TAILSCALE_AUTH_KEY = secrets.tailscale;
    };
    programs.bash.shellAliases = {
      godmode = "gemini --yolo --include-directories /etc/nixos,/home/moritz";
    };
  };
}
