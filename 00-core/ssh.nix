{ config, lib, ... }:
{
  # ── SSH SERVER ─────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    # Port 53844 ist der einzige SSH-Port.
    ports = lib.mkForce [ 53844 ];
    extraConfig = ''
      # Kein Port 22 mehr.
    '';
    settings = {
      # Port zusätzlich in sshd_config festgenagelt (Fallback, falls ports-Option ignoriert würde).
      Port = 53844;
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
