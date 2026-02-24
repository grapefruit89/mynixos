{ lib, ... }:
{
  services.openssh = {
    enable = true;
    openFirewall = false;
    ports = lib.mkForce [ 53844 ];

    settings = {
      PermitRootLogin = lib.mkForce "no";
      PasswordAuthentication = lib.mkForce false;
      KbdInteractiveAuthentication = lib.mkForce false;
      AllowUsers = [ "moritz" ];
    };

    # Zugriff nur aus internen Netzen/Loopback/Tailscale-CGNAT.
    extraConfig = ''
      Match Address 127.0.0.1,::1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12,100.64.0.0/10
        PermitTTY yes
        AllowUsers moritz
      Match All
        PermitTTY no
        AllowUsers NOBODY_GETS_IN
    '';
  };

  systemd.services.sshd.serviceConfig = {
    Restart = "always";
    RestartSec = "5s";
    OOMScoreAdjust = lib.mkForce (-1000);
  };
}
