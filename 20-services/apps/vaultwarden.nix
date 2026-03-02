/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-017
 *   title: "Vaultwarden (Aviation Grade)"
 *   layer: 20
 * summary: Tightly sandboxed password manager.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/security/vaultwarden/default.nix
 * ---
 */
{ config, lib, ... }:
let
  myLib = import ../../lib/helpers.nix { inherit lib; };
  serviceBase = myLib.mkService {
    inherit config;
    name = "vaultwarden";
    useSSO = false;
    description = "Password Manager (Aviation Grade Security)";
  };
in
lib.mkMerge [
  serviceBase
  {
    services.vaultwarden = {
      enable = true;
      config = {
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = config.my.ports.vaultwarden;
        SIGNUPS_ALLOWED = false;
        INVITATIONS_ALLOWED = true;
        SHOW_PASSWORD_HINT = false;
        DATABASE_MAX_CONNS = 10;
      };
      environmentFile = config.sops.secrets.vaultwarden_env.path;
    };

    # ── ULTIMATIVE ISOLATION (Extracted from nixpkgs & Security Best-Practices) ──
    systemd.services.vaultwarden.serviceConfig = {
      ProtectSystem = lib.mkForce "strict";
      ReadWritePaths = [ "/var/lib/vaultwarden" ];
      
      # Schutz vor Pufferüberläufen und Code-Injektion
      MemoryDenyWriteExecute = true;
      
      # Netzwerk-Beschränkung (Kein IPv6, kein Bluetooth, keine Roh-Sockets)
      RestrictAddressFamilies = [ "AF_INET" "AF_UNIX" ];
      
      # System-Call Filter (Der ultimative Schutz)
      # Wir erlauben nur Standard-Service-Calls und verbieten Ressourcen-intensives Tuning.
      SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
      
      # Privilegien-Entzug
      CapabilityBoundingSet = ""; # Absolute Null-Toleranz für Privilegien
      NoNewPrivileges = true;
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      LockPersonality = true;
      PrivateDevices = true;
      PrivateTmp = true;
      DevicePolicy = "closed";
      
      # Prozess-Sichtbarkeit einschränken
      ProtectProc = "invisible";
      ProcSubset = "pid";
    };
  }
]
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
