/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-008
 *   title: "Monica (SRE Expert Edition)"
 *   layer: 20
 * summary: Personal CRM with declarative artisan management and secure PHP-FPM setup.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/monica.nix
 * ---
 */
{ config, lib, pkgs, ... }:
let
  port = config.my.ports.monica;
  domain = config.my.configs.identity.domain;
  appKeyFile = "/var/lib/monica/app-key";
in
{
  # 🚀 MONICA EXHAUSTION
  services.monica = {
    enable = true;
    hostname = "monica.${domain}";
    appURL = "https://monica.${domain}";
    inherit appKeyFile;

    # ── DEKLARATIVE PHP-FPM KONFIGURATION ──────────────────────────────────
    nginx.listen = [
      {
        addr = "127.0.0.1";
        port = port;
        ssl = false; # Caddy macht SSL
      }
    ];
    
    # DB-Wiring (Nutzt MariaDB standardmäßig, wir lassen es lokal wie im Modul vorgesehen)
    database.createLocally = true;
  };

  # ── CADDY INTEGRATION ────────────────────────────────────────────────────
  services.caddy.virtualHosts."monica.${domain}" = {
    extraConfig = ''
      import sso_auth
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };

  # ── SRE AUTOMATISIERUNG (App-Key Handling) ───────────────────────────────
  system.activationScripts.monicaAppKeyFile.text = ''
    set -eu
    install -d -m 0750 -o monica -g monica /var/lib/monica
    if [ ! -s ${appKeyFile} ]; then
      head -c 32 /dev/urandom | base64 > ${appKeyFile}
    fi
    chown monica:monica ${appKeyFile}
    chmod 0600 ${appKeyFile}
  '';

  # ── SRE HARDENING ───────────────────────────────────────────────────────
  systemd.services.phpfpm-monica.serviceConfig = {
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    PrivateDevices = true;
    # Monica braucht Dateizugriff für Uploads
    ReadWritePaths = [ "/var/lib/monica" ];
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
