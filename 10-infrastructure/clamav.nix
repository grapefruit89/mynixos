/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-003
 *   title: "ClamAV (SRE Hardened)"
 *   layer: 10
 * summary: Antivirus protection with resource limits and automated updates.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/security/clamav.nix
 * ---
 */
{ config, lib, pkgs, ... }:
{
  # ── CLAMAV DAEMON & UPDATER ──────────────────────────────────────────────
  services.clamav = {
    daemon.enable = true;
    updater.enable = true; # freshclam
    
    # 🕵️ SRE SCANNER (Wöchentlicher Scan)
    scanner = {
      enable = true;
      interval = "Sat *-*-* 03:00:00"; # Samstags nachts
      scanDirectories = [ "/home" "/var/lib" "/etc" ];
    };
  };

  # ── RESSOURCENSCHUTZ (Schutz vor CPU-Heißlaufen) ────────────────────────
  # ClamAV kann beim Scannen extrem viel CPU fressen.
  # Wir limitieren den Scan-Prozess auf 2 Kerne und geben ihm 'idle' Priorität.
  systemd.services.clamdscan = {
    serviceConfig = {
      CPUWeight = 20;
      IOWeight = 20;
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
    };
  };

  # ── SRE SANDBOXING ───────────────────────────────────────────────────────
  systemd.services.clamav-daemon.serviceConfig = {
    # Aus nixpkgs übernommen
    ProtectSystem = "strict";
    PrivateTmp = true;
    PrivateDevices = true;
    NoNewPrivileges = true;
    # ClamAV braucht keine Netzwerk-Capabilities
    CapabilityBoundingSet = [ "" ];
    # OOM-Schutz: ClamAV darf im Zweifel als erstes sterben
    OOMScoreAdjust = 1000;
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
