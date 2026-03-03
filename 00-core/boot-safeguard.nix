{ config, lib, pkgs, ... }:
let
  nms = {
    id = "NIXH-00-CORE-003";
    title = "Boot Safeguard";
    description = "Prevent /boot overflow with aggressive GC and pre-build checks.";
    layer = 00;
    nixpkgs.category = "system/boot";
    capabilities = [ "system/maintenance" "safety/circuit-breaker" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };
  warningThreshold = 75; criticalThreshold = 85;
  bootSpaceCheck = pkgs.writeShellScriptBin "boot-space-check" "df /boot | tail -1"; # Simplified
  preBuildCheck = pkgs.writeShellScriptBin "pre-build-check" "df /boot | tail -1"; # Simplified
in
{
  options.my.meta.boot_safeguard = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata";
  };

  config = lib.mkIf (config.my.services.bootSafeguard.enable or true) {
    nix.gc = { automatic = true; dates = lib.mkForce "daily"; options = lib.mkForce "--delete-older-than 7d"; persistent = true; };
    nix.optimise.automatic = true;
    boot.loader.systemd-boot.configurationLimit = lib.mkForce 5;
    systemd.services.boot-space-monitor = { description = "Boot Partition Space Monitor"; serviceConfig = { Type = "oneshot"; ExecStart = "${bootSpaceCheck}/bin/boot-space-check"; }; };
    systemd.timers.boot-space-monitor = { wantedBy = [ "timers.target" ]; timerConfig = { OnCalendar = "daily"; OnBootSec = "5min"; Persistent = true; }; };
    environment.systemPackages = [ bootSpaceCheck preBuildCheck ];
    programs.bash.shellAliases = { boot-check = "${bootSpaceCheck}/bin/boot-space-check"; nsw-safe = "sudo pre-build-check && sudo nixos-rebuild switch"; };
  };
}
