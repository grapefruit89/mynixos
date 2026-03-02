/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-036
 *   title: "Matrix Conduit"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   upstream: [NIXH-00-SYS-ROOT-001, NIXH-00-SYS-LIB-001]
 *   downstream: []
 *   status: audited
 * summary: Lightweight Matrix homeserver (Conduit) written in Rust.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/matrix/conduit.nix
 * ---
 */
{ config, lib, pkgs, ... }:

let
  myLib = import ../../lib/helpers.nix { inherit lib; };
  port = config.my.ports.matrix;
  domain = config.my.configs.identity.domain;
  subdomain = config.my.configs.identity.subdomain;
  serverName = "matrix.${subdomain}.${domain}";

  # Wir nutzen mkService für Caddy, biegen aber den Service auf 'conduit' um
  serviceBase = myLib.mkService {
    inherit config;
    name = "matrix"; 
    port = port;
    useSSO = false;
    description = "Matrix Homeserver (Conduit)";
  };
in
lib.mkMerge [
  (lib.filterAttrs (n: v: n != "systemd") serviceBase) # Caddy part
  {
    services.matrix-conduit = {
      enable = true;
      settings.global = {
        server_name = serverName;
        port = port;
        address = "127.0.0.1";
        database_backend = "rocksdb";
        allow_registration = true;
      };
    };

    # ── SYSTEMD HARDENING (Aviation Grade) ──────────────────────────
    systemd.services.conduit = {
      serviceConfig = lib.mkMerge [
        serviceBase.systemd.services.matrix.serviceConfig
        {
          StateDirectory = lib.mkForce "matrix-conduit";
          ReadWritePaths = lib.mkForce [ "/var/lib/matrix-conduit" ];
          MemoryDenyWriteExecute = lib.mkForce false; 
          CPUWeight = lib.mkForce 50;
          MemoryMax = lib.mkForce "1G";
        }
      ];
    };

    # ── CADDY WELL-KNOWN INTEGRATION ────────────────────────────────────────
    services.caddy.virtualHosts."${serverName}".extraConfig = lib.mkAfter ''
      handle /.well-known/matrix/server {
        header Content-Type application/json
        respond `{"m.server": "${serverName}:443"}`
      }
      handle /.well-known/matrix/client {
        header Content-Type application/json
        header Access-Control-Allow-Origin *
        respond `{"m.homeserver": {"base_url": "https://${serverName}"}}`
      }
    '';
  }
]
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
