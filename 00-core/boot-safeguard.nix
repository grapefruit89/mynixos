{ config, lib, pkgs, ... }:

let
  bootSpaceCheck = pkgs.writeShellScriptBin "boot-check" ''
    export PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.gawk pkgs.gnused ]}:$PATH
    
    BOOT_USAGE=$(df /boot | tail -1 | awk '{print $5}' | sed 's/%//')
    BOOT_AVAIL=$(df -h /boot | tail -1 | awk '{print $4}')
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔍 Boot-Partition Status"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [ "$BOOT_USAGE" -ge 85 ]; then
      echo "Status:   KRITISCH"
    elif [ "$BOOT_USAGE" -ge 75 ]; then
      echo "Status:   WARNUNG"
    else
      echo "Status:   OK"
    fi
    echo "Füllstand: $BOOT_USAGE%"
    echo "Frei:      $BOOT_AVAIL"
  '';
in
{
  environment.systemPackages = [ bootSpaceCheck ];

  systemd.services.boot-space-monitor = {
    description = "Boot Partition Space Monitor";
    path = with pkgs; [ coreutils gawk gnused ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${bootSpaceCheck}/bin/boot-check";
    };
  };

  systemd.timers.boot-space-monitor = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };
}
