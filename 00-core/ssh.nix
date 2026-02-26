# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: ssh Modul

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
  # [SEC-SSH-SVC-001] OpenSSH service must stay enabled.
  services.openssh = {
    enable = true;
    openFirewall = false;
    ports = lib.mkForce [ sshPort ];

    settings = {
      PermitRootLogin = lib.mkForce "no";
      # [SEC-SSH-TTY-001]
      PermitTTY = lib.mkForce true;
      # [SEC-SSH-AUTH-001]/[SEC-SSH-AUTH-002]
      PasswordAuthentication = lib.mkForce allowPasswordFallback;
      # [SEC-SSH-AUTH-001]/[SEC-SSH-AUTH-002]
      KbdInteractiveAuthentication = lib.mkForce allowPasswordFallback;
      AllowUsers = [ "${user}" ];

      # Härtungs-Parameter (Audit Fixes)
      LoginGraceTime = 20;              # Timeout bei Login-Prompt: 20 Sekunden
      MaxAuthTries = 3;                 # Nur 3 Passwort-Versuche
      ClientAliveInterval = 300;        # Keep-Alive alle 5 Minuten
      ClientAliveCountMax = 2;          # Nach 2 fehlenden Responses: Disconnect
      MaxSessions = 10;
      PermitEmptyPasswords = false;
    };

    # Zugriff nur aus internen Netzen/Loopback/Tailscale-CGNAT.
    extraConfig = ''
      Match Address 127.0.0.1,::1,${matchCidrs}
        PermitTTY yes
        AllowUsers ${user}
    '';
  };

  # [SEC-SSH-AUTH-002] Explizite Warnung in den Logs, wenn Passwort-Fallback aktiv ist.
  systemd.services.ssh-password-fallback-warning = lib.mkIf allowPasswordFallback {
    description = "Warn when SSH password fallback is active";
    wantedBy = [ "multi-user.target" ];
    after = [ "sshd.service" ];
    serviceConfig = {
      Type = "oneshot";
    };
    path = with pkgs; [ util-linux coreutils ];
    script = ''
      msg="WARNING: No SSH authorized key for user '${user}' found. PasswordAuthentication/KbdInteractiveAuthentication are enabled as emergency fallback. Add key to disable password login."
      echo "$msg" >&2
      logger -p authpriv.warning -t ssh-fallback "$msg"
    '';
  };

  # [SEC-SSH-SVC-002] Keep sshd alive and restartable.
  systemd.services.sshd.serviceConfig = {
    Restart = "always";
    RestartSec = "5s";
    OOMScoreAdjust = lib.mkForce (-1000);
  };
}
