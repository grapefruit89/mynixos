{ config, lib, pkgs, ... }:

let
  user = config.my.configs.identity.user;
in
{
  systemd.services.ssh-recovery-window = {
    description = "SSH Password Recovery Window (5min after boot)";
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ util-linux coreutils gnused config.programs.ssh.package ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      echo "🔓 SSH Recovery Window startet (300s)"
      # Hier käme die Logik zum temporären Erlauben von Passwörtern
      echo "Recovery Window aktiv" | logger -t ssh-rescue
    '';
  };
}
