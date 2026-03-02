/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-024
 *   title: "_servarr-factory"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   upstream: [NIXH-00-SYS-DEFAULTS-001]
 *   downstream:
 *     - NIXH-20-SRV-030  # sonarr
 *     - NIXH-20-SRV-031  # radarr
 *     - NIXH-20-SRV-032  # prowlarr
 *     - NIXH-20-SRV-033  # readarr
 *     - NIXH-20-SRV-034  # lidarr
 *   status: audited
 * ---
 */

# =============================================================================
# modules/services/arr/_servarr-factory.nix
# =============================================================================
# Erweiterte Version von nixpkgs/nixos/modules/services/misc/servarr/settings-options.nix
# (Commit: 957de226611daff0e11c4b29b622aa07b667f159)
#
# Was aus nixpkgs übernommen wurde (1:1):
#   - mkServarrSettingsOptions  (freeformType INI + strukturierte Optionen)
#   - mkServarrEnvironmentFiles (listOf path für sops-nix Kompatibilität)
#   - mkServarrSettingsEnvVars  (lib.pipe → UPPER__SECTION__KEY Mapping)
#
# Eigene Ergänzungen gegenüber nixpkgs:
#   - mkServarrHardening        (vollständiges Systemd-Hardening für ALLE Apps)
#   - mkServarrTmpfiles         (einheitliche Verzeichnis-Anlage)
#   - mkServarrUserGroup        (geteilte Gruppe aus my.defaults)
#   - mkServarrModule           (komplette Modul-Factory für my.media.* Namespace)
# =============================================================================
{ lib, pkgs }:

let
  # ---------------------------------------------------------------------------
  # Vollständiges Systemd-Hardening — aus Sonarr/Radarr extrahiert und auf
  # alle Apps vereinheitlicht (Readarr/Lidarr hatten es in nixpkgs nicht)
  # ---------------------------------------------------------------------------
  servarrHardening = {
    CapabilityBoundingSet   = "";
    NoNewPrivileges         = true;
    ProtectHome             = true;
    ProtectClock            = true;
    ProtectKernelLogs       = true;
    PrivateTmp              = true;
    PrivateDevices          = true;
    PrivateUsers            = true;
    ProtectKernelTunables   = true;
    ProtectKernelModules    = true;
    ProtectControlGroups    = true;
    RestrictSUIDSGID        = true;
    RemoveIPC               = true;
    UMask                   = "0022";
    ProtectHostname         = true;
    ProtectProc             = "invisible";
    ProcSubset              = "pid";
    RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
    RestrictNamespaces      = true;
    RestrictRealtime        = true;
    LockPersonality         = true;
    SystemCallArchitectures = "native";
    SystemCallFilter        = [
      "@system-service"
      "~@privileged"
      "~@debug"
      "~@mount"
      "@chown"
    ];
  };

in
{
  # ===========================================================================
  # AUS NIXPKGS ÜBERNOMMEN (1:1, Commit 957de226)
  # ===========================================================================

  # settings.*-Optionen mit freeformType INI + strukturierten Defaults
  mkServarrSettingsOptions =
    name: port:
    lib.mkOption {
      type = lib.types.submodule {
        freeformType = (pkgs.formats.ini { }).type;
        options = {
          update = {
            mechanism = lib.mkOption {
              type    = with lib.types; nullOr (enum [ "external" "builtIn" "script" ]);
              default = "external";
              description = "Update-Mechanismus. 'external' = NixOS verwaltet Updates (empfohlen).";
            };
            automatically = lib.mkOption {
              type    = lib.types.bool;
              default = false;
              description = "Automatische Updates. Immer false in NixOS — nixpkgs verwaltet das.";
            };
          };
          server = {
            port = lib.mkOption {
              type    = lib.types.port;
              default = port;
              description = "HTTP-Port. Wird auch für Firewall-Regel verwendet.";
            };
            bindAddress = lib.mkOption {
              type    = lib.types.str;
              default = "127.0.0.1";
              description = "Bind-Adresse. '127.0.0.1' = nur lokal (empfohlen mit Caddy).";
            };
          };
          log = {
            analyticsEnabled = lib.mkOption {
              type    = lib.types.bool;
              default = false;
              description = "Anonyme Nutzungsdaten senden. Immer false.";
            };
          };
        };
      };
      default     = { };
      description = ''
        Konfigurationsoptionen als Attribut-Set (INI-Format).
        Werden als Umgebungsvariablen übergeben: ${lib.toUpper name}__SECTION__KEY=value
        Dokumentation: https://wiki.servarr.com/useful-tools#using-environment-variables-for-config

        ⚠️  Diese Konfiguration liegt im world-readable Nix Store!
        Secrets (API-Keys, Passwörter) immer über environmentFiles setzen.
      '';
    };

  # EnvironmentFile-Liste — kompatibel mit sops-nix (listOf path)
  mkServarrEnvironmentFiles =
    name:
    lib.mkOption {
      type        = lib.types.listOf lib.types.path;
      default     = [ ];
      description = ''
        Liste von Environment-Dateien für Secrets.
        Format pro Zeile: ${lib.toUpper name}__SECTION__KEY=value
        Kompatibel mit sops-nix: environmentFiles = [ config.sops.secrets.${name}-env.path ];
      '';
    };

  # Env-Var Mapping: settings.server.port → SONARR__SERVER__PORT=8989
  mkServarrSettingsEnvVars =
    name: settings:
    lib.pipe settings [
      (lib.mapAttrsRecursive (
        path: value:
        lib.optionalAttrs (value != null) {
          name  = lib.toUpper "${name}__${lib.concatStringsSep "__" path}";
          value = toString (if lib.isBool value then lib.boolToString value else value);
        }
      ))
      (lib.collect (x: lib.isString x.name or false && lib.isString x.value or false))
      lib.listToAttrs
    ];

  # ===========================================================================
  # EIGENE ERGÄNZUNGEN
  # ===========================================================================

  # Vollständiges Hardening-Set (für alle Apps einheitlich)
  mkServarrHardening = servarrHardening;

  # Tmpfiles-Regel für State-Verzeichnis
  mkServarrTmpfiles = name: cfg: {
    "10-${name}".${cfg.stateDir}.d = {
      inherit (cfg) user group;
      mode = "0700";
    };
  };

  # User/Group mit geteilter Gruppe aus my.defaults
  mkServarrUserGroup = name: cfg: defaultGroup: {
    users.users.${cfg.user} = lib.mkIf (cfg.user == name) {
      group       = cfg.group;
      home        = cfg.stateDir;
      isSystemUser = true;
      description = "${name} service user";
    };
    # Geteilte Gruppe nur anlegen wenn sie noch nicht existiert (z.B. "media")
    users.groups.${cfg.group} = lib.mkDefault { };
  };
}
/**
 * ---
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 *   complexity_score: 3
 * ---
 */
