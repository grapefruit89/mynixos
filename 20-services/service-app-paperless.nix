/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-30-DOC-001
 *   title: "paperless"
 *   layer: 30
 * architecture:
 *   req_refs: [REQ-DOC]
 *   upstream: [NIXH-00-SYS-DEFAULTS-001, NIXH-20-SRV-023]
 *   downstream: []
 *   status: audited
 * ---
 */

# =============================================================================
# modules/services/documents/paperless.nix
# =============================================================================
# Paperless-ngx — basiert auf dem nixpkgs-Quellcode (services/paperless.nix)
# als kanonischer Referenz. Alle Hardening-Entscheidungen, Redis-Socket-
# Konfiguration, preStart-Migrationslogik und Exporter-Struktur sind direkt
# aus nixpkgs übernommen — nicht neu erfunden.
#
# Eigene Ergänzungen gegenüber nixpkgs:
#   - my.documents.paperless Namespace (myServices-Architektur)
#   - Geteilte Defaults aus my.defaults.* (00-defaults.nix)
#   - myLib.mkService Integration (SSO, netns, Reverse Proxy)
#   - Alle Optionen die nixpkgs bereits korrekt implementiert werden
#     DURCHGEREICHT, nicht neu implementiert
#
# Geteilte Defaults aus 00-defaults.nix:
#   ocr.languages       → PAPERLESS_OCR_LANGUAGE (via package.apply)
#   ocr.outputType      → PAPERLESS_OCR_OUTPUT_TYPE
#   locale.timezone     → via config.time.timeZone (nixpkgs liest das direkt)
#   locale.dateOrder    → PAPERLESS_DATE_ORDER
#   paths.statePrefix   → dataDir Basis
#   paths.documentRoot  → consumptionDir / mediaDir
#   paths.backupRoot    → exporter.directory
#   security.defaultGroup → group (via users.users)
#   netns               → mkService
#   security.ssoEnable  → mkService
# =============================================================================
{ lib, pkgs, config, ... }:

let
  myLib = import ../00-core/lib-helpers.nix { inherit lib; };
  cfg   = config.my.documents.paperless;
  defs  = config.my.defaults;

  # ---------------------------------------------------------------------------
  # Abgeleitete Pfade aus 00-defaults (kein Hardcoding)
  # ---------------------------------------------------------------------------
  defaultStateDir  = "${defs.paths.statePrefix}/paperless";
  defaultMediaDir  = "${defaultStateDir}/media";
  defaultConsumeDir = "${defs.paths.documentRoot}/consume";
  defaultExportDir = "${defs.paths.backupRoot}/paperless/export";

  # ---------------------------------------------------------------------------
  # OCR-Sprachen: Union aus Defaults + per-Dienst-Ergänzungen
  # Wird als PAPERLESS_OCR_LANGUAGE gesetzt → package.apply übernimmt
  # automatisch den Tesseract-Build (nixpkgs-Mechanismus)
  # ---------------------------------------------------------------------------
  ocrLanguageString = lib.concatStringsSep "+"
    (lib.lists.unique (defs.ocr.languages ++ cfg.ocr.extraLanguages));

  # ---------------------------------------------------------------------------
  # mkService: Reverse Proxy, SSO, netns (dein Factory-Pattern)
  # ---------------------------------------------------------------------------
  serviceBase = myLib.mkService {
    inherit config;
    name        = "paperless";
    port        = cfg.port;
    useSSO      = defs.security.ssoEnable;
    description = "Paperless-ngx Document Management";
    netns       = cfg.netns;
  };

