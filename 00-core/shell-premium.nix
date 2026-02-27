# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: Shell-Workflow-Modul – Premium-Aliase + Fastfetch MOTD + Produktivitäts-Tools

{ config, lib, pkgs, ... }:

let
  user = config.my.configs.identity.user;
  host = config.my.configs.identity.host;
  domain = config.my.configs.identity.domain;
  
  fastfetchConfig = pkgs.writeText "fastfetch-homelab.jsonc" (builtins.toJSON {
    logo = { source = "nixos"; padding = { top = 1; left = 2; }; };
    modules = [ "title" "os" "kernel" "uptime" "packages" "shell" "break" "cpu" "gpu" "memory" "disk" "break" "localip" "colors" ];
  });
  
  serviceStatusScript = pkgs.writeShellScriptBin "check-services" ''
    #!/usr/bin/env bash
    SERVICES=("sshd:SSH" "traefik:Traefik" "tailscaled:Tailscale" "jellyfin:Jellyfin" "fail2ban:Fail2ban")
    echo ""
    echo "🔧 Service Status:"
    for entry in "''${SERVICES[@]}"; do
      service="''${entry%%:*}"; label="''${entry##*:}"
      if systemctl is-active --quiet "$service"; then
        echo "  ✅ $label"
      else
        echo "  ❌ $label"
      fi
    done
  '';
in
{
  programs.bash.shellAliases = lib.mkIf (user == "moritz") {
    nsw = "sudo nixos-rebuild switch";
    ntest = "sudo nixos-rebuild test";
    ncfg = "cd /etc/nixos";
    ll = "${pkgs.eza}/bin/eza -la --icons --git";
    sysinfo = "${pkgs.fastfetch}/bin/fastfetch --config ${fastfetchConfig}";
    services = "${serviceStatusScript}/bin/check-services";
  };
  
  programs.bash.interactiveShellInit = lib.mkIf (user == "moritz") ''
    if [ -n "$SSH_CONNECTION" ] || [ "$TERM" = "xterm-256color" ]; then
      ${pkgs.fastfetch}/bin/fastfetch --config ${fastfetchConfig}
      ${serviceStatusScript}/bin/check-services
      BOOT_USAGE=$(df /boot | tail -1 | awk '{print $5}' | sed 's/%//')
      if [ "$BOOT_USAGE" -gt 80 ]; then
        echo "🚨 ACHTUNG: /boot ist zu ''${BOOT_USAGE}% voll!"
      fi
    fi
  '';
  
  environment.systemPackages = with pkgs; [
    bat eza ripgrep fd duf dust htop btop fastfetch micro git curl wget tree unzip file lsof ncdu
    serviceStatusScript
  ];
}
