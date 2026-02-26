# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: locale/profile Modul

{ lib, config, ... }:
let
  profiles = {
    DE = {
      timeZone = "Europe/Berlin";
      locale = "de_DE.UTF-8";
      keyMap = "de-latin1";
      xkbLayout = "de";
      ntp = [ "0.de.pool.ntp.org" "1.de.pool.ntp.org" "2.de.pool.ntp.org" "3.de.pool.ntp.org" ];
    };
    AT = {
      timeZone = "Europe/Vienna";
      locale = "de_AT.UTF-8";
      keyMap = "de-latin1";
      xkbLayout = "de";
      ntp = [ "0.at.pool.ntp.org" "1.at.pool.ntp.org" "2.at.pool.ntp.org" "3.at.pool.ntp.org" ];
    };
    CH = {
      timeZone = "Europe/Zurich";
      locale = "de_CH.UTF-8";
      keyMap = "de-latin1";
      xkbLayout = "de";
      ntp = [ "0.ch.pool.ntp.org" "1.ch.pool.ntp.org" "2.ch.pool.ntp.org" "3.ch.pool.ntp.org" ];
    };
    EN = {
      timeZone = "Etc/UTC";
      locale = "en_GB.UTF-8";
      keyMap = "us";
      xkbLayout = "us";
      ntp = [ "0.uk.pool.ntp.org" "1.uk.pool.ntp.org" "2.uk.pool.ntp.org" "3.uk.pool.ntp.org" ];
    };
  };

  profile = config.my.locale.profile;
  cfg = profiles.${profile} or profiles.DE;

  must = assertion: message: { inherit assertion message; };
  allowed = builtins.attrNames profiles;
in
{
  options.my.locale.profile = lib.mkOption {
    type = lib.types.str;
    default = "DE";
    description = "Locale profile selector (DE/AT/CH/EN).";
  };

  config = {
    assertions = [
      (must (builtins.elem profile allowed) "locale: my.locale.profile must be one of: ${lib.concatStringsSep ", " allowed}")
    ];

    time.timeZone = cfg.timeZone;

    i18n.defaultLocale = cfg.locale;
    i18n.supportedLocales = lib.mkForce [ "de_DE.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];

    console.keyMap = lib.mkForce cfg.keyMap;

    # Keyboard layout for X11 and Wayland
    services.xserver.xkb = {
      layout = cfg.xkbLayout;
      variant = "";
    };

    networking.timeServers = cfg.ntp;

    # source-id: CFG.network.dnsNamed
    networking.nameservers =
      [ "127.0.0.1" ]
      ++ config.my.configs.network.dnsNamed;

    services.resolved = {
      enable = true;
      dnssec = "true";
      dnsovertls = "opportunistic";
      domains = [ "~." ];
      # source-id: CFG.network.dnsFallback
      fallbackDns = config.my.configs.network.dnsFallback;
    };
  };
}
