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
    useSSO = false; # HA has its own robust auth
    description = "Home Automation (Full Declarative Core)";
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
      
      # 🚀 VOLL-DEKLARATIVE KONFIGURATION
      # Verhindert UI-Konfig-Drift und macht das Setup 100% reproduzierbar.
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

        # Deklarative Dashboards (Lovelace)
        lovelace.mode = "yaml";

        # Standard-Komponenten & Integrationen
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
        
        # SRE: Observability
        prometheus = { };
      };
    };
  }
]



/**
 * ---
 * technical_integrity:
 *   checksum: sha256:1c2355a6a1a0d84da8c6d629cc23403e74cfa9fb97369f515c82eb0fad25c6b1
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
