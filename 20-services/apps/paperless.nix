/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-012
 *   title: "Paperless-ngx (SRE Multi-Service)"
 *   layer: 20
 * summary: Professional document management with standardized media paths.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/paperless.nix
 * ---
 */
{ config, lib, pkgs, ... }:
let
  port = config.my.ports.paperless;
in
{
  # 🚀 PAPERLESS-NGX EXHAUSTION
  services.paperless = {
    enable = true;
    address = "127.0.0.1";
    port = port;
    
    # 🚀 ZUGRIFFSPFADE (Standardisiert)
    dataDir = "/var/lib/paperless";
    mediaDir = "/mnt/media/documents"; # Gemappt auf Tier C (HDD)
    consumptionDir = "/mnt/fast-pool/downloads/paperless-consume"; # Gemappt auf Tier B (SSD)
    
    database.createLocally = true; 
    configureTika = true;
    
    settings = {
      # Performance Tuning (i3-9100 / 16GB RAM)
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_TIME_ZONE = config.time.timeZone;
      PAPERLESS_ENABLE_NLTK = true;
      
      # Parallelisierung (Drosselung für System-Stabilität)
      PAPERLESS_TASK_WORKERS = 2; 
      PAPERLESS_THREADS_PER_WORKER = 1;
      
      # Redis Integration (SSoT: Nutzt Valkey aus Layer 10)
      PAPERLESS_REDIS = "redis://127.0.0.1:6379";
    };

    passwordFile = config.sops.secrets.paperless_secret_key.path;
  };

  # ── CADDY INTEGRATION ────────────────────────────────────────────────────
  services.caddy.virtualHosts."docs.${config.my.configs.identity.domain}" = {
    extraConfig = ''
      import sso_auth
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };

  # ── SRE HARDENING ───────────────────────────────────────────────────────
  systemd.services.paperless-web.serviceConfig = {
    OOMScoreAdjust = -200;
    ProtectSystem = "strict";
    # Berechtigungen für standardisierte Pfade
    ReadWritePaths = [ 
      "/var/lib/paperless" 
      "/mnt/media/documents" 
      "/mnt/fast-pool/downloads/paperless-consume" 
    ];
  };

  systemd.services.gotenberg.serviceConfig.Slice = "system-paperless.slice";
  systemd.services.tika.serviceConfig.Slice = "system-paperless.slice";
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
