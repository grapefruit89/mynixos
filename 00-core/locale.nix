/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-013
 *   title: "Locale (SRE Refactored)"
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
  # SSoT: Pulling from Master Source (configs.nix)
  tz = config.my.configs.locale.timezone;
  loc = config.my.configs.locale.default;
in
{
  config = {
    time.timeZone = tz;
    i18n.defaultLocale = loc;
    i18n.supportedLocales = lib.mkForce [ "de_DE.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
    
    # Standard settings for Germany/EU
    console.keyMap = lib.mkForce "de-latin1";
    services.xserver.xkb = {
      layout = "de";
      variant = "";
    };

    networking.timeServers = [ 
      "0.de.pool.ntp.org" 
      "1.de.pool.ntp.org" 
      "2.de.pool.ntp.org" 
      "3.de.pool.ntp.org" 
    ];

    # DNS configuration (integrated with systemwide SRE standards)
    services.resolved = {
      enable = true;
      dnssec = "true";
      dnsovertls = "opportunistic";
      domains = [ "~." ];
    };
  };
}
/**
 * ---
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 * ---
 */
