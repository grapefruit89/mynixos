/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-024
 *   title: "Shell Premium"
 *   layer: 00
 * summary: Advanced shell workflow with fastfetch MOTD and productivity aliases.
 * ---
 */
{ config, lib, pkgs, ... }:

let
  user = config.my.configs.identity.user;
  host = config.my.configs.identity.host;
  domain = config.my.configs.identity.domain;
  
  # Fastfetch Konfiguration (Ryan4yin-inspiriert)
  fastfetchConfig = pkgs.writeText "fastfetch-homelab.jsonc" (builtins.toJSON {
    logo = {
      source = "nixos";
      padding = {
        top = 1;
        left = 2;
      };
    };
    
    display = {
      separator = " ➜ ";
      color = {
        keys = "blue";
        title = "green";
      };
    };
    
    modules = [
      {
        type = "title";
        format = "{user-name}@{host-name}";
      }
      "separator"
      
      {
        type = "os";
        key = "OS";
      }
      {
        type = "kernel";
        key = "Kernel";
      }
      {
        type = "uptime";
        key = "Uptime";
      }
      {
        type = "packages";
        key = "Packages";
      }
      {
        type = "shell";
        key = "Shell";
      }
      
      "break"
      
      {
        type = "cpu";
        key = "CPU";
      }
      {
        type = "gpu";
        key = "GPU";
      }
      {
        type = "memory";
        key = "Memory";
      }
      {
        type = "disk";
        key = "Disk (/)";
        folders = "/";
      }
      
      "break"
      
      {
        type = "localip";
        key = "LAN IP";
        compact = true;
      }
      {
        type = "custom";
        format = "${config.my.configs.server.tailscaleIP}";
        key = "Tailscale";
      }
      
      "break"
      
      {
        type = "custom";
        format = "https://${domain}";
        key = "Dashboard";
      }
      {
        type = "custom";
        format = "https://traefik.${domain}";
        key = "Traefik";
      }
      
      "break"
      "colors"
    ];
  });
  
  # Service-Status Checker (für MOTD)
  serviceStatusScript = pkgs.writeShellScriptBin "check-services" ''
    #!/usr/bin/env bash
    
    # Definiere kritische Services
    CRITICAL_SERVICES=(
      "sshd:SSH"
      "traefik:Traefik"
      "tailscaled:Tailscale"
      "jellyfin:Jellyfin"
      "fail2ban:Fail2ban"
    )
    
    echo ""
    echo "🔧 Service Status:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    for entry in "''${CRITICAL_SERVICES[@]}"; do
      service="''${entry%%:*}"
      label="''${entry##*:}"
      
      if systemctl is-active --quiet "$service"; then
        echo "  ✅ $label"
      else
        echo "  ❌ $label (FEHLER!)"
      fi
    done
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
  '';
  
  # Quick-Alias Hilfe
  aliasHelpScript = pkgs.writeShellScriptBin "aliases" ''
    #!/usr/bin/env bash
    
    cat <<'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    🚀 NIXOS SHORTCUTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  🔧 REBUILD & DEPLOYMENT
  ─────────────────────────────────────────────────────
  nsw        → sudo nixos-rebuild switch (persistent)
  ntest      → sudo nixos-rebuild test (until reboot)
  ndry       → sudo nixos-rebuild dry-run (simulation)
  nboot      → sudo nixos-rebuild boot (next boot)
  
  📦 MAINTENANCE
  ─────────────────────────────────────────────────────
  nup        → nix flake update (update inputs)
  nclean     → GC + delete old generations
  nopt       → nix-store --optimise (deduplicate)
  ngen       → list-generations (show history)
  
  📁 NAVIGATION
  ─────────────────────────────────────────────────────
  ncfg       → cd /etc/nixos (config directory)
  ngit       → git status -sb (in config repo)
  nlog       → journalctl -xef (follow logs)
  
  🛠️ UTILITIES
  ─────────────────────────────────────────────────────
  ll         → eza -la --icons --git (better ls)
  cat        → bat (syntax highlighting)
  top        → htop (better process viewer)
  df         → duf (modern disk usage)
  
  📊 SYSTEM INFO
  ─────────────────────────────────────────────────────
  sysinfo    → fastfetch (system overview)
  services   → check-services (service status)
  ports      → sudo ss -tulpn (open ports)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  '';
