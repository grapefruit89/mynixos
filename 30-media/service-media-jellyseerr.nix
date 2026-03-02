/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-036
 *   title: "jellyseerr"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   upstream: [NIXH-00-SYS-DEFAULTS-001]
 *   downstream: []
 *   status: audited
 * ---
 */

# =============================================================================
# modules/services/arr/jellyseerr.nix
# =============================================================================
# Jellyseerr — Media-Request-Management für Jellyfin
# Nativport: 5055
#
# nixpkgs Basis: services/misc/jellyseerr.nix @ 957de226
#
# Jellyseerr ist KEIN servarr — kein settings-options.nix Factory.
# Konfiguration via settings.json (wird von Jellyseerr selbst geschrieben).
# Port-Konfiguration nur via Umgebungsvariable PORT.
#
# Besonderheit: Jellyseerr speichert API-Keys für Sonarr/Radarr in seiner
# eigenen DB — diese sind über die WebUI zu konfigurieren, nicht über Nix.
# =============================================================================
{ config, lib, pkgs, ... }:

let
  myLib = import ../00-core/lib-helpers.nix { inherit lib; };

  cfg  = config.my.media.jellyseerr;
  defs = config.my.defaults;

  nativeName = "jellyseerr";
  nativePort = 5055;

  stateDir = "${defs.paths.statePrefix}/${nativeName}";

  serviceBase = myLib.mkService {
    inherit config;
    name        = nativeName;
    port        = cfg.port;
    useSSO      = defs.security.ssoEnable;
    description = "Jellyseerr Media Request Management";
    netns       = cfg.netns;
  };
in
{
  options.my.media.jellyseerr = {
    enable = lib.mkEnableOption "Jellyseerr Media-Request-Management";

    stateDir = lib.mkOption {
      type    = lib.types.str;
      default = stateDir;
    };

    port = lib.mkOption {
      type    = lib.types.port;
      default = nativePort;
    };

    user = lib.mkOption {
      type    = lib.types.str;
      default = nativeName;
    };

    group = lib.mkOption {
      type    = lib.types.str;
      default = defs.security.defaultGroup;
    };

    netns = lib.mkOption {
      type    = lib.types.nullOr lib.types.str;
      default = defs.netns;
    };

    expose.enable = lib.mkOption {
      type    = lib.types.bool;
      default = true;
    };

    environmentFile = lib.mkOption {
      type    = lib.types.nullOr lib.types.path;
      default = null;
      description = "EnvironmentFile für Jellyseerr Secrets.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    serviceBase
    {
      # nixpkgs services.jellyseerr — vollständige Durchreiche
      services.jellyseerr = {
        enable = true;
        port   = cfg.port;
      };

      # Systemd-Override: User/Group + Hardening + stateDir
      systemd.services.jellyseerr = {
        environment = {
          # Jellyseerr liest CONFIG_DIRECTORY für seine settings.json
          CONFIG_DIRECTORY = lib.mkForce cfg.stateDir;
        };
        serviceConfig = {
          User           = cfg.user;
          Group          = cfg.group;
          ReadWritePaths = [ cfg.stateDir ];
          EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;

          # Hardening
          CapabilityBoundingSet   = "";
          NoNewPrivileges         = true;
          PrivateTmp              = true;
          PrivateDevices          = true;
          ProtectHome             = true;
          ProtectKernelLogs       = true;
          ProtectKernelModules    = true;
          ProtectKernelTunables   = true;
          ProtectControlGroups    = true;
          RestrictSUIDSGID        = true;
          RestrictNamespaces      = true;
          RestrictRealtime        = true;
          LockPersonality         = true;
          SystemCallArchitectures = "native";
          SystemCallFilter        = [ "@system-service" "~@privileged" "~@debug" "~@mount" ];
          UMask                   = "0022";
          ProtectHostname         = true;
          ProtectProc             = "invisible";
          ProcSubset              = "pid";
          RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
        };
      };

      systemd.tmpfiles.settings."10-jellyseerr" = {
        ${cfg.stateDir}.d = {
          inherit (cfg) user group;
          mode = "0700";
        };
      };

      networking.firewall.allowedTCPPorts = lib.mkForce [];

      users.users.${cfg.user} = lib.mkIf (cfg.user == nativeName) {
        group        = cfg.group;
        home         = cfg.stateDir;
        isSystemUser = true;
        description  = "Jellyseerr service user";
      };
      users.groups.${cfg.group} = lib.mkDefault {};
    }
  ]);
}

/**
 * ---
 * technical_integrity:
 *   checksum: sha256:PLACEHOLDER
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-01
 *   complexity_score: 3
 * ---
 */
