# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: Shell-Workflow-Modul – Premium-Aliase + Fastfetch MOTD

{ config, lib, pkgs, ... }:

let
  user = config.my.configs.identity.user;
  host = config.my.configs.identity.host;
  domain = config.my.configs.identity.domain;
  
  # Fastfetch Konfiguration
  fastfetchConfig = pkgs.writeText "fastfetch-homelab.jsonc" (builtins.toJSON {
    logo = {
      source = "nixos";
      padding = { top = 1; left = 2; };
    };
    display = {
      separator = " ➜ ";
      color = { keys = "blue"; title = "green"; };
    };
    modules = [
      { type = "title"; format = "{user-name}@{host-name}"; }
      "separator"
      { type = "os"; key = "OS"; }
      { type = "kernel"; key = "Kernel"; }
      { type = "uptime"; key = "Uptime"; }
      { type = "packages"; key = "Packages"; }
      { type = "shell"; key = "Shell"; }
      "break"
      { type = "cpu"; key = "CPU"; }
      { type = "gpu"; key = "GPU"; }
      { type = "memory"; key = "Memory"; }
      { type = "disk"; key = "Disk (/)"; folders = "/"; }
      "break"
      { type = "localip"; key = "LAN IP"; compact = true; }
      { type = "custom"; format = "${config.my.configs.server.tailscaleIP}"; key = "Tailscale"; }
      "break"
      { type = "custom"; format = "https://${domain}"; key = "Dashboard"; }
      { type = "custom"; format = "https://traefik.${domain}"; key = "Traefik"; }
      "break"
      "colors"
    ];
  });
  
  # Service-Status Checker
  serviceStatusScript = pkgs.writeShellScriptBin "check-services" ''
    #!/usr/bin/env bash
    CRITICAL_SERVICES=("sshd:SSH" "traefik:Traefik" "tailscaled:Tailscale" "jellyfin:Jellyfin" "fail2ban:Fail2ban")
    echo ""
    echo "🔧 Service Status:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    for entry in "''${CRITICAL_SERVICES[@]}"; do
      service="''${entry%%:*}"; label="''${entry##*:}"
      if systemctl is-active --quiet "$service"; then
        echo -e "  \033[0;32m✅\033[0m $label"
      else
        echo -e "  \033[0;31m❌\033[0m $label (FEHLER!)"
      fi
    done
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
  '';
in
{
  programs.bash.shellAliases = lib.mkIf (user == "moritz") {
    # NIX REBUILD
    nsw = "sudo nixos-rebuild switch";
    ntest = "sudo nixos-rebuild test";
    ndry = "sudo nixos-rebuild dry-run";
    nboot = "sudo nixos-rebuild boot";
    
    # NIX MAINTENANCE
    nclean = "sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +5 && sudo nix-store --gc";
    nopt = "sudo nix-store --optimise";
    ngen = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
    
    # NAVIGATION
    ncfg = "cd /etc/nixos";
    ngit = "cd /etc/nixos && git status -sb";
    nlog = "journalctl -xef";
    
    # MODERNE TOOLS
    ls = "${pkgs.eza}/bin/eza --icons";
    ll = "${pkgs.eza}/bin/eza -la --icons --git";
    tree = "${pkgs.eza}/bin/eza --tree --icons";
    cat = "${pkgs.bat}/bin/bat --paging=never";
    less = "${pkgs.bat}/bin/bat";
    top = "${pkgs.htop}/bin/htop";
    df = "${pkgs.duf}/bin/duf";
    du = "${pkgs.dust}/bin/dust";
    
    # SYSTEM INFO
    sysinfo = "${pkgs.fastfetch}/bin/fastfetch --config ${fastfetchConfig}";
    services = "${serviceStatusScript}/bin/check-services";
    ports = "sudo ss -tulpn";
  };
  
  programs.bash.interactiveShellInit = lib.mkIf (user == "moritz") ''
    if [ -n "$SSH_CONNECTION" ] || [ "$TERM" = "xterm-256color" ]; then
      echo ""
      ${pkgs.fastfetch}/bin/fastfetch --config ${fastfetchConfig}
      ${serviceStatusScript}/bin/check-services
      echo ""
      echo -e "  \033[1;36m${host}\033[0m Schaltzentrale | \033[1;33mncfg\033[0m für Config-Zugriff"
      echo ""
    fi
  '';
  
  programs.bash.completion.enable = true;
  
  environment.systemPackages = with pkgs; [
    bat eza ripgrep fd nix-tree nix-diff nixfmt fastfetch duf dust htop
    serviceStatusScript
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
