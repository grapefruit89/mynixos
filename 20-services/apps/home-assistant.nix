{ config, lib, pkgs, ... }:
let
  myLib = import ../../lib/helpers.nix { inherit lib; };
  domain = config.my.configs.identity.domain;
  
  serviceBase = myLib.mkService {
    inherit config;
    name = "homeassistant";
    useSSO = false; # HA has its own robust auth and mobile app needs it
    description = "Home Automation (Vanilla Core)";
  };
in
lib.mkMerge [
  serviceBase
  {
    # ── HOME ASSISTANT CORE ──────────────────────────────────────────────────
    # Hinweis: SLZB-06M (Ethernet) wird in HA via ZHA (socket://IP:PORT) eingebunden.
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

        # Standard-Komponenten
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
