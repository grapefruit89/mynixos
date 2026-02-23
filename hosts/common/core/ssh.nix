{ config, lib, ... }:
{
  # ── SSH SERVER ─────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    openFirewall = lib.mkForce true; # Erlaube den SSH-Port durch die Firewall

    settings = {
      Port = 22; # SSH Port 22 – EISERNES GESETZ – wird durch nichts überschrieben
      PermitRootLogin      = "no";    # Root-Login verboten
      PasswordAuthentication = false; # Nur Key-Login erlauben
      # AllowUsers = "moritz @192.168.2.*"; # Beispiel: SSH nur von bestimmten IPs erlauben
    };
  };

  # SSH Port 22 – EISERNES GESETZ – wird durch nichts überschrieben
  networking.firewall.allowedTCPPorts = lib.mkForce [ 22 80 443 ];

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
