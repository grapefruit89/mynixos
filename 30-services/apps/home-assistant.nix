/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Home Assistant
 * TRACE-ID:     NIXH-SRV-007
 * REQ-REF:      REQ-SRV
 * LAYER:        30
 * STATUS:       Stable
 * INTEGRITY:    SHA256:65ad414bf5634faf21c6e1ec07b0a0d9669b2a476bd731f76c207acd51ea4e7b
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