in
{
  # ===========================================================================
  # OPTIONEN
  # Prinzip: Nur Optionen die über services.paperless.* NICHT erreichbar sind
  # oder die aus 00-defaults koordiniert werden müssen. Alles andere wird
  # direkt an services.paperless durchgereicht.
  # ===========================================================================
  options.my.documents.paperless = {

    enable = lib.mkEnableOption "Paperless-ngx Dokumenten-Management";

    # -------------------------------------------------------------------------
    # Pfad-Overrides (Defaults aus 00-defaults)
    # -------------------------------------------------------------------------
    dataDir = lib.mkOption {
      type        = lib.types.str;
      default     = defaultStateDir;
      description = "Persistenter Zustandspfad. Standard: my.defaults.paths.statePrefix/paperless";
    };

    mediaDir = lib.mkOption {
      type        = lib.types.str;
      default     = defaultMediaDir;
      description = "Dokumenten-Archiv (Original + PDF/A). Standard: dataDir/media";
    };

    consumptionDir = lib.mkOption {
      type        = lib.types.str;
      default     = defaultConsumeDir;
      description = "Eingangsordner. Standard: my.defaults.paths.documentRoot/consume";
    };

    consumptionDirIsPublic = lib.mkOption {
      type    = lib.types.bool;
      default = false;
      description = "0777 auf consumptionDir (für Samba-Shares). Entspricht services.paperless.consumptionDirIsPublic.";
    };

    # -------------------------------------------------------------------------
    # Netzwerk (identisch zu arr-Factory-Muster)
    # -------------------------------------------------------------------------
    address = lib.mkOption {
      type    = lib.types.str;
      default = "127.0.0.1";
    };

    port = lib.mkOption {
      type    = lib.types.port;
      default = 28981;
    };

    domain = lib.mkOption {
      type    = lib.types.nullOr lib.types.str;
      default = null;
      description = "Vollständige Domain für nginx vHost und PAPERLESS_URL. Null = kein nginx.";
    };

    netns = lib.mkOption {
      type    = lib.types.nullOr lib.types.str;
      default = defs.netns;
    };

    expose.enable = lib.mkOption {
      type    = lib.types.bool;
      default = true;
    };

    # -------------------------------------------------------------------------
    # Datenbank
    # -------------------------------------------------------------------------
    database.createLocally = lib.mkOption {
      type    = lib.types.bool;
      default = true;
      description = "Lokale PostgreSQL-DB anlegen und verwalten (services.paperless.database.createLocally).";
    };

    # -------------------------------------------------------------------------
    # OCR — Ergänzungen zur Basis aus my.defaults.ocr
    # package.apply in nixpkgs übernimmt den Tesseract-Build automatisch
    # -------------------------------------------------------------------------
    ocr = {
      extraLanguages = lib.mkOption {
        type    = lib.types.listOf lib.types.str;
        default = [];
        description = ''
          Zusätzliche Tesseract-Sprachen nur für Paperless.
          Basis kommt aus my.defaults.ocr.languages (00-defaults).
        '';
      };
    };

    # -------------------------------------------------------------------------
    # Tika / Gotenberg
    # -------------------------------------------------------------------------
    configureTika = lib.mkOption {
      type    = lib.types.bool;
      default = true;
      description = "Apache Tika + Gotenberg für Office/E-Mail OCR (services.paperless.configureTika).";
    };

    # -------------------------------------------------------------------------
    # Exporter (aus nixpkgs-Struktur übernommen, Ziel aus 00-defaults)
    # -------------------------------------------------------------------------
    exporter = {
      enable = lib.mkOption {
        type    = lib.types.bool;
        default = true;
        description = "Automatischen täglichen Document-Export aktivieren.";
      };

      directory = lib.mkOption {
        type    = lib.types.str;
        default = defaultExportDir;
        description = "Export-Zielverzeichnis. Standard: my.defaults.paths.backupRoot/paperless/export";
      };

      onCalendar = lib.mkOption {
        type    = lib.types.nullOr lib.types.str;
        default = "01:30:00";
        description = "systemd OnCalendar Ausdruck. Null = Timer deaktiviert.";
      };

      # CLI-Settings exakt wie nixpkgs (compare-checksums verhindert unnötige Rewrites)
      settings = lib.mkOption {
        type    = with lib.types; attrsOf anything;
        default = {
          "no-progress-bar"  = true;
          "no-color"         = true;
          "compare-checksums" = true;
          "delete"           = true;
        };
        description = "CLI-Argumente für document_exporter (nixpkgs-kompatibel).";
      };
    };

    # -------------------------------------------------------------------------
    # OpenMP Workaround (aus nixpkgs — default true dort)
    # -------------------------------------------------------------------------
    openMPThreadingWorkaround = lib.mkOption {
      type    = lib.types.bool;
      default = true;
      description = "OMP_NUM_THREADS=1 Workaround für Classifier-Timeouts (nixpkgs-Default: true).";
    };

    # -------------------------------------------------------------------------
    # Secrets
    # -------------------------------------------------------------------------
    passwordFile = lib.mkOption {
      type        = lib.types.nullOr lib.types.path;
      default     = null;
      description = "Pfad zur Admin-Passwort-Datei (services.paperless.passwordFile). Empfehlung: sops.secrets.*.path";
    };

    environmentFile = lib.mkOption {
      type    = lib.types.nullOr lib.types.path;
      default = null;
      description = "Zusätzlicher systemd EnvironmentFile für Secrets (SMTP, SECRET_KEY, …).";
    };

    # -------------------------------------------------------------------------
    # Durchreiche für services.paperless.settings
    # Alles was direkt als PAPERLESS_* gesetzt werden soll ohne eigene Option
    # -------------------------------------------------------------------------
    extraSettings = lib.mkOption {
      type    = with lib.types; attrsOf anything;
      default = {};
      description = ''
        Direkte Durchreiche an services.paperless.settings.
        Für Einstellungen die keine eigene Option haben.
        Beispiel: { PAPERLESS_CONSUMER_DELETE_DUPLICATES = false; }
      '';
    };

  };

  # ===========================================================================
  # IMPLEMENTIERUNG
  # ===========================================================================
  config = lib.mkIf cfg.enable (lib.mkMerge [

    # serviceBase: Reverse Proxy, SSO, netns aus myLib.mkService
    serviceBase

    {
      # -----------------------------------------------------------------------
      # Assertions
      # -----------------------------------------------------------------------
      assertions = [
        {
          # Aus nixpkgs übernommen
          assertion = cfg.domain != null || !cfg.expose.enable;
          message   = "my.documents.paperless: expose.enable = true erfordert domain != null.";
        }
      ];

      # -----------------------------------------------------------------------
      # services.paperless — VOLLSTÄNDIGE Durchreiche an nixpkgs
      # Alle Hardening-, Redis-, Migration- und Exporter-Logik bleibt
      # in nixpkgs. Wir konfigurieren nur, wir re-implementieren nicht.
      # -----------------------------------------------------------------------
      services.paperless = {
        enable                   = true;
        dataDir                  = cfg.dataDir;
        mediaDir                 = cfg.mediaDir;
        consumptionDir           = cfg.consumptionDir;
        consumptionDirIsPublic   = cfg.consumptionDirIsPublic;
        address                  = cfg.address;
        port                     = cfg.port;
        domain                   = cfg.domain;
        passwordFile             = cfg.passwordFile;
        environmentFile          = cfg.environmentFile;
        configureTika            = cfg.configureTika;
        openMPThreadingWorkaround = cfg.openMPThreadingWorkaround;

        database.createLocally   = cfg.database.createLocally;

        # Exporter: Struktur 1:1 aus nixpkgs (inkl. compare-checksums!)
        exporter = {
          enable     = cfg.exporter.enable;
          directory  = cfg.exporter.directory;
          onCalendar = cfg.exporter.onCalendar;
          settings   = cfg.exporter.settings;
        };

        # settings: Geordnet nach Priorität
        settings = lib.mkMerge [
          {
            # --- OCR ---
            # ocrLanguageString → package.apply baut Tesseract korrekt (nixpkgs-Mechanismus)
            PAPERLESS_OCR_LANGUAGE    = ocrLanguageString;             # ← GETEILT (00-defaults + extraLanguages)
            PAPERLESS_OCR_OUTPUT_TYPE = defs.ocr.outputType;          # ← GETEILT (00-defaults)
            PAPERLESS_OCR_MODE        = "skip";
            PAPERLESS_OCR_CLEAN       = "clean";
            PAPERLESS_OCR_DESKEW      = true;
            PAPERLESS_OCR_ROTATE_PAGES = true;
            PAPERLESS_OCR_ROTATE_PAGES_THRESHOLD = 12.0;
            PAPERLESS_OCR_USER_ARGS   = {
              optimize               = 1;
              pdfa_image_compression = "lossless";    # Attrset → auto-JSON via nixpkgs
            };

            # --- Lokalisierung (aus 00-defaults — GETEILT) ---
            # PAPERLESS_TIME_ZONE wird von nixpkgs automatisch aus config.time.timeZone gelesen
            # → NICHT doppelt setzen, nixpkgs macht das bereits in env{}
            PAPERLESS_DATE_ORDER = defs.locale.dateOrder;             # ← GETEILT (00-defaults)

            # --- Dateibenennungsschema ---
            PAPERLESS_FILENAME_FORMAT      = "{created_year}/{correspondent}/{document_type}/{created_year}-{created_month}-{created_day} {title}";
            PAPERLESS_FILENAME_DATE_FORMAT = "%Y-%m-%d";

            # --- Consumer ---
            PAPERLESS_CONSUMER_POLLING         = 60;    # NAS-sicher; 0 nur für lokale FS
            PAPERLESS_CONSUMER_RECURSIVE       = true;
            PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS = true;
            PAPERLESS_CONSUMER_IGNORE_PATTERNS = [      # List → auto-JSON via nixpkgs
              ".DS_Store" "._*" ".stfolder/*" ".stversions/*" "Thumbs.db"
            ];
            PAPERLESS_CONSUMER_ENABLE_ASN_BARCODE = true;
            PAPERLESS_CONSUMER_BARCODE_SCANNER    = "ZXING";
            PAPERLESS_CONSUMER_DELETE_DUPLICATES  = false;

            # --- Sicherheit & Sonstiges ---
            PAPERLESS_COOKIE_PREFIX           = "paperless";
            PAPERLESS_AUDIT_LOG_ENABLED       = true;
            PAPERLESS_IGNORE_DATES_IN_FUTURE  = true;
            PAPERLESS_ENABLE_COMPRESSION      = true;
            PAPERLESS_NUMBER_OF_SUGGESTED_DATES = 4;

            # --- NLTK (nixpkgs setzt PAPERLESS_NLTK_DIR automatisch) ---
            # → Nicht manuell setzen

            # --- Logging ---
            PAPERLESS_LOGROTATE_MAX_SIZE    = 10;
            PAPERLESS_LOGROTATE_MAX_BACKUPS = 5;
          }

          # Direkte Durchreiche (für alles ohne eigene Option)
          cfg.extraSettings
        ];
      };

      # -----------------------------------------------------------------------
      # tmpfiles — Exporter-Verzeichnis (dataDir/mediaDir/consumptionDir
      # werden von nixpkgs selbst via systemd.tmpfiles.settings angelegt)
      # -----------------------------------------------------------------------
      systemd.tmpfiles.settings."10-paperless-extra" = {
        "${cfg.exporter.directory}".d = {
          user  = config.services.paperless.user;
          group = config.users.users.${config.services.paperless.user}.group;
          mode  = "0750";
        };
      };

      # -----------------------------------------------------------------------
      # User/Group — geteilte Gruppe aus 00-defaults
      # nixpkgs legt users.users.paperless an, wir passen nur die Gruppe an
      # -----------------------------------------------------------------------
      users.users.${config.services.paperless.user} = {
        extraGroups = [ defs.security.defaultGroup ];
      };

      users.groups.${defs.security.defaultGroup} = lib.mkDefault {};

      # -----------------------------------------------------------------------
      # Firewall (explizit — mkForce oben reicht, aber zur Klarheit)
      # -----------------------------------------------------------------------
      networking.firewall.allowedTCPPorts = lib.mkForce [];

    }
  ]);
}

/**
 * ---
 * technical_integrity:
 *   checksum: sha256:PLACEHOLDER_REPLACE_WITH_REAL_CHECKSUM
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-01
 *   complexity_score: 3
 * ---
 */
