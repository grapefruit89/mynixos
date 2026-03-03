{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-00-CORE-024";
    title = "Shell Premium";
    description = "Advanced shell workflow with fastfetch MOTD, service status health-checks, and power-user aliases.";
    layer = 00;
    nixpkgs.category = "system/settings";
    capabilities = [ "shell/premium" "observability/motd" "system/status-checker" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

  user = config.my.configs.identity.user;
  host = config.my.configs.identity.host;
  domain = config.my.configs.identity.domain;
  
  fastfetchConfig = pkgs.writeText "fastfetch-homelab.jsonc" (builtins.toJSON {
    logo = { source = "nixos"; padding = { top = 1; left = 2; }; };
    display = { separator = " ➜ "; color = { keys = "blue"; title = "green"; }; };
    modules = [
      { type = "title"; format = "{user-name}@{host-name}"; } "separator"
      { type = "os"; key = "OS"; } { type = "kernel"; key = "Kernel"; } { type = "uptime"; key = "Uptime"; }
      { type = "packages"; key = "Packages"; } { type = "shell"; key = "Shell"; } "break"
      { type = "cpu"; key = "CPU"; } { type = "gpu"; key = "GPU"; } { type = "memory"; key = "Memory"; }
      { type = "disk"; key = "Disk (/)"; folders = "/"; } "break"
      { type = "localip"; key = "LAN IP"; compact = true; } { type = "custom"; format = "${config.my.configs.server.tailscaleIP}"; key = "Tailscale"; } "break"
      { type = "custom"; format = "https://${domain}"; key = "Dashboard"; } { type = "custom"; format = "https://traefik.${domain}"; key = "Traefik"; } "break" "colors"
    ];
  });
  
  serviceStatusScript = pkgs.writeShellScriptBin "check-services" ''
    #!/usr/bin/env bash
    CRITICAL_SERVICES=("sshd:SSH" "traefik:Traefik" "tailscaled:Tailscale" "jellyfin:Jellyfin" "fail2ban:Fail2ban")
    echo -e "\n🔧 Service Status:\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    for entry in "''${CRITICAL_SERVICES[@]}"; do
      service="''${entry%%:*}"; label="''${entry##*:}"
      if systemctl is-active --quiet "$service"; then echo "  ✅ $label"; else echo "  ❌ $label (FEHLER!)"; fi
    done
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  '';
in
{
  options.my.meta.shell_premium = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for shell-premium module";
  };

  options.my.shell.premium.enable = lib.mkEnableOption "Advanced Shell Features (Fastfetch, Service Checks)";

  config = lib.mkIf (config.my.shell.premium.enable && user == "moritz") {
    programs.bash.shellAliases = {
      nsw = "sudo nixos-rebuild switch"; ntest = "sudo nixos-rebuild test"; ndry = "sudo nixos-rebuild dry-run"; nboot = "sudo nixos-rebuild boot";
      nup = "nix flake update"; nclean = "sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +5 && sudo nix-store --gc";
      nopt = "sudo nix-store --optimise"; ngen = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
      ncfg = "cd /etc/nixos"; ngit = "cd /etc/nixos && git status -sb"; nlog = "journalctl -xef";
      ls = "${pkgs.eza}/bin/eza --icons"; ll = "${pkgs.eza}/bin/eza -la --icons --git"; tree = "${pkgs.eza}/bin/eza --tree --icons";
      cat = "${pkgs.bat}/bin/bat --paging=never"; less = "${pkgs.bat}/bin/bat"; top = "${pkgs.htop}/bin/htop"; df = "${pkgs.duf}/bin/duf"; du = "${pkgs.dust}/bin/dust";
      sysinfo = "${pkgs.fastfetch}/bin/fastfetch --config ${fastfetchConfig}"; services = "${serviceStatusScript}/bin/check-services"; ports = "sudo ss -tulpn";
      gs = "git status -sb"; ga = "git add"; gc = "git commit -m"; gp = "git push"; gl = "git log --oneline --graph --decorate --all -n 10";
    };
    
    programs.bash.interactiveShellInit = ''
      if [ -n "$SSH_CONNECTION" ] || [ "$TERM" = "xterm-256color" ]; then
        ${pkgs.fastfetch}/bin/fastfetch --config ${fastfetchConfig}
        ${serviceStatusScript}/bin/check-services
        echo "💡 Tipp: Nutze 'aliases' für eine Liste aller Shortcuts"
        ${lib.optionalString config.my.configs.bastelmodus "echo '⚠️ WARNUNG: Bastelmodus ist AKTIV (Firewall AUS)'"}
      fi
    '';
    
    environment.systemPackages = with pkgs; [ bat eza ripgrep fd duf dust htop btop nix-tree nix-diff nixfmt-classic nix-output-monitor fastfetch micro git curl wget tree unzip file lsof ncdu serviceStatusScript ];
  };
}
