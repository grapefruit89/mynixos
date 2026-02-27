{ config, lib, pkgs, ... }: {
  systemd.services.ssh-rescue-window = {
    description = "SRE: Temporäres Passwort-Login Fenster";
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = "echo 'Rescue-Fenster aktiv' | logger -t SRE-SSH";
  };
}