in
{
  # ══════════════════════════════════════════════════════════════════════════
  # BASH ALIASE (Nur für den definierten User)
  # ══════════════════════════════════════════════════════════════════════════
  programs.bash.shellAliases = lib.mkIf (user == "moritz") {
    # ── NIX REBUILD ────────────────────────────────────────────────────────
    nsw = "sudo nixos-rebuild switch";
    ntest = "sudo nixos-rebuild test";
    ndry = "sudo nixos-rebuild dry-run";
    nboot = "sudo nixos-rebuild boot";
    
    # ── NIX MAINTENANCE ────────────────────────────────────────────────────
    nup = "nix flake update";
    nclean = "sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +5 && sudo nix-store --gc";
    nopt = "sudo nix-store --optimise";
    ngen = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
    
    # ── NAVIGATION ─────────────────────────────────────────────────────────
    ncfg = "cd /etc/nixos";
    ngit = "cd /etc/nixos && git status -sb";
    nlog = "journalctl -xef";
    
    # ── MODERNE TOOLS ──────────────────────────────────────────────────────
    ls = "${pkgs.eza}/bin/eza --icons";
    ll = "${pkgs.eza}/bin/eza -la --icons --git";
    tree = "${pkgs.eza}/bin/eza --tree --icons";
    cat = "${pkgs.bat}/bin/bat --paging=never";
    less = "${pkgs.bat}/bin/bat";
    top = "${pkgs.htop}/bin/htop";
    df = "${pkgs.duf}/bin/duf";
    du = "${pkgs.dust}/bin/dust";
    
    # ── SYSTEM INFO ────────────────────────────────────────────────────────
    sysinfo = "${pkgs.fastfetch}/bin/fastfetch --config ${fastfetchConfig}";
    services = "${serviceStatusScript}/bin/check-services";
    ports = "sudo ss -tulpn";
    
    # ── GIT SHORTCUTS ──────────────────────────────────────────────────────
    gs = "git status -sb";
    ga = "git add";
    gc = "git commit -m";
    gp = "git push";
    gl = "git log --oneline --graph --decorate --all -n 10";
    
    # ── DOCKER (falls Container genutzt werden) ───────────────────────────
    dps = "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'";
    dlogs = "docker logs -f";
    dexec = "docker exec -it";
  };
  
  # ══════════════════════════════════════════════════════════════════════════
  # INTERAKTIVER SHELL START (MOTD)
  # ══════════════════════════════════════════════════════════════════════════
  programs.bash.interactiveShellInit = lib.mkIf (user == "moritz") ''
    # Nur bei SSH oder lokaler Konsole
    if [ -n "$SSH_CONNECTION" ] || [ "$TERM" = "xterm-256color" ]; then
      # Fastfetch Banner
      ${pkgs.fastfetch}/bin/fastfetch --config ${fastfetchConfig}
      
      # Service-Status
      ${serviceStatusScript}/bin/check-services
      
      # Hinweis auf Aliase
      echo "💡 Tipp: Nutze 'aliases' für eine Liste aller Shortcuts"
      echo ""
      
      # Firewall-Warnung (wenn Bastelmodus aktiv)
      ${lib.optionalString config.my.configs.bastelmodus ''
        echo "⚠️  WARNUNG: Bastelmodus ist AKTIV (Firewall AUS)"
        echo "   → Produktiv schalten: my.configs.bastelmodus = false"
        echo ""
      ''}
      
      # Boot-Partition Warnung (wenn >80% voll)
      BOOT_USAGE=$(df /boot | tail -1 | awk '{print $5}' | sed 's/%//')
      if [ "$BOOT_USAGE" -gt 80 ]; then
        echo "🚨 ACHTUNG: /boot ist zu ''${BOOT_USAGE}% voll!"
        echo "   → Lösung: nclean (löscht alte Generationen)"
        echo ""
      fi
    fi
  '';
  
  # ══════════════════════════════════════════════════════════════════════════
  # BASH KONFIGURATION
  # ══════════════════════════════════════════════════════════════════════════
  programs.bash.shellInit = ''
    # History-Optimierung
    export HISTCONTROL=ignoredups:ignorespace:erasedups
    export HISTSIZE=50000
    export HISTFILESIZE=100000
    shopt -s histappend
    
    # Editor
    export EDITOR="micro"
    export VISUAL="micro"
    
    # Pager mit Farben
    export LESS="-R"
    export PAGER="less"
    
    # Colored Man Pages
    export LESS_TERMCAP_mb=$'\e[1;32m'
    export LESS_TERMCAP_md=$'\e[1;32m'
    export LESS_TERMCAP_me=$'\e[0m'
    export LESS_TERMCAP_se=$'\e[0m'
    export LESS_TERMCAP_so=$'\e[01;33m'
    export LESS_TERMCAP_ue=$'\e[0m'
    export LESS_TERMCAP_us=$'\e[1;4;31m'
    
    # Prompt-Optimierung (mit Git-Branch)
    parse_git_branch() {
      git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
    }
    
    # Farben (mit Fallback für alte Terminals)
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
      PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[33m\]$(parse_git_branch)\[\033[00m\]\$ '
    else
      PS1='\u@\h:\w\$ '
    fi
  '';
  
  # ══════════════════════════════════════════════════════════════════════════
  # BASH COMPLETION
  # ══════════════════════════════════════════════════════════════════════════
  programs.bash.completion.enable = true;
  
  # ══════════════════════════════════════════════════════════════════════════
  # SYSTEMWEITE PAKETE (Produktivitäts-Tools)
  # ══════════════════════════════════════════════════════════════════════════
  environment.systemPackages = with pkgs; [
    # Moderne CLI-Tools
    bat               # cat mit Syntax-Highlighting
    eza               # ls Ersatz
    ripgrep           # grep Ersatz
    fd                # find Ersatz
    duf               # df Ersatz
    dust              # du Ersatz
    htop              # top Ersatz
    btop              # htop Ersatz (noch schöner)
    
    # Nix-Tools
    nix-tree          # Dependency-Visualisierung
    nix-diff          # Config-Vergleich
    nixfmt-classic    # Nix-Formatter
    nix-output-monitor  # Schöner Build-Output
    
    # System-Info
    fastfetch         # neofetch Nachfolger
    
    # Development
    micro             # Editor (nano Ersatz)
    git               # VCS
    
    # Networking
    curl              # HTTP-Client
    wget              # Downloader
    
    # Utilities
    tree              # Verzeichnis-Baum
    unzip             # Archive
    file              # Datei-Typ Erkennung
    
    # Monitoring
    lsof              # Open Files
    ncdu              # Disk Usage Analyzer
    
    # Helper-Scripts
    serviceStatusScript
    aliasHelpScript
  ];
  
  # ══════════════════════════════════════════════════════════════════════════
  # GIT KONFIGURATION
  # ══════════════════════════════════════════════════════════════════════════
  programs.git = {
    enable = true;
    config = {
      user.name = "Moritz Baumeister";
      user.email = config.my.configs.identity.email;
      
      # Workflow
      pull.ff = "only";
      push.default = "current";
      init.defaultBranch = "main";
      
      # Diff & Merge
      diff.colorMoved = "default";
      merge.conflictStyle = "diff3";
      
      # Aliase
      alias = {
        st = "status -sb";
        co = "checkout";
        br = "branch";
        ci = "commit";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        visual = "log --oneline --graph --decorate --all";
      };
      
      # Performance
      core.preloadindex = true;
      core.fscache = true;
      gc.auto = 256;
    };
  };
  
  # ══════════════════════════════════════════════════════════════════════════
  # ASSERTIONS (Sicherheitsprüfung)
  # ══════════════════════════════════════════════════════════════════════════
  assertions = [
    {
      assertion = user == "moritz";
      message = "Shell-Premium-Modul ist nur für User 'moritz' konfiguriert. Für andere User: Home-Manager nutzen.";
    }
  ];
}
