/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-030
 *   title: "sonarr"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   upstream: [NIXH-00-SYS-DEFAULTS-001, NIXH-20-SRV-024]
 *   downstream: []
 *   status: audited
 * ---
 */

# =============================================================================
# modules/services/arr/sonarr.nix
# =============================================================================
# Sonarr — TV-Serien Downloader
# Nativport: 8989
#
# nixpkgs Basis: services/misc/servarr/sonarr.nix @ 957de226
# Änderungen gegenüber nixpkgs:
#   - Namespace my.media.sonarr statt services.sonarr
#   - stateDir aus my.defaults.paths.statePrefix
#   - group aus my.defaults.security.defaultGroup
#   - netns + SSO via myLib.mkService (caddy virtualHost)
#   - Hardening aus _servarr-factory (einheitlich, auch ReadWritePaths für media)
#   - environmentFiles → sops-nix kompatibel
#   - openFirewall immer false (Caddy übernimmt)
# =============================================================================
{ config, lib, pkgs, utils, ... }:

let
  factory = import ./_servarr-factory.nix { inherit lib pkgs; };
  myLib   = import ../../00-core/lib/helpers.nix { inherit lib; };

  cfg     = config.my.media.sonarr;
  defs    = config.my.defaults;

  nativeName = "sonarr";
  nativePort = 8989;

  stateDir = "${defs.paths.statePrefix}/${nativeName}/.config/NzbDrone";

  serviceBase = myLib.mkService {
    inherit config;
    name        = nativeName;
    port        = cfg.settings.server.port;
    useSSO      = defs.security.ssoEnable;
    description = "Sonarr TV Series Downloader";
    netns       = cfg.netns;
  };
in
{
  options.my.media.sonarr = {
    enable = lib.mkEnableOption "Sonarr TV-Serien Downloader";

    stateDir = lib.mkOption {
      type    = lib.types.str;
      default = stateDir;
      description = "Persistenter Zustandspfad. Standard aus my.defaults.paths.statePrefix.";
    };

    user = lib.mkOption {
      type    = lib.types.str;
      default = nativeName;
    };

    group = lib.mkOption {
      type    = lib.types.str;
      default = defs.security.defaultGroup;   # ← 00-defaults ("media")
    };

    netns = lib.mkOption {
      type    = lib.types.nullOr lib.types.str;
      default = defs.netns;
    };

    expose.enable = lib.mkOption {
      type    = lib.types.bool;
      default = true;
    };

    # settings + environmentFiles: 1:1 aus nixpkgs factory
    settings         = factory.mkServarrSettingsOptions nativeName nativePort;
    environmentFiles = factory.mkServarrEnvironmentFiles nativeName;
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    serviceBase
    {
      # Systemd-Service — nixpkgs Implementierung + eigene Ergänzungen
      systemd.services.${nativeName} = {
        description = "Sonarr";
        after       = [ "network.target" ];
        wantedBy    = [ "multi-user.target" ];

        # Env-Vars: settings → SONARR__SERVER__PORT=8989 etc.
        environment = factory.mkServarrSettingsEnvVars
          (lib.toUpper nativeName) cfg.settings;

        serviceConfig = {
          Type            = "simple";
          User            = cfg.user;
          Group           = cfg.group;
          EnvironmentFile = cfg.environmentFiles;
          ExecStart       = utils.escapeSystemdExecArgs [
            (lib.getExe cfg.package or pkgs.sonarr)
            "-nobrowser"
            "-data=${cfg.stateDir}"
          ];
          Restart         = "on-failure";
                      ReadWritePaths  = [
                        cfg.stateDir
                        defs.paths.mediaRoot
                        defs.paths.downloadsDir
                      ];
                                  BindPaths = [
                                    "${defs.paths.fastPoolRoot}/metadata/${nativeName}:/var/lib/${nativeName}/MediaCover"
                                  ];
                                } // factory.mkServarrHardening // { RestrictNamespaces = lib.mkForce false; };   # ← vollständiges Hardening
                              };
                                        # Verzeichnisse anlegen
                  systemd.tmpfiles.settings = (factory.mkServarrTmpfiles nativeName cfg) // {
                    "10-${nativeName}-meta"."${defs.paths.fastPoolRoot}/metadata/${nativeName}".d = {
                      inherit (cfg) user group;
                      mode = "0750";
                    };
                  };
          
                  # Firewall: immer geschlossen — Caddy übernimmt
                  networking.firewall.allowedTCPPorts = lib.mkForce [];
                # User/Group
      users.users.${cfg.user} = lib.mkIf (cfg.user == nativeName) {
        group        = cfg.group;
        home         = cfg.stateDir;
        uid          = config.ids.uids.sonarr;
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
