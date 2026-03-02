/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-004
 *   title: "Filebrowser (SRE Hardened)"
 *   layer: 20
 * summary: Web-based file manager with strict path restrictions and sandboxing.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/filebrowser.nix
 * ---
 */
{ config, lib, ... }:
let
  port = config.my.ports.filebrowser;
  domain = config.my.configs.identity.domain;
in
{
  # 🚀 FILEBROWSER EXHAUSTION
  services.filebrowser = {
    enable = true;
    settings = {
      port = port;
      address = "127.0.0.1";
      root = "/mnt/storage"; # SSoT: Einstiegspunkt in den Pool
    };
  };

  # ── CADDY INTEGRATION ────────────────────────────────────────────────────
  services.caddy.virtualHosts."files.${domain}" = {
    extraConfig = ''
      import sso_auth
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };

  # ── SRE SANDBOXING (Level: High) ─────────────────────────────────────────
  systemd.services.filebrowser.serviceConfig = {
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    PrivateDevices = true;
    
    # Schreibzugriff nur auf DB und den Storage-Pool
    ReadWritePaths = [ 
      "/var/lib/filebrowser"
      "/mnt/storage" 
    ];
    
    NoNewPrivileges = true;
    SystemCallFilter = [ "@system-service" "~@privileged" ];
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
