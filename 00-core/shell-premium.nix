/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-024
 *   title: "Shell Premium"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-CORE]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ config, lib, pkgs, ... }:

let
  user = config.my.configs.identity.user;
  host = config.my.configs.identity.host;
  domain = config.my.configs.identity.domain;
  
  fastfetchConfig = pkgs.writeText "fastfetch-homelab.jsonc" (builtins.toJSON {
    logo = { source = "nixos"; padding = { top = 1; left = 2; }; };
    modules = [
      "title"
      "os"
      "kernel"
      "uptime"
      "packages"
      "shell"
      "break"
      "cpu"
      "gpu"
      "memory"
      "disk"
      "break"
      {
        type = "localip";
        key = "🌐 Local IPs";
        compact = true;
      }
      {
        type = "custom";
        format = "⚓ Notfall-IP:  10.254.0.1";
      }
      {
        type = "custom";
        format = "🏠 Lokale URL:  http://nixhome.local";
      }
      "break"
      "colors"
    ];
  });
  
  serviceStatusScript = pkgs.writeShellScriptBin "check-services" ''
    #!/usr/bin/env bash
    SERVICES=("sshd:SSH" "caddy:Caddy" "tailscaled:Tailscale" "jellyfin:Jellyfin" "fail2ban:Fail2ban")
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

  # 🔄 NIX-SYNC: Der neue Workflow-Manager (Commit -> Push -> Dry-Run)
  nixSyncScript = pkgs.writeShellScriptBin "nix-sync" ''
    #!/usr/bin/env bash
    set -e
    cd /etc/nixos
    echo "🔄 [NIX-SYNC] Vorbereitung läuft..."

    # 1. GIT CHECK & COMMIT
    if [ -n "$(git status --porcelain)" ]; then
        echo "📝 Änderungen erkannt..."
        MSG="$1"
        if [ -z "$MSG" ]; then
            if [ -t 0 ]; then
                read -p "Commit-Nachricht (leer für Timestamp): " USER_MSG
                MSG="''${USER_MSG:-Auto-Commit: $(date '+%Y-%m-%d %H:%M:%S')}"
            else
                MSG="Auto-Commit: $(date '+%Y-%m-%d %H:%M:%S')"
            fi
        fi
        git add .
        git commit -m "$MSG"
    else
        echo "✅ Git ist sauber."
    fi

    # 2. GIT PUSH
    echo "🚀 Pushing to GitHub..."
    git push origin main || { echo "❌ Push fehlgeschlagen! Eventuell Pull nötig?"; exit 1; }

    # 3. DRY-RUN BUILD
    echo "🏗️ Starte Dry-Run Build..."
    if sudo nixos-rebuild dry-activate ; then
        echo "✨ DRY-RUN ERFOLGREICH! Konfiguration ist syntaktisch korrekt."
        echo "💡 Nutze 'nsw' für den echten Switch, wenn du bereit bist."
    else
        echo "🔥 FEHLER im Dry-Run! Build würde fehlschlagen."
        exit 1
    fi
  '';

  nixSafeSwitchScript = pkgs.writeShellScriptBin "nix-safe-switch" ''
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -z "$TMUX" ]; then
        echo "🔄 [NIX-SAFE-SWITCH] Starte Rebuild in geschützter TMUX-Sitzung..."
        tmux new-session -d -s "nix_update" "sudo nixos-rebuild switch | tee /tmp/nixos-switch.log"
        echo "🚀 Update läuft im Hintergrund."
        echo "💡 Falls die Verbindung abbricht, verbinde dich neu und tippe: tmux attach -t nix_update"
        echo "📖 Logs: tail -f /tmp/nixos-switch.log"
    else
        echo "🛠️ [NIX-SAFE-SWITCH] Tmux bereits aktiv, führe Rebuild direkt aus..."
        sudo nixos-rebuild switch
    fi
  '';
in
{
  programs.bash.shellAliases = lib.mkIf (user == "moritz") {
    # NIX REBUILD & SYNC
    nsw = "${nixSafeSwitchScript}/bin/nix-safe-switch";
    nsw-dry = "sudo nixos-rebuild dry-activate -I nixos-config=/etc/nixos/configuration.nix";
    ntest = "sudo nixos-rebuild test";
    ndry = lib.mkForce "sudo nixos-rebuild dry-activate"; # Dry-Run Update
    nboot = "sudo nixos-rebuild boot";
    np = "nix-sync"; # Nix-Prep Workflow
    
    # NIX MAINTENANCE
    nclean = "sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +5 && sudo nix-store --gc";
    nopt = "sudo nix-store --optimise";
    ngen = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
    
    # NAVIGATION & STATUS
    ncfg = "cd /etc/nixos";
    ngit = "cd /etc/nixos && git status -sb";
    nlog = "journalctl -xef";
    services = "${serviceStatusScript}/bin/check-services";
    sysinfo = "${pkgs.fastfetch}/bin/fastfetch --config ${fastfetchConfig}";
    ports = "sudo ss -tulpn";
    
    # MODERNE TOOLS
    ls = "${pkgs.eza}/bin/eza --icons";
    ll = "${pkgs.eza}/bin/eza -la --icons --git";
    tree = "${pkgs.eza}/bin/eza --tree --icons";
    cat = "${pkgs.bat}/bin/bat --paging=never";
    less = "${pkgs.bat}/bin/bat";
    top = "${pkgs.htop}/bin/htop";
    df = "${pkgs.duf}/bin/duf";
    du = "${pkgs.dust}/bin/dust";
  };
  
  programs.bash.interactiveShellInit = lib.mkIf (user == "moritz") ''
    # 🔒 TMUX AUTO-START DEAKTIVIERT (Fix für SFTP & Mausrad)
    # if [[ -z "$TMUX" && -n "$SSH_CONNECTION" && $- == *i* ]]; then
    #   if [[ "$BASH_EXECUTION_STRING" != *sftp-server* ]]; then
    #     tmux attach -t main 2>/dev/null || tmux new-session -s main
    #   fi
    # fi

    if [[ -n "$SSH_CONNECTION" || "$TERM" = "xterm-256color" ]] && [[ $- == *i* ]]; then
      ${pkgs.fastfetch}/bin/fastfetch --config ${fastfetchConfig}
      ${serviceStatusScript}/bin/check-services
      BOOT_USAGE=$(df /boot | tail -1 | ${pkgs.gawk}/bin/awk '{print $5}' | ${pkgs.gnused}/bin/sed 's/%//')
      if [ "$BOOT_USAGE" -gt 80 ]; then
        echo "🚨 ACHTUNG: /boot ist zu ''${BOOT_USAGE}% voll!"
      fi
    fi
  '';
  
  environment.systemPackages = with pkgs; [
    bat eza ripgrep fd duf dust htop btop fastfetch micro git curl wget tree unzip file lsof ncdu tmux github-cli
    serviceStatusScript
    nixSyncScript
    nixSafeSwitchScript
  ];
}












/**
 * ---
 * technical_integrity:
 *   checksum: sha256:cea8a42907f1fd5229bf35841fc6796751d7575d4093f525a9cc27fda2987148
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
