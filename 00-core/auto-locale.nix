# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: Auto-Locale – Intelligente Länder-Erkennung via Geolocation
#   priority: P4 (Nice-to-Have)
#   benefit: Reduziert manuelle Konfiguration auf 1 Zeile

{ config, lib, pkgs, ... }:

let
  cfg = config.my.autoLocale;
  
  # Locale-Profile (erweitert aus locale.nix)
  profiles = {
    DE = {
      name = "Deutschland";
      timeZone = "Europe/Berlin";
      locale = "de_DE.UTF-8";
      keyMap = "de-latin1";
      xkbLayout = "de";
      ntp = [ "0.de.pool.ntp.org" "1.de.pool.ntp.org" "2.de.pool.ntp.org" ];
    };
    AT = {
      name = "Österreich";
      timeZone = "Europe/Vienna";
      locale = "de_AT.UTF-8";
      keyMap = "de-latin1";
      xkbLayout = "de";
      ntp = [ "0.at.pool.ntp.org" "1.at.pool.ntp.org" ];
    };
    CH = {
      name = "Schweiz";
      timeZone = "Europe/Zurich";
      locale = "de_CH.UTF-8";
      keyMap = "de-latin1";
      xkbLayout = "de";
      ntp = [ "0.ch.pool.ntp.org" "1.ch.pool.ntp.org" ];
    };
    US = {
      name = "United States";
      timeZone = "America/New_York";
      locale = "en_US.UTF-8";
      keyMap = "us";
      xkbLayout = "us";
      ntp = [ "0.us.pool.ntp.org" "1.us.pool.ntp.org" ];
    };
    GB = {
      name = "United Kingdom";
      timeZone = "Europe/London";
      locale = "en_GB.UTF-8";
      keyMap = "uk";
      xkbLayout = "uk";
      ntp = [ "0.uk.pool.ntp.org" "1.uk.pool.ntp.org" ];
    };
    FR = {
      name = "France";
      timeZone = "Europe/Paris";
      locale = "fr_FR.UTF-8";
      keyMap = "fr";
      xkbLayout = "fr";
      ntp = [ "0.fr.pool.ntp.org" "1.fr.pool.ntp.org" ];
    };
    ES = {
      name = "España";
      timeZone = "Europe/Madrid";
      locale = "es_ES.UTF-8";
      keyMap = "es";
      xkbLayout = "es";
      ntp = [ "0.es.pool.ntp.org" "1.es.pool.ntp.org" ];
    };
    IT = {
      name = "Italia";
      timeZone = "Europe/Rome";
      locale = "it_IT.UTF-8";
      keyMap = "it";
      xkbLayout = "it";
      ntp = [ "0.it.pool.ntp.org" "1.it.pool.ntp.org" ];
    };
    NL = {
      name = "Nederland";
      timeZone = "Europe/Amsterdam";
      locale = "nl_NL.UTF-8";
      keyMap = "us-intl";  # NL nutzt oft US-International
      xkbLayout = "us";
      ntp = [ "0.nl.pool.ntp.org" "1.nl.pool.ntp.org" ];
    };
    PL = {
      name = "Polska";
      timeZone = "Europe/Warsaw";
      locale = "pl_PL.UTF-8";
      keyMap = "pl";
      xkbLayout = "pl";
      ntp = [ "0.pl.pool.ntp.org" "1.pl.pool.ntp.org" ];
    };
  };
  
  # Geolocation via IP-API (fallback: ipapi.co)
  geolocateScript = pkgs.writeShellScript "geolocate" ''
    set -euo pipefail
    
    # Versuch 1: ip-api.com (kein API-Key nötig)
    COUNTRY=$(${pkgs.curl}/bin/curl -sf --max-time 5 \
      "http://ip-api.com/json/?fields=countryCode" \
      | ${pkgs.jq}/bin/jq -r '.countryCode' 2>/dev/null || echo "")
    
    if [ -n "$COUNTRY" ]; then
      echo "$COUNTRY"
      exit 0
    fi
    
    # Versuch 2: ipapi.co (Fallback)
    COUNTRY=$(${pkgs.curl}/bin/curl -sf --max-time 5 \
      "https://ipapi.co/country/" 2>/dev/null || echo "")
    
    if [ -n "$COUNTRY" ]; then
      echo "$COUNTRY"
      exit 0
    fi
    
    # Fallback: Default zu DE
    echo "DE"
  '';
  
  # Interaktive Auswahl (für manuelle Override)
  selectCountryScript = pkgs.writeShellScriptBin "select-country" ''
    #!/usr/bin/env bash
    set -euo pipefail
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🌍 Auto-Locale: Land auswählen"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Verfügbare Länder:"
    echo ""
    ${lib.concatMapStringsSep "\n" (code: 
      let profile = profiles.${code}; in
      ''  echo "  [${code}] ${profile.name}"''
    ) (lib.attrNames profiles)}
    echo ""
    
    # Automatische Erkennung
    AUTO=$(${geolocateScript})
    echo "🔍 Automatisch erkannt: $AUTO (${profiles.${cfg.country}.name or "Unbekannt"})"
    echo ""
    
    read -p "Land auswählen [Enter für $AUTO]: " CHOICE
    CHOICE=''${CHOICE:-$AUTO}
    CHOICE=$(echo "$CHOICE" | tr '[:lower:]' '[:upper:]')
    
    # Validierung
    case "$CHOICE" in
      ${lib.concatMapStringsSep "|" (code: code) (lib.attrNames profiles)})
        echo ""
        echo "✅ Ausgewählt: $CHOICE (${profiles.''${CHOICE}.name})"
        echo ""
        echo "Trage in /etc/nixos/00-core/configs.nix ein:"
        echo ""
        echo "  my.autoLocale.country = \"$CHOICE\";"
        echo ""
        ;;
      *)
        echo "❌ Ungültige Auswahl: $CHOICE"
        echo "Verwende Default: $AUTO"
        CHOICE=$AUTO
        ;;
    esac
  '';
  
  # Cache-Datei für erkanntes Land
  cacheFile = "/var/lib/auto-locale/country";
  
  # Land ermitteln (Priorität: Config > Cache > Geolocation)
  selectedCountry =
    if cfg.country != ""
    then cfg.country
    else if builtins.pathExists cacheFile
    then lib.removeSuffix "\n" (builtins.readFile cacheFile)
    else "DE";  # Fallback
  
  # Ausgewähltes Profil
  profile = profiles.${selectedCountry} or profiles.DE;
