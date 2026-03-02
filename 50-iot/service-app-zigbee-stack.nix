/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-035
 *   title: "Zigbee Stack (MQTT & Z2M)"
 *   layer: 20
 * summary: Decoupled Zigbee infrastructure with Mosquitto and Zigbee2MQTT for SLZB-06.
 * ---
 */
{ config, lib, pkgs, ... }:
let
  cfg = config.my.configs.hardware;
  portZ2M = config.my.ports.zigbee2mqtt;
  portMQTT = config.my.ports.mqtt;
in
{
  # ── MOSQUITTO (MQTT BROKER) ──────────────────────────────────────────────
  services.mosquitto = {
    enable = true;
    listeners = [{
      port = portMQTT;
      address = "127.0.0.1"; # Nur intern
      acl = [ "pattern readwrite #" ];
      settings.allow_anonymous = true;
    }];
  };

  # ── ZIGBEE2MQTT (BRIDGE) ────────────────────────────────────────────────
  services.zigbee2mqtt = {
    enable = true;
    dataDir = "/var/lib/zigbee2mqtt";
    
    settings = {
      homeassistant = { enabled = true; };
      permit_join = false; # SRE: Standardmäßig aus
      
      # MQTT Anbindung
      mqtt = {
        base_topic = "zigbee2mqtt";
        server = "mqtt://127.0.0.1:${toString portMQTT}";
      };

      # 🚀 SLZB-06 ETHERNET ANBINDUNG
      serial = {
        port = "tcp://${cfg.zigbeeStickIP}:6638";
        adapter = "ember";
      };

      # Web-UI
      frontend = {
        port = portZ2M;
        host = "127.0.0.1";
      };
    };
  };

  # ── CADDY INTEGRATION (Z2M UI) ──────────────────────────────────────────
  services.caddy.virtualHosts."zigbee.${config.my.configs.identity.domain}" = {
    extraConfig = ''
      import sso_auth
      reverse_proxy 127.0.0.1:${toString portZ2M}
    '';
  };

  # ── SRE SANDBOXING ───────────────────────────────────────────────────────
  systemd.services.zigbee2mqtt.serviceConfig = {
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    # Netzwerkzugriff für MQTT und Ethernet-Stick nötig
    RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
