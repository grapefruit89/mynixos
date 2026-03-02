/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-025
 *   title: "SSH (SRE Expert Edition)"
 *   layer: 00
 * summary: Hardened SSH daemon with connection protection and modern crypto.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/ssh/sshd.nix
 * ---
 */
{ lib, config, pkgs, ... }:
let
  sshPort = config.my.ports.ssh;
  user = config.my.configs.identity.user;
  lanCidrs = config.my.configs.network.lanCidrs;
  tailnetCidrs = config.my.configs.network.tailnetCidrs;
  matchCidrs = lib.concatStringsSep "," (lanCidrs ++ tailnetCidrs);
in
{
  services.openssh = {
    enable = true;
    openFirewall = false; # Gesteuert via 00-core/firewall.nix
    ports = lib.mkForce [ 22 sshPort ];
    
    settings = {
      # ── GRUNDLAGEN ────────────────────────────────────────────────────────
      PermitRootLogin = "no";
      PasswordAuthentication = false; # Key-only Standard
      KbdInteractiveAuthentication = false;
      AllowUsers = [ "${user}" ];
      LogLevel = "VERBOSE"; # Erhöhte Sichtbarkeit für SRE-Audits
      
      # ── HARDENING ─────────────────────────────────────────────────────────
      LoginGraceTime = 20;   # Schneller Timeout bei Geister-Logins
      MaxAuthTries = 3;      # Strikte Begrenzung gegen Brute-Force
      ClientAliveInterval = 300;
      ClientAliveCountMax = 2;
      
      # ── MODERNE CRYPTO (Infosec Standard 2026) ───────────────────────────
      KexAlgorithms = [
        "curve25519-sha256"
        "curve25519-sha256@libssh.org"
        "sntrup761x25519-sha512@openssh.com" # Post-Quantum Resilience
      ];
      Ciphers = [
        "chacha20-poly1305@openssh.com"
        "aes256-gcm@openssh.com"
      ];
    };

    # ── LOKALE AUSNAHMEN (Match Block) ──────────────────────────────────────
    extraConfig = ''
      # In vertrauenswürdigen Netzen erlauben wir TTY und X11-Forwarding
      Match Address 127.0.0.1,::1,${matchCidrs}
        X11Forwarding yes
        AllowTcpForwarding yes
        GatewayPorts yes
    '';
  };

  # ── SYSTEMD SRE TUNING ──────────────────────────────────────────────────
  systemd.services.sshd = {
    # 🚀 KRITISCH: Verhindert Verbindungsabbruch bei nixos-rebuild
    stopIfChanged = false;

    serviceConfig = {
      Restart = "always";
      RestartSec = "5s";
      
      # Sandboxing des SSH-Prozesses
      ProtectProc = "invisible";
      ProcSubset = "pid";
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      CapabilityBoundingSet = [ "CAP_CHOWN" "CAP_SETUID" "CAP_SETGID" "CAP_SYS_CHROOT" "CAP_AUDIT_WRITE" "CAP_NET_BIND_SERVICE" ];
    };
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