in
{
  # ══════════════════════════════════════════════════════════════════════════
  # OPTIONEN
  # ══════════════════════════════════════════════════════════════════════════
  
  options.my.autoLocale = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Aktiviert automatische Locale-Erkennung via Geolocation.
        
        WICHTIG: Nur beim ersten Boot sinnvoll!
        Danach besser manuell in configs.nix setzen:
          my.locale.profile = "DE";
      '';
    };
    
    country = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "DE";
      description = ''
        Länder-Code (ISO 3166-1 alpha-2).
        Leer = Automatische Erkennung via IP.
        
        Verfügbare Codes: ${lib.concatStringsSep ", " (lib.attrNames profiles)}
      '';
    };
    
    forceGeolocation = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Erzwingt Geolocation bei jedem Boot (nicht empfohlen).
        Standard: Nur einmalig, dann gecacht.
      '';
    };
  };
  
  # ══════════════════════════════════════════════════════════════════════════
  # KONFIGURATION
  # ══════════════════════════════════════════════════════════════════════════
  
  config = lib.mkIf cfg.enable {
    
    # System-Locale (überschreibbar via my.locale.profile)
    time.timeZone = lib.mkDefault profile.timeZone;
    i18n.defaultLocale = lib.mkDefault profile.locale;
    i18n.supportedLocales = lib.mkForce [
      "de_DE.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "en_GB.UTF-8/UTF-8"
      "fr_FR.UTF-8/UTF-8"
    ];
    
    console.keyMap = lib.mkDefault profile.keyMap;
    
    services.xserver.xkb = {
      layout = lib.mkDefault profile.xkbLayout;
      variant = "";
    };
    
    networking.timeServers = lib.mkDefault profile.ntp;
    
    # ══════════════════════════════════════════════════════════════════════════
    # GEOLOCATION SERVICE (einmalig beim ersten Boot)
    # ══════════════════════════════════════════════════════════════════════════
    
    systemd.services.auto-locale-detect = {
      description = "Auto-Locale: Detect Country via Geolocation";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      
      # Nur ausführen wenn:
      # 1. Cache-Datei fehlt ODER
      # 2. forceGeolocation = true
      unitConfig = lib.mkIf (!cfg.forceGeolocation) {
        ConditionPathExists = "!${cacheFile}";
      };
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      
      script = ''
        set -euo pipefail
        
        echo "🌍 Auto-Locale: Starte Geolocation..."
        
        # Erstelle Cache-Verzeichnis
        ${pkgs.coreutils}/bin/mkdir -p "$(dirname ${cacheFile})"
        
        # Geolocation durchführen
        COUNTRY=$(${geolocateScript} || echo "DE")
        
        # In Cache schreiben
        echo "$COUNTRY" > ${cacheFile}
        
        echo "✅ Land erkannt: $COUNTRY (${profiles.''${COUNTRY}.name or "Unbekannt"})"
        
        # Log-Meldung
        ${pkgs.util-linux}/bin/logger -t auto-locale "Detected country: $COUNTRY"
        
        # Info-Banner
        cat <<EOF
        
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        🌍 AUTO-LOCALE AKTIVIERT
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        
        Erkanntes Land: $COUNTRY (${profiles.''${COUNTRY}.name or "Unbekannt"})
        Zeitzone:       ${profile.timeZone}
        Sprache:        ${profile.locale}
        Tastatur:       ${profile.keyMap}
        
        WICHTIG: Wenn falsch erkannt, ändere in configs.nix:
          my.autoLocale.country = "XX";
        
        Oder interaktiv auswählen:
          sudo select-country
        
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        EOF
      '';
    };
    
    # ══════════════════════════════════════════════════════════════════════════
    # HELPER-TOOLS
    # ══════════════════════════════════════════════════════════════════════════
    
    environment.systemPackages = [
      selectCountryScript
      
      # Info-Tool
      (pkgs.writeShellScriptBin "show-locale" ''
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "🌍 Aktuelle Locale-Einstellungen"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Land:       ${selectedCountry} (${profile.name})"
        echo "Zeitzone:   ${profile.timeZone}"
        echo "Sprache:    ${profile.locale}"
        echo "Tastatur:   ${profile.keyMap}"
        echo "NTP-Server: ${lib.concatStringsSep ", " profile.ntp}"
        echo ""
        echo "Cache:      ${cacheFile}"
        if [ -f ${cacheFile} ]; then
          echo "Inhalt:     $(cat ${cacheFile})"
        else
          echo "Inhalt:     (nicht vorhanden)"
        fi
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      '')
    ];
    
    # Aliase
    programs.bash.shellAliases = {
      "locale-info" = "show-locale";
      "locale-select" = "sudo select-country";
    };
    
    # ══════════════════════════════════════════════════════════════════════════
    # ASSERTIONS
    # ══════════════════════════════════════════════════════════════════════════
    
    assertions = [
      {
        assertion = cfg.country == "" || (profiles ? ${cfg.country});
        message = ''
          auto-locale: Ungültiger Länder-Code: ${cfg.country}
          Verfügbar: ${lib.concatStringsSep ", " (lib.attrNames profiles)}
        '';
      }
    ];
  };
}

