/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-SYS-DEFAULTS-001
 *   title: "00-defaults"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-SRV]
 *   upstream: []
 *   downstream: [NIXH-20-SRV-023, NIXH-30-DOC-001]
 *   status: audited
 * ---
 */

# =============================================================================
# modules/00-defaults.nix
# =============================================================================
# Geteilte Optionen die über mehrere App-Namespaces hinweg konsistent sein
# müssen. Jedes Modul das auf diese Defaults zurückgreift referenziert
# config.my.defaults.<option> — niemals hartkodierte Werte in Leaf-Modulen.
#
# Abgedeckte Querschnittsthemen:
#   - Netzwerk      (netns, bindAddress)
#   - Lokalisierung (locale, timezone, ocr.languages)
#   - Dateisystem   (stateDir-Prefix, mediaRoot, cacheRoot, metadataRoot)
#   - Sicherheit    (defaultUser/Group-Konventionen)
#   - Observability (metrics-Port-Offset, logLevel)
# =============================================================================
{ lib, ... }:

{
  options.my.defaults = {

    # -------------------------------------------------------------------------
    # Netzwerk
    # -------------------------------------------------------------------------
    netns = lib.mkOption {
      type    = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Standard Network-Namespace für alle Dienste.
        Null = kein separater netns (Default-Netzwerk-Stack).
        Wird in jedem Dienst-Modul via cfg.netns referenziert und kann
        dort per-Dienst überschrieben werden.
      '';
    };

    bindAddress = lib.mkOption {
      type    = lib.types.str;
      default = "127.0.0.1";
      description = ''
        Standard-Bind-Adresse für alle Dienste.
        Dienste mit netns überschreiben dies typischerweise auf die
        netns-interne Loopback-Adresse.
      '';
    };

    # -------------------------------------------------------------------------
    # Lokalisierung — einmal definiert, überall konsistent
    # -------------------------------------------------------------------------
    locale = {
      timezone = lib.mkOption {
        type    = lib.types.str;
        default = "Europe/Berlin";
        description = "Systemzeitzone. Wird von Paperless, Home Assistant etc. übernommen.";
      };

      language = lib.mkOption {
        type    = lib.types.str;
        default = "de_DE.UTF-8";
        description = "Primäre Systemsprache (LANG).";
      };

      dateOrder = lib.mkOption {
        type    = lib.types.enum [ "DMY" "MDY" "YMD" ];
        default = "DMY";
        description = "Datumsinterpretationsreihenfolge (relevant für Paperless, Sonarr-Umbenennung etc.).";
      };
    };

    # -------------------------------------------------------------------------
    # OCR — geteilte Sprachkonfiguration
    # Paperless, Stirling-PDF und zukünftige Dienste ziehen hieraus
    # -------------------------------------------------------------------------
    ocr = {
      languages = lib.mkOption {
        type    = lib.types.listOf lib.types.str;
        default = [ "deu" "eng" ];
        description = ''
          Tesseract-Sprachpakete die systemweit für OCR-Dienste verfügbar
          sein sollen. Einzelne Dienste können ergänzen, aber nicht entfernen.
          Format: ISO 639-2/T Codes (deu, eng, fra, …)
        '';
      };

      outputType = lib.mkOption {
        type    = lib.types.enum [ "pdfa" "pdfa-1" "pdfa-2" "pdfa-3" "pdf" "none" ];
        default = "pdfa";
        description = "Standard OCR-Ausgabeformat für alle Dokument-Dienste.";
      };
    };

    # -------------------------------------------------------------------------
    # Dateisystem-Präfixe — ein zentraler Ort für alle Mount-Punkte
    # -------------------------------------------------------------------------
    paths = {
      statePrefix = lib.mkOption {
        type    = lib.types.str;
        default = "/data/state";
        description = ''
          Wurzelpfad für persistente Service-Zustände (Datenbanken, Konfigs).
          Dienste hängen ihren Namen an: statePrefix + "/" + name
        '';
      };

      mediaRoot = lib.mkOption {
        type    = lib.types.str;
        default = "/mnt/media";
        description = "Wurzelpfad der Medienbibliothek (Filme, Serien, Musik).";
      };

      downloadsDir = lib.mkOption {
        type    = lib.types.str;
        default = "/mnt/media/downloads";
        description = "Download-Staging-Verzeichnis (sabnzbd/qbittorrent Output).";
      };

      fastPoolRoot = lib.mkOption {
        type    = lib.types.str;
        default = "/mnt/fast-pool";
        description = "Schneller Pool (SSD/NVMe) für Cache und Metadaten.";
      };

      documentRoot = lib.mkOption {
        type    = lib.types.str;
        default = "/mnt/documents";
        description = "Wurzelpfad für Dokument-Dienste (Paperless consume, media, export).";
      };

      backupRoot = lib.mkOption {
        type    = lib.types.str;
        default = "/mnt/backup";
        description = "Backup-Zielwurzel für alle Dienste.";
      };
    };

    # -------------------------------------------------------------------------
    # Sicherheit & User-Konventionen
    # -------------------------------------------------------------------------
    security = {
      defaultGroup = lib.mkOption {
        type    = lib.types.str;
        default = "media";
        description = ''
          Geteilte Gruppe für alle Medien- und Dokument-Dienste.
          Stellt sicher dass arr-Stack, Paperless etc. auf gemeinsame
          Verzeichnisse zugreifen können ohne sudo/ACLs.
        '';
      };

      ssoEnable = lib.mkOption {
        type    = lib.types.bool;
        default = true;
        description = "SSO standardmäßig für alle Dienste aktivieren (via mkService).";
      };
    };

    # -------------------------------------------------------------------------
    # Observability
    # -------------------------------------------------------------------------
    observability = {
      logLevel = lib.mkOption {
        type    = lib.types.enum [ "DEBUG" "INFO" "WARNING" "ERROR" ];
        default = "WARNING";
        description = "Standard-Log-Level für alle Dienste.";
      };

      metricsPortOffset = lib.mkOption {
        type    = lib.types.int;
        default = 9000;
        description = ''
          Basis-Port für Prometheus-Exporter.
          Konvention: metricsPortOffset + nativePort-letzteStelle
          Verhindert Port-Kollisionen ohne manuelle Verwaltung.
        '';
      };
    };

  };
}
