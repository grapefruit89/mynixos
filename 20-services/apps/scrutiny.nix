/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-014
 *   title: "Scrutiny"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ config, lib, ... }:
let
  myLib = import ../../lib/helpers.nix { inherit lib; };
  cfg = config.my.profiles.services.scrutiny;
  serviceBase = myLib.mkService {
    inherit config;
    name = "scrutiny";
    useSSO = true;
    description = "Hard Drive Monitoring (Exhausted)";
  };
in
lib.mkIf cfg.enable (lib.mkMerge [
  serviceBase
  {
    # 🚀 SCRUTINY EXHAUSTION
    services.scrutiny = {
      enable = true;
      
      # VOLL-DEKLARATIVE EINSTELLUNGEN
      settings = {
        web.listen.port = config.my.ports.scrutiny;
        web.listen.host = "127.0.0.1";
        
        # SRE: Metrics & Monitoring
        log.level = "info";
        notify.urls = []; # Platzhalter für Gotify/Discord
      };

      # Collector aktivieren (Automatischer Scan)
      collector = {
        enable = true;
        interval = "15m";
      };
    };

    # systemd Hardening (SRE High-Trust)
    systemd.services.scrutiny.serviceConfig = {
      DeviceAllow = [ "/dev/sda rw" "/dev/sdb rw" "/dev/nvme0n1 rw" ];
      CapabilityBoundingSet = [ "CAP_SYS_RAWIO" "CAP_SYS_ADMIN" ];
      ProtectSystem = lib.mkForce "strict";
      ReadWritePaths = [ "/var/lib/scrutiny" ];
    };
  }
])



/**
 * ---
 * technical_integrity:
 *   checksum: sha256:9d49e3996b6f447d61aa260c7fa03c8140a76f934d8a799f3d4c1c8e96decc06
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
