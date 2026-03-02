/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-032
 *   title: "prowlarr"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   upstream: [NIXH-00-SYS-DEFAULTS-001, NIXH-20-SRV-024]
 *   downstream: []
 *   status: audited
 * ---
 */

# =============================================================================
# modules/services/arr/prowlarr.nix
# =============================================================================
# Prowlarr — Indexer-Manager für alle arr-Apps
# Nativport: 9696
#
# nixpkgs Basis: services/misc/servarr/prowlarr.nix @ 957de226
#
# Wichtige nixpkgs-Besonderheit bei Prowlarr:
#   DynamicUser = true  → kein expliziter users.users Eintrag nötig!
#   StateDirectory = "prowlarr" → systemd verwaltet /var/lib/private/prowlarr
#   Bei custom dataDir: bind-mount auf /var/lib/private/prowlarr
#
# Diese Besonderheit wird hier beibehalten — Prowlarr hat keinen festen
# UID/GID in nixpkgs (anders als sonarr/radarr/lidarr).
# =============================================================================
{ config, lib, pkgs, ... }:

let
  factory = import ./service-media-_servarr-factory.nix { inherit lib pkgs; };
  myLib   = import ../00-core/lib-helpers.nix { inherit lib; };

  cfg  = config.my.media.prowlarr;
  defs = config.my.defaults;

  nativeName     = "prowlarr";
  nativePort     = 9696;
  defaultDataDir = "/var/lib/prowlarr";

  # Prowlarr erwartet seinen State in /var/lib/prowlarr (DynamicUser)
  # Bei custom stateDir: bind-mount (aus nixpkgs übernommen)
  isCustomStateDir = cfg.stateDir != defaultDataDir;

  serviceBase = myLib.mkService {
    inherit config;
    name        = nativeName;
    port        = cfg.settings.server.port;
    useSSO      = defs.security.ssoEnable;
    description = "Prowlarr Indexer Manager";
    netns       = cfg.netns;
  };
in
{
  options.my.media.prowlarr = {
    enable = lib.mkEnableOption "Prowlarr Indexer-Manager";

    # Prowlarr: stateDir default = nixpkgs Standard (wegen DynamicUser)
    stateDir = lib.mkOption {
      type    = lib.types.str;
      default = defaultDataDir;
      description = ''
        Zustandspfad für Prowlarr.
        Standard: /var/lib/prowlarr (DynamicUser-kompatibel).
        Bei abweichendem Pfad wird ein bind-mount angelegt (nixpkgs-Verhalten).
      '';
    };

    netns = lib.mkOption {
      type    = lib.types.nullOr lib.types.str;
      default = defs.netns;
    };

    expose.enable = lib.mkOption {
      type    = lib.types.bool;
      default = true;
    };

    # Kein user/group: DynamicUser = true (systemd verwaltet das)
    settings         = factory.mkServarrSettingsOptions nativeName nativePort;
    environmentFiles = factory.mkServarrEnvironmentFiles nativeName;
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    serviceBase
    {
      systemd.services.${nativeName} = {
        description = "Prowlarr";
        after       = [ "network.target" ];
        wantedBy    = [ "multi-user.target" ];

        environment = factory.mkServarrSettingsEnvVars
          (lib.toUpper nativeName) cfg.settings
          // { HOME = "/var/empty"; };   # ← aus nixpkgs (DynamicUser braucht das)

        serviceConfig = {
          Type             = "simple";
          DynamicUser      = true;       # ← nixpkgs-Besonderheit für Prowlarr
          StateDirectory   = nativeName; # → /var/lib/private/prowlarr
          EnvironmentFile  = cfg.environmentFiles;
          ExecStart        = "${lib.getExe pkgs.prowlarr} -nobrowser -data=/var/lib/prowlarr";
          Restart          = "on-failure";
        } // factory.mkServarrHardening;
      };

      # Bind-Mount bei custom stateDir (1:1 aus nixpkgs übernommen)
      systemd.mounts = lib.optional isCustomStateDir {
        what    = cfg.stateDir;
        where   = "/var/lib/private/prowlarr";
        options = "bind";
        wantedBy = [ "local-fs.target" ];
      };

      systemd.tmpfiles.settings."10-prowlarr-custom" =
        lib.mkIf isCustomStateDir {
          ${cfg.stateDir}.d = {
            user  = "root";
            group = "root";
            mode  = "0700";
          };
        };

      networking.firewall.allowedTCPPorts = lib.mkForce [];

      # Kein users.users/groups: DynamicUser = true
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
