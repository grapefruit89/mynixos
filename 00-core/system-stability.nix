/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: id:
 *   title: "System Stability"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-CORE]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ config, lib, pkgs, ... }:
{
  # 🚀 SYSTEM STABILITY & OOM-PROTECTION (2026 Standard)
  
  # 1. SSHD: UNANTASTBARKEIT (Anti-OOM)
  systemd.services.sshd.serviceConfig = {
    OOMScoreAdjust = -1000;
    Restart = "always";
    RestartSec = "5s";
  };

  # 2. KRITISCHE DIENSTE SCHÜTZEN
  systemd.services.caddy.serviceConfig.OOMScoreAdjust = -500;
  systemd.services.pocket-id.serviceConfig.OOMScoreAdjust = -500;

  # 3. NIX-DAEMON: OPFER-MODUS
  systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = 500;

  # 4. SSH OPTIMIERUNG
  services.openssh = {
    settings = {
      PasswordAuthentication = lib.mkDefault false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
      Ciphers = [ "aes256-gcm@openssh.com" "chacha20-poly1305@openssh.com" ];
      KexAlgorithms = [ "curve25519-sha256" "curve25519-sha256@libssh.org" ];
    };
  };

  # 5. Cockpit Management
  services.cockpit = {
    enable = true;
    settings.WebService.AllowUnencrypted = true;
  };
}


/**
 * ---
 * technical_integrity:
 *   checksum: sha256:ed8f799cf8dc50934abb1c3519de1af6d639e324e36c0a0d19f735ab1351899d
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
