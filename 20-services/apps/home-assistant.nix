/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-005
 *   title: "Home Assistant"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
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
    description = "Home Automation (Fully Declarative Exhaustion)";
  };
in
lib.mkMerge [
  serviceBase
  {
    # 🚀 HOME ASSISTANT EXHAUSTION
    services.home-assistant = {
      enable = true;
      
      # DEKLARATIVE KOMPONENTEN
      # Alle Abhängigkeiten werden von Nix automatisch gelöst
      extraComponents = [
        "default_config"
        "met"
        "esphome"
        "prometheus"
        "mobile_app"
        "sun"
        "radio_browser"
        "google_translate"
      ];

      # VOLL-DEKLARATIVE CONFIGURATION.YAML
      config = {
        homeassistant = {
          name = "NixHome";
          unit_system = "metric";
          time_zone = config.time.timeZone;
          external_url = "https://home.nix.${domain}";
          internal_url = "http://localhost:8123";
        };

        # SRE: Observability Integration
        prometheus = {
          namespace = "hass";
        };

        # Web-Server Hardening
        http = {
          use_x_forwarded_for = true;
          trusted_proxies = [ "127.0.0.1" "::1" ];
        };

        # Deklarative Dashboards
        lovelace.mode = "yaml";
      };

      # LOVELACE UI IN NIX
      lovelaceConfig = {
        title = "NixHome Control Center";
        views = [
          {
            title = "Hauptansicht";
            icon = "mdi:home";
            cards = [
              {
                type = "vertical-stack";
                cards = [
                  { type = "weather-forecast"; entity = "weather.home"; }
                  { type = "entities"; entities = [ "sun.sun" ]; }
                ];
              }
            ];
          }
        ];
      };
    };

    # Hardening & Performance (UHD 630 Offloading falls möglich)
    systemd.services.home-assistant.serviceConfig = {
      DeviceAllow = [ "/dev/dri/renderD128" ]; # GPU Zugriff für Video-Processing
      OOMScoreAdjust = 300; # HA darf im Notfall sterben (vor SSH/Caddy)
    };
  }
]



/**
 * ---
 * technical_integrity:
 *   checksum: sha256:cab16d7da534cea54e91d06aef621aa916a9f3f874b2dc214101f22b77b0c918
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
