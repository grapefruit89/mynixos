/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-017
 *   title: "Vaultwarden"
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
  serviceBase = myLib.mkService {
    inherit config;
    name = "vaultwarden";
    useSSO = false;
    description = "Password Manager (Hardened)";
  };
in
lib.mkMerge [
  serviceBase
  {
    # 🚀 VAULTWARDEN EXHAUSTION
    services.vaultwarden = {
      enable = true;
      
      # DEKLARATIVE KONFIGURATION
      config = {
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = config.my.ports.vaultwarden;
        
        # SRE PERFORMANCE & SECURITY
        SIGNUPS_ALLOWED = false;
        INVITATIONS_ALLOWED = true;
        SHOW_PASSWORD_HINT = false;
        DATABASE_MAX_CONNS = 10;
      };

      # 🛡️ SECURE SECRET HANDLING
      # Nutzt eine sops-entschlüsselte Datei für SMTP/Admin-Token
      # environmentFile = config.sops.secrets.vaultwarden_env.path;
    };

    # systemd Hardening (Extreme SRE)
    systemd.services.vaultwarden.serviceConfig = {
      ProtectSystem = lib.mkForce "strict";
      ReadWritePaths = [ "/var/lib/vaultwarden" ];
      
      # Sicherheits-Richtlinien
      MemoryDenyWriteExecute = true;
      RestrictAddressFamilies = [ "AF_INET" "AF_UNIX" ];
      SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
      CapabilityBoundingSet = ""; # Keine Privilegien notwendig
      DevicePolicy = "closed";
    };
  }
]





/**
 * ---
 * technical_integrity:
 *   checksum: sha256:686a3e8e8ba1752b272063eae061c88d147e62f7fb6c0e6cb361f0d214ec67eb
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
