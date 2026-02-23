{ lib, ... }:
{
  # ── SSH SERVER ───────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    ports = lib.mkForce [ 53844 ];
    settings.PasswordAuthentication = lib.mkForce false;
    settings.KbdInteractiveAuthentication = lib.mkForce false;
    settings.AllowUsers = [ "moritz" ];
    settings.PermitRootLogin = lib.mkForce "no";
  };

  systemd.services.sshd.serviceConfig = {
    Restart = "always";
    RestartSec = "5s";
    OOMScoreAdjust = -1000;
  };
}
