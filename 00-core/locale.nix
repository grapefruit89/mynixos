/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-013
 *   title: "Locale"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-CORE]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
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

    services.xserver.xkb = {
      layout = cfg.xkbLayout;
      variant = "";
    };

    networking.timeServers = cfg.ntp;

    networking.nameservers = [ "127.0.0.1" ] ++ config.my.configs.network.dnsNamed;

    services.resolved = {
      enable = true;
      dnssec = "true";
      dnsovertls = "opportunistic";
      domains = [ "~." ];
      fallbackDns = config.my.configs.network.dnsFallback;
    };
  };
}




/**
 * ---
 * technical_integrity:
 *   checksum: sha256:3d77e071e12349a55e513709de6111c8d5bd8454e2e1913d683441111b7ca696
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
