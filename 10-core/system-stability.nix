/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        System Stability
 * TRACE-ID:     NIXH-CORE-019
 * REQ-REF:      REQ-CORE
 * LAYER:        10
 * STATUS:       Stable
 * INTEGRITY:    SHA256:652b68f6b1062e8e92a40add10f8974d3884c763ba12486f3f540249fd4b3fc6
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
