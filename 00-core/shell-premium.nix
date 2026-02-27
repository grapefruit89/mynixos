{ config, lib, pkgs, ... }:
let
  fastfetchConfig = pkgs.writeText "motd.jsonc" (builtins.toJSON {
    "logo" = { "source" = "nixos"; "padding" = { "top" = 1; "left" = 2; }; };
    "display" = { "separator" = " ➜ "; "color" = { "keys" = "cyan"; "title" = "blue"; }; };
    "modules" = [
      "title" "os" "host" "kernel" "uptime" "packages" "memory" "disk" "localip" "break" "colors"
    ];
  });

  serviceStatusScript = pkgs.writeShellScript "check-services" ''
    SERVICES=("sshd:SSH" "traefik:Traefik" "tailscaled:Tailscale" "jellyfin:Jellyfin" "fail2ban:Fail2ban")
    echo -e "
🔧 Service Status:"
    for entry in "''${SERVICES[@]}"; do
      service="''${entry%%:*}"; label="''${entry##*:}"
      if systemctl is-active --quiet "$service"; then
        echo -e "  \033[0;32m✅\033[0m $label"
      else
        echo -e "  \033[0;31m❌\033[0m $label"
      fi
    done
  '';
in {
  environment.systemPackages = with pkgs; [ fastfetch btop ncdu duf ripgrep ];
  
  programs.bash.interactiveShellInit = ''
    if [[ $- == *i* ]]; then
      echo ""
      ${pkgs.fastfetch}/bin/fastfetch --config ${fastfetchConfig}
      ${serviceStatusScript}
      echo -e "
🔍 Boot-Partition:"
      df -h /boot | grep -v Filesystem
      echo ""
    fi
  '';
}
