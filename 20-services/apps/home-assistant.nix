/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Home Assistant
 * TRACE-ID:     NIXH-SRV-004
 * PURPOSE:      Zentrale Hausautomations-Instanz.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [00-core/configs.nix, 00-core/ports.nix]
 * LAYER:        20-services
 * STATUS:       Stable
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
