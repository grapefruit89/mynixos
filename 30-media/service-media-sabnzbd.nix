/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-035
 *   title: "sabnzbd"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   upstream: [NIXH-00-SYS-DEFAULTS-001]
 *   downstream: []
 *   status: audited
 * ---
 */

# =============================================================================
# modules/services/arr/sabnzbd.nix
# =============================================================================
# SABnzbd — Usenet Download Client
# Nativport: 8080 (intern: 20080 aus deinem _lib Modul)
#
# nixpkgs Basis: services/misc/sabnzbd.nix @ 957de226
# SABnzbd ist KEIN servarr — kein settings-options.nix Factory.
# Konfiguration über sabnzbd.ini (nicht über Env-Vars wie arr-Apps).
#
# Wichtig: SABnzbd schreibt seine eigene Config. Die initiale Config
# kann über configFile vorgegeben werden, wird dann aber von SABnzbd
# selbst überschrieben. Secrets → environmentFile.
# =============================================================================
{ config, lib, pkgs, ... }:

let
  myLib = import ../00-core/lib-helpers.nix { inherit lib; };

  cfg  = config.my.media.sabnzbd;
  defs = config.my.defaults;

  nativeName = "sabnzbd";
  nativePort = 20080;   # interner Port aus deinem _lib Modul

  stateDir = "${defs.paths.statePrefix}/${nativeName}";

  serviceBase = myLib.mkService {
    inherit config;
    name        = nativeName;
    port        = cfg.port;
    useSSO      = defs.security.ssoEnable;
    description = "SABnzbd Usenet Download Client";
    netns       = cfg.netns;
  };
in
{
  options.my.media.sabnzbd = {
    enable = lib.mkEnableOption "SABnzbd Usenet Download Client";

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

    # SABnzbd hat kein settings-options.nix Pattern (kein servarr)
    # Konfiguration via sabnzbd.ini — nur Secrets über environmentFile
    environmentFile = lib.mkOption {
      type    = lib.types.nullOr lib.types.path;
      default = null;
      description = "EnvironmentFile für SABnzbd Secrets (API-Key, NZB-Provider-Credentials).";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    serviceBase
    {
      # nixpkgs services.sabnzbd — vollständige Durchreiche
      services.sabnzbd = {
        enable  = true;
        user    = cfg.user;
        group   = cfg.group;
        # SABnzbd verwaltet seine config selbst in stateDir
        # configFile nicht setzen — SABnzbd überschreibt es sowieso
      };

      # Port-Override via systemd (nixpkgs sabnzbd hat kein port-Option)
      systemd.services.sabnzbd = {
        environment = {
          SAB_CONFIG_FILE = "${cfg.stateDir}/sabnzbd.ini";
        };
        serviceConfig = {
          User           = cfg.user;
          Group          = cfg.group;
          ReadWritePaths = [
            cfg.stateDir
            defs.paths.downloadsDir
          ];
          EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;

          # Hardening (sabnzbd braucht mehr Rechte als arr-Apps — kein @chown etc.)
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
          SystemCallFilter        = [ "@system-service" "~@privileged" "~@debug" ];
          UMask                   = "0022";
        };
      };

      systemd.tmpfiles.settings."10-sabnzbd" = {
        ${cfg.stateDir}.d = {
          inherit (cfg) user group;
          mode = "0700";
        };
        "${defs.paths.downloadsDir}/incomplete".d = {
          inherit (cfg) user group;
          mode = "0750";
        };
        "${defs.paths.downloadsDir}/complete".d = {
          inherit (cfg) user group;
          mode = "0750";
        };
      };

      networking.firewall.allowedTCPPorts = lib.mkForce [];

      users.users.${cfg.user} = lib.mkIf (cfg.user == nativeName) {
        group        = cfg.group;
        home         = cfg.stateDir;
        isSystemUser = true;
        description  = lib.mkForce "SABnzbd service user";
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
