/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-031
 *   title: "radarr"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   upstream: [NIXH-00-SYS-DEFAULTS-001, NIXH-20-SRV-024]
 *   downstream: []
 *   status: audited
 * ---
 */

# =============================================================================
# modules/services/arr/radarr.nix
# =============================================================================
# Radarr — Film Downloader
# Nativport: 7878
#
# nixpkgs Basis: services/misc/servarr/radarr.nix @ 957de226
# Änderungen: identisch zu sonarr.nix (siehe dort)
# =============================================================================
{ config, lib, pkgs, ... }:

let
  factory = import ./_servarr-factory.nix { inherit lib pkgs; };
  myLib   = import ../../00-core/lib/helpers.nix { inherit lib; };

  cfg  = config.my.media.radarr;
  defs = config.my.defaults;

  nativeName = "radarr";
  nativePort = 7878;

  stateDir = "${defs.paths.statePrefix}/${nativeName}/.config/Radarr";

  serviceBase = myLib.mkService {
    inherit config;
    name        = nativeName;
    port        = cfg.settings.server.port;
    useSSO      = defs.security.ssoEnable;
    description = "Radarr Movie Downloader";
    netns       = cfg.netns;
  };
in
{
  options.my.media.radarr = {
    enable = lib.mkEnableOption "Radarr Film-Downloader";

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
        description = "Radarr";
        after       = [ "network.target" ];
        wantedBy    = [ "multi-user.target" ];
        environment = factory.mkServarrSettingsEnvVars
          (lib.toUpper nativeName) cfg.settings;

        serviceConfig = {
          Type            = "simple";
          User            = cfg.user;
          Group           = cfg.group;
          EnvironmentFile = cfg.environmentFiles;
          ExecStart       = "${pkgs.radarr}/bin/Radarr -nobrowser -data='${cfg.stateDir}'";
          Restart         = "on-failure";
                      ReadWritePaths  = [
                        cfg.stateDir
                        defs.paths.mediaRoot
                        defs.paths.downloadsDir
                      ];
                      BindPaths = [
                        "${defs.paths.fastPoolRoot}/metadata/${nativeName}:/var/lib/${nativeName}/MediaCover"
                      ];
                    } // factory.mkServarrHardening;
                  };
          
                  systemd.tmpfiles.settings = (factory.mkServarrTmpfiles nativeName cfg) // {
                    "10-${nativeName}-meta"."${defs.paths.fastPoolRoot}/metadata/${nativeName}".d = {
                      inherit (cfg) user group;
                      mode = "0750";
                    };
                  };
          
                  networking.firewall.allowedTCPPorts = lib.mkForce [];
                users.users.${cfg.user} = lib.mkIf (cfg.user == nativeName) {
        group        = cfg.group;
        home         = cfg.stateDir;
        uid          = config.ids.uids.radarr;
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
