{ config, lib, pkgs, ... }:

let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-00-CORE-035";
    title = "Auto Locale";
    description = "Intelligent country detection via IP geolocation for zero-touch locale setup.";
    layer = 00;
    nixpkgs.category = "system/localization";
    capabilities = [ "automation/geolocate" "system/boot-optimization" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

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
      keyMap = "us-intl";
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
  
  geolocateScript = pkgs.writeShellScript "geolocate" ''
    set -euo pipefail
    COUNTRY=$(${pkgs.curl}/bin/curl -sf --max-time 5 "http://ip-api.com/json/?fields=countryCode" | ${pkgs.jq}/bin/jq -r '.countryCode' 2>/dev/null || echo "")
    if [ -n "$COUNTRY" ]; then echo "$COUNTRY"; exit 0; fi
    COUNTRY=$(${pkgs.curl}/bin/curl -sf --max-time 5 "https://ipapi.co/country/" 2>/dev/null || echo "")
    if [ -n "$COUNTRY" ]; then echo "$COUNTRY"; exit 0; fi
    echo "DE"
  '';
  
  selectCountryScript = pkgs.writeShellScriptBin "select-country" ''
    #!/usr/bin/env bash
    set -euo pipefail
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🌍 Auto-Locale: Land auswählen"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Verfügbare Länder:"
    ${lib.concatMapStringsSep "\n" (code: let profile = profiles.${code}; in ''  echo "  [${code}] ${profile.name}"'') (lib.attrNames profiles)}
    AUTO=$(${geolocateScript})
    echo "🔍 Automatisch erkannt: $AUTO"
    read -p "Land auswählen [Enter für $AUTO]: " CHOICE
    CHOICE=''${CHOICE:-$AUTO}
    CHOICE=$(echo "$CHOICE" | tr '[:lower:]' '[:upper:]')
    case "$CHOICE" in
      ${lib.concatMapStringsSep "|" (code: code) (lib.attrNames profiles)})
        echo "✅ Ausgewählt: $CHOICE"
        echo "Trage in /etc/nixos/00-core/configs.nix ein: my.autoLocale.country = \"$CHOICE\";"
        ;;
      *)
        echo "❌ Ungültige Auswahl: $CHOICE. Verwende Default: $AUTO"
        ;;
    esac
  '';
  
  cacheFile = "/var/lib/auto-locale/country";
  selectedCountry = if cfg.country != "" then cfg.country else if builtins.pathExists cacheFile then lib.removeSuffix "\n" (builtins.readFile cacheFile) else "DE";
  profile = profiles.${selectedCountry} or profiles.DE;
in
{
  options.my.meta.auto_locale = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for auto-locale module";
  };

  options.my.autoLocale = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Aktiviert automatische Locale-Erkennung via Geolocation.";
    };
    country = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Länder-Code (ISO 3166-1 alpha-2). Leer = Automatisch.";
    };
    forceGeolocation = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Erzwingt Geolocation bei jedem Boot.";
    };
  };
  
  config = lib.mkIf cfg.enable {
    time.timeZone = lib.mkDefault profile.timeZone;
    i18n.defaultLocale = lib.mkDefault profile.locale;
    i18n.supportedLocales = lib.mkForce [ "de_DE.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" "en_GB.UTF-8/UTF-8" "fr_FR.UTF-8/UTF-8" ];
    console.keyMap = lib.mkDefault profile.keyMap;
    services.xserver.xkb = { layout = lib.mkDefault profile.xkbLayout; variant = ""; };
    networking.timeServers = lib.mkDefault profile.ntp;
    
    systemd.services.auto-locale-detect = {
      description = "Auto-Locale: Detect Country via Geolocation";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      unitConfig = lib.mkIf (!cfg.forceGeolocation) { ConditionPathExists = "!${cacheFile}"; };
      serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
      script = ''
        mkdir -p "$(dirname ${cacheFile})"
        COUNTRY=$(${geolocateScript} || echo "DE")
        echo "$COUNTRY" > ${cacheFile}
        logger -t auto-locale "Detected country: $COUNTRY"
      '';
    };
    
    environment.systemPackages = [ selectCountryScript (pkgs.writeShellScriptBin "show-locale" "echo Land: ${selectedCountry}") ];
    programs.bash.shellAliases = { "locale-info" = "show-locale"; "locale-select" = "sudo select-country"; };
    assertions = [ { assertion = cfg.country == "" || (profiles ? ${cfg.country}); message = "auto-locale: Ungültiger Länder-Code: ${cfg.country}"; } ];
  };
}
