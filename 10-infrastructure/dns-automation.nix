{ config, pkgs, ... }:
# DNS-Guard Automation: Runs every 30 mins to avoid Cloudflare conflicts.
# source: /etc/nixos/10-infrastructure/dns-automation.nix
{
  systemd.services.dns-guard = {
    description = "Check Cloudflare for DNS conflicts and update dns-map.nix";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash /etc/nixos/scripts/dns-guard.sh";
    };
    path = with pkgs; [ curl jq coreutils gnugrep ];
  };

  systemd.timers.dns-guard = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "30min";
    };
  };
}
