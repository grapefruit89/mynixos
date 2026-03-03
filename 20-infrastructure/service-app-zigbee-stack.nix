{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-20-SRV-035";
    title = "Zigbee Stack (MQTT & Z2M)";
    description = "Decoupled Zigbee infrastructure with Mosquitto and Zigbee2MQTT for SLZB-06.";
    layer = 20;
    nixpkgs.category = "services/home-automation";
    capabilities = [ "iot/zigbee" "iot/mqtt" "hardware/slzb-06" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 3;
  };

  cfg = config.my.configs.hardware;
  portZ2M = config.my.ports.zigbee2mqtt;
  portMQTT = config.my.ports.mqtt;
in
{
  options.my.meta.zigbee_stack = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for zigbee-stack module";
  };


  config = lib.mkIf config.my.services.zigbeeStack.enable {
    services.mosquitto = { enable = true; listeners = [{ port = portMQTT; address = "127.0.0.1"; acl = [ "pattern readwrite #" ]; settings.allow_anonymous = true; }]; };
    services.zigbee2mqtt = {
      enable = true; dataDir = "/var/lib/zigbee2mqtt";
      settings = { homeassistant = { enabled = true; }; permit_join = false; mqtt = { base_topic = "zigbee2mqtt"; server = "mqtt://127.0.0.1:${toString portMQTT}"; }; serial = { port = "tcp://${cfg.zigbeeStickIP}:6638"; adapter = "ember"; }; frontend = { port = portZ2M; host = "127.0.0.1"; }; };
    };
    services.caddy.virtualHosts."zigbee.${config.my.configs.identity.domain}" = { extraConfig = "import sso_auth\nreverse_proxy 127.0.0.1:${toString portZ2M}"; };
    systemd.services.zigbee2mqtt.serviceConfig = { ProtectSystem = "strict"; ProtectHome = true; PrivateTmp = true; RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ]; };
  };
}
