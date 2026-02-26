# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: Shell-Workflow-Modul – Aliase + Fastfetch MOTD

{ config, lib, pkgs, ... }:

let
  user = config.my.configs.identity.user;
  
  # Fastfetch Konfiguration (Ryan4yin-Style)
  fastfetchConfig = pkgs.writeText "fastfetch-config.jsonc" (builtins.toJSON {
    logo = {
      source = "nixos";
      padding = {
        top = 1;
      };
    };
    display = {
      separator = " ➜ ";
    };
    modules = [
      "title"
      "separator"
      "os"
      "host"
      "kernel"
      "uptime"
      "packages"
      "shell"
      "cpu"
      "gpu"
      "memory"
      "disk"
      "localip"
      "break"
      "colors"
    ];
  });
in
{
  # Aliase für User moritz
  programs.bash.shellAliases = lib.mkIf (user == "moritz") {
    nsw = "sudo nixos-rebuild switch";
    ntest = "sudo nixos-rebuild test";
    ndry = "sudo nixos-rebuild dry-run";
    nclean = "sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +5 && sudo nix-store --gc";
    ncfg = "cd /etc/nixos";
    ngit = "cd /etc/nixos && git status -sb";
    
    # Moderne Tools
    ls = "${pkgs.eza}/bin/eza --icons";
    ll = "${pkgs.eza}/bin/eza -la --icons --git";
    cat = "${pkgs.bat}/bin/bat";
    top = "${pkgs.htop}/bin/htop";
  };
  
  # Neues MOTD via Fastfetch
  programs.bash.interactiveShellInit = lib.mkIf (user == "moritz") ''
    if [ -n "$SSH_CONNECTION" ] || [ "$TERM" = "xterm-256color" ]; then
      echo ""
      ${pkgs.fastfetch}/bin/fastfetch --config ${fastfetchConfig}
      echo ""
      echo -e "  ${config.my.configs.identity.host} Schaltzentrale | ncfg für Config-Zugriff"
      echo ""
    fi
  '';
  
  programs.bash.completion.enable = true;
  
  environment.systemPackages = with pkgs; [
    bat eza ripgrep fd nix-tree nix-diff nixfmt fastfetch
  ];
  
  programs.git = {
    enable = true;
    config = {
      user.name = "Moritz Baumeister";
      user.email = config.my.configs.identity.email;
      pull.ff = "only";
      init.defaultBranch = "main";
    };
  };

  programs.bash.shellInit = ''
    export HISTCONTROL=ignoredups:ignorespace
    export EDITOR="micro"
    export VISUAL="micro"
  '';

  assertions = [
    {
      assertion = user == "moritz";
      message = "Shell-Modul ist nur für User 'moritz' konfiguriert.";
    }
  ];
}
