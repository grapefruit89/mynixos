{ config, lib, pkgs, ... }:
{
  # 🚀 SYSTEM STABILITY & OOM-PROTECTION (2026 Standard)
  
  # 1. SSHD: UNANTASTBARKEIT (Anti-OOM)
  # Wir setzen SSHD auf eine OOM-Priorität, die ihn vor dem Killer schützt.
  systemd.services.sshd.serviceConfig = {
    OOMScoreAdjust = -1000; # Höchster Schutz (unantastbar für den OOM-Killer)
    Restart = "always";
    RestartSec = "5s";
  };

  # 2. KRITISCHE DIENSTE SCHÜTZEN
  # Caddy (Proxy) und Pocket-ID (Auth) sind ebenfalls überlebenswichtig.
  systemd.services.caddy.serviceConfig.OOMScoreAdjust = -500;
  systemd.services.pocket-id.serviceConfig.OOMScoreAdjust = -500;

  # 3. NIX-DAEMON: OPFER-MODUS
  # Falls der RAM voll ist, soll der Nix-Build-Prozess zuerst sterben,
  # damit das System (SSH/Media) erreichbar bleibt.
  systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = 500;

  # 4. SSH OPTIMIERUNG (Kein Legacy!)
  # Wir nutzen moderne Kryptographie (Ed25519) und verbieten alten Müll.
  services.openssh = {
    settings = {
      PasswordAuthentication = lib.mkDefault false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
      # Nur moderne Ciphers & MACs (2026 Standard)
      Ciphers = [ "aes256-gcm@openssh.com" "chacha20-poly1305@openssh.com" ];
      KexAlgorithms = [ "curve25519-sha256" "curve25519-sha256@libssh.org" ];
    };
  };

  # 5. ALTERNATIVE ZU SSH? (Modernes Remote Management)
  # Cockpit ist die moderne, webbasierte Alternative für Monitoring & Management.
  services.cockpit = {
    enable = true;
    port = 9090;
    settings.WebService.AllowUnencrypted = true; # Hinter Caddy/Tailscale okay
  };
}
