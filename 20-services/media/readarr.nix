/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-033
 *   title: "readarr"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   upstream: [NIXH-00-SYS-DEFAULTS-001, NIXH-20-SRV-024]
 *   downstream: []
 *   status: audited
 * ---
 */

# =============================================================================
# modules/services/arr/readarr.nix
# =============================================================================
# Readarr — Buch/E-Book Downloader
# Nativport: 8787
#
# nixpkgs Basis: services/misc/servarr/readarr.nix @ 957de226
# Ergänzung: nixpkgs-readarr hatte kein Hardening — hier nachgerüstet
# =============================================================================
{ config, lib, pkgs, ... }:

let
  factory = import ./_servarr-factory.nix { inherit lib pkgs; };
  myLib   = import ../../00-core/lib/helpers.nix { inherit lib; };

  cfg  = config.my.media.readarr;
  defs = config.my.defaults;

  nativeName = "readarr";
  nativePort = 8787;

  stateDir = "${defs.paths.statePrefix}/${nativeName}";

  serviceBase = myLib.mkService {
    inherit config;
    name        = nativeName;
    port        = cfg.settings.server.port;
    useSSO      = defs.security.ssoEnable;
    description = "Readarr E-Book Downloader";
    netns       = cfg.netns;
  };
in
{
  options.my.media.readarr = {
    enable = lib.mkEnableOption "Readarr E-Book/Buch Downloader";

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
        description = "Readarr";
        after       = [ "network.target" ];
        wantedBy    = [ "multi-user.target" ];
        environment = factory.mkServarrSettingsEnvVars
          (lib.toUpper nativeName) cfg.settings;

        serviceConfig = {
          Type            = "simple";
          User            = cfg.user;
          Group           = cfg.group;
          EnvironmentFile = cfg.environmentFiles;
          ExecStart       = "${pkgs.readarr}/bin/Readarr -nobrowser -data='${cfg.stateDir}'";
          Restart         = "on-failure";
          ReadWritePaths  = [
            cfg.stateDir
            defs.paths.mediaRoot
            defs.paths.downloadsDir
          ];
        } // factory.mkServarrHardening;   # ← in nixpkgs fehlte das für Readarr!
      };

      systemd.tmpfiles.settings = factory.mkServarrTmpfiles nativeName cfg;

      networking.firewall.allowedTCPPorts = lib.mkForce [];

      users.users.${cfg.user} = lib.mkIf (cfg.user == nativeName) {
        group        = cfg.group;
        home         = cfg.stateDir;
        isSystemUser = true;
        description  = "Readarr service user";
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
