/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-005
 *   title: "Home Assistant (Fully Declarative)"
 *   layer: 20
 * summary: Tightly integrated home automation with MQTT and declarative UI.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/home-automation/home-assistant.nix
 * ---
 */
{ config, lib, pkgs, ... }:
let
  domain = config.my.configs.identity.domain;
  portMQTT = config.my.ports.mqtt;
in
{
  # 🚀 HOME ASSISTANT EXHAUSTION
  services.home-assistant = {
    enable = true;
    
    # ── DEKLARATIVE KOMPONENTEN ────────────────────────────────────────────
    extraComponents = [
      "default_config" "met" "esphome" "prometheus" 
      "mobile_app" "sun" "radio_browser" "google_translate"
      "mqtt" # 🚀 Aktiviert MQTT Integration
    ];

    # ── VOLL-DEKLARATIVE KONFIGURATION ──────────────────────────────────────
    config = {
      homeassistant = {
        name = "NixHome";
        unit_system = "metric";
        time_zone = config.time.timeZone;
        external_url = "https://home.${domain}";
        internal_url = "http://localhost:8123";
      };

      # 🚀 MQTT INTEGRATION
      mqtt = {
        broker = "127.0.0.1";
        port = portMQTT;
      };

      # SRE: Observability
      prometheus.namespace = "hass";

      # Web-Server Hardening
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [ "127.0.0.1" "::1" "100.64.0.0/10" ];
      };

      # 🚀 UI Modus: YAML (Best Practice für Reproduzierbarkeit)
      lovelace.mode = "yaml";
    };

    # ── DEKLARATIVE UI (Lovelace) ──────────────────────────────────────────
    lovelaceConfig = {
      title = "NixHome Control Center";
      views = [{
        title = "Overview";
        icon = "mdi:home";
        cards = [
          { type = "weather-forecast"; entity = "weather.home"; }
          { 
            type = "entities"; 
            title = "System Status";
            entities = [ "sun.sun" ]; 
          }
          {
            type = "button";
            name = "Zigbee Admin";
            icon = "mdi:zigbee";
            tap_action = {
              action = "url";
              url_path = "https://zigbee.${domain}";
            };
          }
        ];
      }];
    };
  };

  # ── CADDY INTEGRATION ────────────────────────────────────────────────────
  services.caddy.virtualHosts."home.${domain}" = {
    extraConfig = ''
      reverse_proxy localhost:8123
    '';
  };

  # ── SRE HARDENING ───────────────────────────────────────────────────────
  systemd.services.home-assistant.serviceConfig = {
    DeviceAllow = [ "/dev/dri/renderD128 rw" ];
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    OOMScoreAdjust = 300; 
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
