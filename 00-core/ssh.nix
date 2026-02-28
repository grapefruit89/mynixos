/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-025
 *   title: "Ssh"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-CORE]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ lib, config, pkgs, ... }:
let
  sshPort = config.my.ports.ssh;
  user = config.my.configs.identity.user;
  hasAuthorizedKeys = (config.users.users.${user}.openssh.authorizedKeys.keys or [ ]) != [ ];
  allowPasswordFallback = !hasAuthorizedKeys;
  lanCidrs = config.my.configs.network.lanCidrs;
  tailnetCidrs = config.my.configs.network.tailnetCidrs;
  matchCidrs = lib.concatStringsSep "," (lanCidrs ++ tailnetCidrs);
in
{
  # 🚀 SSH EXHAUSTION
  services.openssh = {
    enable = true;
    openFirewall = false; # Via firewall.nix gesteuert
    ports = lib.mkForce [ sshPort ];
    
    settings = {
      # Grundlagen
      PermitRootLogin = lib.mkForce "no";
      PermitTTY = lib.mkForce true;
      PasswordAuthentication = lib.mkForce allowPasswordFallback;
      KbdInteractiveAuthentication = lib.mkForce allowPasswordFallback;
      AllowUsers = [ "${user}" ];
      
      # Hardening (Extreme SRE)
      LoginGraceTime = 20;
      MaxAuthTries = 3;
      ClientAliveInterval = 300;
      ClientAliveCountMax = 2;
      MaxSessions = 10;
      PermitEmptyPasswords = false;
      X11Forwarding = false;
      AllowAgentForwarding = false;
      AllowTcpForwarding = true; # Notwendig für Tunneling
      GatewayPorts = "no";
      Compression = "delayed";
      
      # Enforce Modern Ciphers & Algorithms
      HostKeyAlgorithms = "ssh-ed25519";
      KexAlgorithms = [
        "curve25519-sha256"
        "curve25519-sha256@libssh.org"
      ];
      Ciphers = [
        "chacha20-poly1305@openssh.com"
        "aes256-gcm@openssh.com"
        "aes128-gcm@openssh.com"
      ];
      Macs = [
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256-etm@openssh.com"
        "umac-128-etm@openssh.com"
      ];
    };

    # Deklarative Modifikatoren für lokale Netze
    extraConfig = ''
      Match Address 127.0.0.1,::1,${matchCidrs}
        PermitTTY yes
        AllowUsers ${user}
        # In lokalen Netzen etwas entspannter
        PasswordAuthentication ${if allowPasswordFallback then "yes" else "no"}
    '';
  };

  # SSHD Alive & OOM Protection
  systemd.services.sshd.serviceConfig = {
    Restart = "always";
    RestartSec = "5s";
    OOMScoreAdjust = lib.mkForce (-1000);
    # Hardening the service unit itself
    ProtectSystem = "full";
    ProtectHome = "read-only";
    PrivateTmp = true;
  };
}





/**
 * ---
 * technical_integrity:
 *   checksum: sha256:a830175a73c02438db5f1325f14a48ebbb3aecf9694558550258b467a80e1550
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
