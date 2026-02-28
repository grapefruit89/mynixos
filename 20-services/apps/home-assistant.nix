/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-20-APP-SRV-005
 *   title: "Home Assistant"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   status: audited
 * ---
 */
{ config, lib, pkgs, ... }:
let
  myLib = import ../../lib/helpers.nix { inherit lib; };
  domain = config.my.configs.identity.domain;
  
  serviceBase = myLib.mkService {
    inherit config;
    name = "homeassistant";
    useSSO = false;
    description = "Home Automation (Vanilla Core)";
  };
in
lib.mkMerge [
  serviceBase
  {
    services.home-assistant = {
      enable = true;
      extraPackages = python3Packages: with python3Packages; [
        psycopg2
        pychromecast
      ];
      config = {
        homeassistant = {
          name = "NixHome";
          unit_system = "metric";
          time_zone = config.time.timeZone;
          external_url = "https://home.nix.${domain}";
          internal_url = "http://localhost:8123";
        };

        http = {
          use_x_forwarded_for = true;
          trusted_proxies = [ "127.0.0.1" "::1" ];
        };

        frontend = { };
        config = { };
        history = { };
        logbook = { };
        map = { };
        mobile_app = { };
        sun = { };
        system_health = { };
        updater = { };
        zeroconf = { };
      };
    };
  }
]

/**
 * ---
 * technical_integrity:
 *   checksum: sha256:8656a7a863a2b55aa25c69f8d9c00b367037b6937cdc31c625e773f983781943
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