# ══════════════════════════════════════════════════════════════════════════
# USAGE GUIDE
# ══════════════════════════════════════════════════════════════════════════
#
# OPTION 1: Automatische Erkennung (empfohlen für Erstinstallation)
#
#   # In configuration.nix:
#   my.autoLocale.enable = true;
#   
#   # Nach nixos-rebuild:
#   $ show-locale
#   Land: DE (Deutschland)
#
# OPTION 2: Manuell auswählen
#
#   my.autoLocale = {
#     enable = true;
#     country = "CH";  # Schweiz
#   };
#
# OPTION 3: Interaktive Auswahl (während Installation)
#
#   $ sudo select-country
#   🌍 Auto-Locale: Land auswählen
#   [DE] Deutschland
#   [AT] Österreich
#   ...
#   Land auswählen [Enter für DE]: CH
#   ✅ Ausgewählt: CH (Schweiz)
#
# MIGRATION VON LOCALE.NIX:
#
#   Ersetze:
#     my.locale.profile = "DE";
#   
#   Durch:
#     my.autoLocale = {
#       enable = true;
#       country = "DE";
#     };
#
# DEAKTIVIEREN (nach Installation):
#
#   # auto-locale.nix komplett entfernen
#   # Zurück zu locale.nix:
#   my.locale.profile = "DE";
#
# ══════════════════════════════════════════════════════════════════════════
