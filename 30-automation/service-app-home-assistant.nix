{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-20-SRV-005";
    title = "Home Assistant (Fully Declarative)";
    description = "Tightly integrated home automation with MQTT and declarative UI.";
    layer = 20;
    nixpkgs.category = "services/home-automation";
    capabilities = [ "home-automation/hass" "iot/mqtt" "ui/lovelace" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 3;
  };

  domain = config.my.configs.identity.domain;
  portMQTT = config.my.ports.mqtt;
in
{
  options.my.meta.home_assistant = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for home-assistant module";
  };


  config = lib.mkIf config.my.services.homeAssistant.enable {
    services.home-assistant = {
      enable = true;
      extraComponents = [ "default_config" "met" "esphome" "prometheus" "mobile_app" "sun" "radio_browser" "google_translate" "mqtt" ];
      config = {
        homeassistant = { name = "NixHome"; unit_system = "metric"; time_zone = config.time.timeZone; external_url = "https://home.${domain}"; internal_url = "http://localhost:8123"; };
        mqtt = { broker = "127.0.0.1"; port = portMQTT; };
        prometheus.namespace = "hass";
        http = { use_x_forwarded_for = true; trusted_proxies = [ "127.0.0.1" "::1" "100.64.0.0/10" ]; };
        lovelace.mode = "yaml";
      };
      lovelaceConfig = {
        title = "NixHome Control Center";
        views = [{ title = "Overview"; icon = "mdi:home"; cards = [ { type = "weather-forecast"; entity = "weather.home"; } { type = "entities"; title = "System Status"; entities = [ "sun.sun" ]; } { type = "button"; name = "Zigbee Admin"; icon = "mdi:zigbee"; tap_action = { action = "url"; url_path = "https://zigbee.${domain}"; }; } ]; }];
      };
    };
    services.caddy.virtualHosts."home.${domain}" = { extraConfig = "reverse_proxy localhost:8123"; };
    systemd.services.home-assistant.serviceConfig = { DeviceAllow = [ "/dev/dri/renderD128 rw" ]; ProtectSystem = "strict"; ProtectHome = true; PrivateTmp = true; OOMScoreAdjust = 300; };
  };
}
