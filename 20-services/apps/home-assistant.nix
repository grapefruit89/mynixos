/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-005
 *   title: "Home Assistant (Fully Declarative)"
 *   layer: 20
 * summary: Tightly integrated home automation with Nix-managed components and UI.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/home-automation/home-assistant.nix
 * ---
 */
{ config, lib, pkgs, ... }:
let
  domain = config.my.configs.identity.domain;
in
{
  # 🚀 HOME ASSISTANT EXHAUSTION
  services.home-assistant = {
    enable = true;
    
    # ── DEKLARATIVE KOMPONENTEN ────────────────────────────────────────────
    # Nix löst alle Python-Abhängigkeiten systemweit
    extraComponents = [
      "default_config" "met" "esphome" "prometheus" 
      "mobile_app" "sun" "radio_browser" "google_translate"
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

      # SRE: Observability Integration (Prometheus)
      prometheus.namespace = "hass";

      # Web-Server Hardening (Trusted Proxies für Caddy)
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [ "127.0.0.1" "::1" "100.64.0.0/10" ];
      };

      # UI Modus: YAML (Verhindert UI-Silos)
      lovelace.mode = "yaml";
    };

    # ── DEKLARATIVE UI (Lovelace) ──────────────────────────────────────────
    lovelaceConfig = {
      title = "NixHome Dashboard";
      views = [{
        title = "Overview";
        icon = "mdi:home";
        cards = [
          { type = "weather-forecast"; entity = "weather.home"; }
          { type = "entities"; entities = [ "sun.sun" ]; }
        ];
      }];
    };
  };

  # ── CADDY INTEGRATION ────────────────────────────────────────────────────
  services.caddy.virtualHosts."home.${domain}" = {
    extraConfig = ''
      # Home Assistant braucht Websockets
      reverse_proxy localhost:8123
    '';
  };

  # ── SRE HARDENING ───────────────────────────────────────────────────────
  systemd.services.home-assistant.serviceConfig = {
    # GPU Zugriff für Video-Processing (Kameras)
    DeviceAllow = [ "/dev/dri/renderD128 rw" ];
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    # HA darf bei OOM vor Caddy/SSH sterben
    OOMScoreAdjust = 300; 
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
