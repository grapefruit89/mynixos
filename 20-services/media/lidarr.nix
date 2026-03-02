/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-034
 *   title: "lidarr"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   upstream: [NIXH-00-SYS-DEFAULTS-001, NIXH-20-SRV-024]
 *   downstream: []
 *   status: audited
 * ---
 */

# =============================================================================
# modules/services/arr/lidarr.nix
# =============================================================================
# Lidarr — Musik Downloader
# Nativport: 8686
#
# nixpkgs Basis: services/misc/servarr/lidarr.nix @ 957de226
# Ergänzung: nixpkgs-lidarr hatte kein Hardening — hier nachgerüstet
# =============================================================================
{ config, lib, pkgs, ... }:

let
  factory = import ./_servarr-factory.nix { inherit lib pkgs; };
  myLib   = import ../../00-core/lib/helpers.nix { inherit lib; };

  cfg  = config.my.media.lidarr;
  defs = config.my.defaults;

  nativeName = "lidarr";
  nativePort = 8686;

  stateDir = "${defs.paths.statePrefix}/${nativeName}/.config/Lidarr";

  serviceBase = myLib.mkService {
    inherit config;
    name        = nativeName;
    port        = cfg.settings.server.port;
    useSSO      = defs.security.ssoEnable;
    description = "Lidarr Music Downloader";
    netns       = cfg.netns;
  };
in
{
  options.my.media.lidarr = {
    enable = lib.mkEnableOption "Lidarr Musik-Downloader";

    stateDir = lib.mkOption {
      type    = lib.types.str;
      default = stateDir;
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

    settings         = factory.mkServarrSettingsOptions nativeName nativePort;
    environmentFiles = factory.mkServarrEnvironmentFiles nativeName;
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    serviceBase
    {
      systemd.services.${nativeName} = {
        description = "Lidarr";
        after       = [ "network.target" ];
        wantedBy    = [ "multi-user.target" ];
        environment = factory.mkServarrSettingsEnvVars
          (lib.toUpper nativeName) cfg.settings;

        serviceConfig = {
          Type            = "simple";
          User            = cfg.user;
          Group           = cfg.group;
          EnvironmentFile = cfg.environmentFiles;
          ExecStart       = "${pkgs.lidarr}/bin/Lidarr -nobrowser -data='${cfg.stateDir}'";
          Restart         = "on-failure";
          ReadWritePaths  = [
            cfg.stateDir
            defs.paths.mediaRoot
            defs.paths.downloadsDir
          ];
        } // factory.mkServarrHardening;   # ← in nixpkgs fehlte das für Lidarr!
      };

      systemd.tmpfiles.settings = factory.mkServarrTmpfiles nativeName cfg;

      networking.firewall.allowedTCPPorts = lib.mkForce [];

      users.users.${cfg.user} = lib.mkIf (cfg.user == nativeName) {
        group        = cfg.group;
        home         = "/var/lib/${nativeName}";
        uid          = config.ids.uids.lidarr;
        isSystemUser = false;
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
