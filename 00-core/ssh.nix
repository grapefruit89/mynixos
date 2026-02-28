/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Hardened SSH Stack
 * TRACE-ID:     NIXH-CORE-030
 * PURPOSE:      Sichere SSH-Konfiguration (Ed25519-only, Anti-OOM, restricted Ciphers).
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [00-core/configs.nix, 00-core/ports.nix]
 * LAYER:        00-core
 * STATUS:       Stable
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
  services.openssh = {
    enable = true;
    openFirewall = false;
    ports = lib.mkForce [ sshPort ];

    settings = {
      PermitRootLogin = lib.mkForce "no";
      PermitTTY = lib.mkForce true;
      PasswordAuthentication = lib.mkForce allowPasswordFallback;
      KbdInteractiveAuthentication = lib.mkForce allowPasswordFallback;
      AllowUsers = [ "${user}" ];

      # Hardening
      LoginGraceTime = 20;
      MaxAuthTries = 3;
      ClientAliveInterval = 300;
      ClientAliveCountMax = 2;
      MaxSessions = 10;
      PermitEmptyPasswords = false;
      
      # Enforce Ed25519
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

    extraConfig = ''
      Match Address 127.0.0.1,::1,${matchCidrs}
        PermitTTY yes
        AllowUsers ${user}
    '';
  };

  # SSHD Alive & OOM Protection
  systemd.services.sshd.serviceConfig = {
    Restart = "always";
    RestartSec = "5s";
    OOMScoreAdjust = lib.mkForce (-1000);
  };
}
