{ config, lib, ... }:
{
  # ── SSH SERVER ─────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    extraConfig = ''
      Match Address *,!10.0.0.0/8,!172.16.0.0/12,!192.168.0.0/16,!100.64.0.0/10
        ForceCommand /bin/false
        X11Forwarding no
        PermitTTY no
    '';
    settings = {
      Port = 22; # SSH Port 22 – EISERNES GESETZ – wird durch nichts überschrieben
      PermitRootLogin      = "no";    # Root-Login verboten
      PasswordAuthentication = false; # Nur Key-Login erlauben
    };
  };

  # OOM-Schutz – sshd wird niemals gekillt
  systemd.services.sshd.serviceConfig = {
    OOMScoreAdjust = lib.mkForce (-1000);
    Restart = lib.mkForce "always";
    RestartSec = "5s";
  };

  # fail2ban – sperrt IPs nach zu vielen fehlgeschlagenen SSH-Versuchen
  services.fail2ban = {
    enable = true;
    maxretry = 5;
  };

  # Automatische Sicherheitsupdates – nur für Security-Patches
  system.autoUpgrade = {
    enable = lib.mkForce true;
    allowReboot = false;
    flags = [ "--update-input" "nixpkgs" ];
  };

  # Kernel Hardening
  security.protectKernelImage = true;
  boot.kernel.sysctl."net.ipv4.tcp_syncookies" = 1;
}
