# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: Shell-Workflow-Modul – Aliase + MOTD für User moritz

{ config, lib, pkgs, ... }:

let
  user = config.my.configs.identity.user;
  host = config.my.configs.identity.host;
  
  # ANSI-Farben für MOTD
  reset = "\\033[0m";
  bold = "\\033[1m";
  red = "\\033[31m";
  green = "\\033[32m";
  yellow = "\\033[33m";
  blue = "\\033[34m";
  cyan = "\\033[36m";
  
  # Dynamische Systeminfo
  getSystemInfo = pkgs.writeShellScript "system-info" ''
    # Hostname
    HOSTNAME=$(${pkgs.nettools}/bin/hostname)
    
    # IP-Adressen
    LAN_IP=$(${pkgs.iproute2}/bin/ip -4 addr show | ${pkgs.gnugrep}/bin/grep -oP '(?<=inet\s)\d+(\.\d+){3}' | ${pkgs.gnugrep}/bin/grep -v 127.0.0.1 | head -1)
    TAILSCALE_IP=$(${pkgs.iproute2}/bin/ip -4 addr show tailscale0 2>/dev/null | ${pkgs.gnugrep}/bin/grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
    
    # Uptime
    UPTIME=$(${pkgs.procps}/bin/uptime -p | sed 's/up //')
    
    # Load Average
    LOAD=$(${pkgs.coreutils}/bin/cut -d' ' -f1-3 /proc/loadavg)
    
    # Disk Usage (Root)
    DISK=$(${pkgs.coreutils}/bin/df -h / | ${pkgs.gawk}/bin/awk 'NR==2 {print $5}')
    
    # Memory Usage
    MEM=$(${pkgs.procps}/bin/free -h | ${pkgs.gawk}/bin/awk 'NR==2 {print $3 "/" $2}')
    
    # Service-Status (wichtigste Services)
    check_service() {
      if ${pkgs.systemd}/bin/systemctl is-active "$1" >/dev/null 2>&1; then
        echo -e "${green}✓${reset}"
      else
        echo -e "${red}✗${reset}"
      fi
    }
    
    TRAEFIK=$(check_service traefik)
    SSH=$(check_service sshd)
    TAILSCALE=$(check_service tailscaled)
    JELLYFIN=$(check_service jellyfin)
    
    # Ausgabe
    cat <<EOF
${bold}${cyan}╔════════════════════════════════════════════════════════════════╗
║                    Fujitsu Q958 · NixOS Homelab                ║
╚════════════════════════════════════════════════════════════════╝${reset}

${bold}System Info:${reset}
  Host:           ${bold}$HOSTNAME${reset}
  LAN-IP:         ${cyan}''${LAN_IP:-N/A}${reset}
  Tailscale:      ${cyan}''${TAILSCALE_IP:-N/A}${reset}
  Uptime:         $UPTIME
  Load:           $LOAD
  Disk (Root):    $DISK
  Memory:         $MEM

${bold}Service Status:${reset}
  Traefik:    $TRAEFIK      SSH:        $SSH
  Tailscale:  $TAILSCALE    Jellyfin:   $JELLYFIN

${bold}${yellow}Wichtige Aliase:${reset}
  ${bold}nsw${reset}      → sudo nixos-rebuild switch
  ${bold}ntest${reset}    → sudo nixos-rebuild test (temporär bis Reboot)
  ${bold}nup${reset}      → nix flake update (nur wenn Flakes aktiv)
  ${bold}nclean${reset}   → Garbage Collection (alte Generationen löschen)
  ${bold}nconf${reset}    → cd ~/nix-config && vscodium . (Config editieren)
  ${bold}ncfg${reset}     → cd /etc/nixos
  ${bold}ngit${reset}     → cd /etc/nixos && git status -sb

${bold}${yellow}Workflow:${reset}
  1. Änderungen machen:  ${cyan}ncfg${reset} → Editor
  2. Testen:             ${cyan}ntest${reset}
  3. Persistieren:       ${cyan}nsw${reset}
  4. Cleanup:            ${cyan}nclean${reset} (bei Platzmangel)

${bold}${red}⚠️  Hinweise:${reset}
  • ${yellow}Immer erst 'ntest' vor 'nsw' ausführen!${reset}
  • Rollback: Neustart → ältere Generation im Boot-Menü wählen
  • Logs: ${cyan}journalctl -xe${reset} oder ${cyan}journalctl -u <service>${reset}

${bold}Dokumentation:${reset} /etc/nixos/README.md
${bold}Support:${reset} https://github.com/grapefruit89/mynixos

EOF
  '';
in
{
  # Aliase für User moritz
  programs.bash.shellAliases = lib.mkIf (user == "moritz") {
    # Basis-Workflow
    nsw = "sudo nixos-rebuild switch";
    ntest = "sudo nixos-rebuild test";
    ndry = "sudo nixos-rebuild dry-run";
    
    # Flake-Befehle (nur wenn Flakes aktiv)
    nup = "nix flake update";
    
    # Cleanup
    nclean = "sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +5 && sudo nix-store --gc";
    
    # Navigation
    nconf = "cd /etc/nixos && \${EDITOR:-nano}";
    ncfg = "cd /etc/nixos";
    ngit = "cd /etc/nixos && git status -sb";
    
    # Nützliche Zusatz-Aliase
    nlog = "sudo journalctl -xe";
    nserv = "sudo systemctl status";
    nrestart = "sudo systemctl restart";
    
    # Traefik-spezifisch
    traefik-log = "sudo journalctl -u traefik -f";
    traefik-reload = "sudo systemctl reload traefik";
    
    # Deployment-Helfer
    nix-deploy = "/etc/nixos/scripts/nix-deploy.sh";
  };
  
  # MOTD (Message of the Day)
  users.users.${user}.shell = pkgs.bash;
  
  programs.bash.interactiveShellInit = lib.mkIf (user == "moritz") ''
    # MOTD nur bei SSH-Login (nicht bei lokaler Konsole)
    if [ -n "$SSH_CONNECTION" ] || [ "$TERM" = "xterm-256color" ]; then
      ${getSystemInfo}
    fi
  '';
  
  # Alternative: Über /etc/motd (statischer Ansatz)
  # environment.etc."motd".text = ''
  #   System: ${host}
  #   User: ${user}
  #   ...
  # '';
  
  # Bash-Completion für nix-Befehle
  programs.bash.enableCompletion = true;
  
  # Nix-Command-Wrapper mit besseren Defaults
  environment.systemPackages = with pkgs; [
    # Für interaktive Shells
    bat          # cat-Alternative mit Syntax-Highlighting
    eza          # ls-Alternative
    ripgrep      # grep-Alternative
    fd           # find-Alternative
    
    # Nix-spezifisch
    nix-tree     # Dependency-Tree visualisieren
    nix-diff     # Nix-Store-Diffs anzeigen
    nixfmt       # Nix-Code formatieren
  ];
  
  # Git-Konfiguration für nix-config Repository
  programs.git = {
    enable = true;
    config = {
      user.name = lib.mkDefault "Moritz Baumeister";
      user.email = lib.mkDefault config.my.configs.identity.email;
      
      # Nützliche Git-Aliase
      alias = {
        st = "status -sb";
        co = "checkout";
        ci = "commit";
        br = "branch";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        visual = "log --graph --oneline --all";
      };
      
      # Git-Workflow optimiert für NixOS-Config
      pull.ff = "only";  # Keine Merge-Commits bei Pull
      push.default = "current";
      init.defaultBranch = "main";
    };
  };
  
  # Bash-History-Optimierungen
  programs.bash.historyControl = [ "ignoredups" "ignorespace" ];
  programs.bash.historySize = 10000;
  programs.bash.historyFileSize = 20000;
  
  # Farben für ls/eza
  programs.bash.shellInit = ''
    # Farben aktivieren
    alias ls='${pkgs.eza}/bin/eza --color=auto'
    alias ll='${pkgs.eza}/bin/eza -la --git --color=auto'
    alias lt='${pkgs.eza}/bin/eza -la --git --tree --level=2 --color=auto'
    
    # cat → bat
    alias cat='${pkgs.bat}/bin/bat --style=plain'
    
    # grep → ripgrep
    alias grep='${pkgs.ripgrep}/bin/rg'
    
    # Editor-Fallback
    export EDITOR="''${EDITOR:-nano}"
    export VISUAL="$EDITOR"
    
    # Nix-spezifische Umgebungsvariablen
    export NIX_BUILD_CORES=4
    export NIX_AUTO_OPTIMISE_STORE=1
  '';
  
  # Bash-Prompt (optional – nur wenn erwünscht)
  programs.bash.promptInit = ''
    # Einfacher, informativer Prompt
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
  '';
  
  # Assertions
  assertions = [
    {
      assertion = user == "moritz";
      message = "Shell-Modul ist nur für User 'moritz' konfiguriert. Passe 00-core/configs.nix an.";
    }
  ];
}
