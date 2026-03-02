/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-012
 *   title: "Paperless-ngx (SRE Exhausted)"
 *   layer: 20
 * summary: Document management with Wake-on-Access (Socket Activation) for the web interface.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/paperless.nix
 * ---
 */
{ config, lib, pkgs, ... }:
let
  port = config.my.ports.paperless;
in
{
  services.paperless = {
    enable = true;
    address = "127.0.0.1";
    port = port;
    dataDir = "/var/lib/paperless";
    mediaDir = "/mnt/media/documents"; 
    consumptionDir = "/mnt/fast-pool/downloads/paperless-consume";
    database.createLocally = true; 
    configureTika = true;
    
    settings = {
      PAPERLESS_OCR_LANGUAGE = config.my.configs.locale.ocrLanguage;
      PAPERLESS_TIME_ZONE = config.my.configs.locale.timezone;
      PAPERLESS_ENABLE_NLTK = true;
      PAPERLESS_TASK_WORKERS = 2; 
      PAPERLESS_THREADS_PER_WORKER = 1;
      PAPERLESS_REDIS = "redis://127.0.0.1:${toString config.my.ports.valkey}";
    };

    passwordFile = config.sops.secrets.paperless_secret_key.path;
  };

  # ── WAKE-ON-ACCESS (Socket Activation) ──────────────────────────────────
  systemd.sockets.paperless-web = {
    description = "Paperless-ngx Web Socket (Wake-on-Access)";
    wantedBy = [ "sockets.target" ];
    listenStreams = [ (toString port) ];
  };

  # ── SRE SANDBOXING ───────────────────────────────────────────────────────
  systemd.services.paperless-web = {
    wantedBy = lib.mkForce [ ];
    requires = [ "paperless-web.socket" ];
    after = [ "paperless-web.socket" ];

    serviceConfig = {
      OOMScoreAdjust = 200;
      ProtectSystem = "strict";
      ReadWritePaths = [ 
        "/var/lib/paperless" 
        "/mnt/media/documents" 
        "/mnt/fast-pool/downloads/paperless-consume" 
      ];
    };
  };

  systemd.services.gotenberg.serviceConfig.Slice = "system-paperless.slice";
  systemd.services.tika.serviceConfig.Slice = "system-paperless.slice";
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 * ---
 */
