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
  services.openssh.enable = true;
  services.openssh.openFirewall = false;
  services.openssh.ports = lib.mkForce [ sshPort ];

  services.openssh.settings.PermitRootLogin = lib.mkForce "no";
  services.openssh.settings.PermitTTY = lib.mkForce true;
  services.openssh.settings.PasswordAuthentication = lib.mkForce allowPasswordFallback;
  services.openssh.settings.KbdInteractiveAuthentication = lib.mkForce allowPasswordFallback;
  services.openssh.settings.AllowUsers = [ "${user}" ];

  # Hardening
  services.openssh.settings.LoginGraceTime = 20;
  services.openssh.settings.MaxAuthTries = 3;
  services.openssh.settings.ClientAliveInterval = 300;
  services.openssh.settings.ClientAliveCountMax = 2;
  services.openssh.settings.MaxSessions = 10;
  services.openssh.settings.PermitEmptyPasswords = false;
  
  # Enforce Ed25519
  services.openssh.settings.HostKeyAlgorithms = "ssh-ed25519";
  services.openssh.settings.KexAlgorithms = [
    "curve25519-sha256"
    "curve25519-sha256@libssh.org"
  ];
  services.openssh.settings.Ciphers = [
    "chacha20-poly1305@openssh.com"
    "aes256-gcm@openssh.com"
    "aes128-gcm@openssh.com"
  ];
  services.openssh.settings.Macs = [
    "hmac-sha2-512-etm@openssh.com"
    "hmac-sha2-256-etm@openssh.com"
    "umac-128-etm@openssh.com"
  ];

  services.openssh.extraConfig = ''
    Match Address 127.0.0.1,::1,${matchCidrs}
      PermitTTY yes
      AllowUsers ${user}
  '';

  # SSHD Alive & OOM Protection
  systemd.services.sshd.serviceConfig.Restart = "always";
  systemd.services.sshd.serviceConfig.RestartSec = "5s";
  systemd.services.sshd.serviceConfig.OOMScoreAdjust = lib.mkForce (-1000);
}




/**
 * ---
 * technical_integrity:
 *   checksum: sha256:8e917c7f426e4be282b09cc244544311ec3f666eff9fd5fbf882f6ba822f8c1b
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
