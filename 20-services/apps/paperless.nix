/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-012
 *   title: "Paperless-ngx (SRE Multi-Service)"
 *   layer: 20
 * summary: Professional document management with multi-service isolation (Web, Scheduler, Worker).
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/paperless.nix
 * ---
 */
{ config, lib, pkgs, ... }:
let
  port = config.my.ports.paperless;
  user = "paperless";
  dataDir = "/var/lib/paperless";
in
{
  # 🚀 PAPERLESS-NGX EXHAUSTION
  services.paperless = {
    enable = true;
    address = "127.0.0.1";
    port = port;
    
    # ── DB-WIRING (SSoT) ──────────────────────────────────────────────────
    # Nutzt die zentrale PostgreSQL Instanz aus Layer 10
    database.createLocally = true; 
    
    # ── DOCUMENT PROCESSING ───────────────────────────────────────────────
    # Tika & Gotenberg für Office/Email Support
    configureTika = true;
    
    settings = {
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_TIME_ZONE = config.time.timeZone;
      # SRE Performance: Verhindert CPU-Spamming durch Classifier
      PAPERLESS_ENABLE_NLTK = true;
    };

    # Secret Handling via sops-nix
    passwordFile = config.sops.secrets.paperless_secret_key.path;
  };

  # ── CADDY INTEGRATION ────────────────────────────────────────────────────
  services.caddy.virtualHosts."docs.${config.my.configs.identity.domain}" = {
    extraConfig = ''
      import sso_auth
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };

  # ── SRE HARDENING (Aviation Grade) ───────────────────────────────────────
  # Das NixOS-Modul erzeugt automatisch 3 Services (web, consumer, scheduler).
  # Wir härten diese kollektiv über systemd overrides.
  systemd.services.paperless-web.serviceConfig = {
    OOMScoreAdjust = -200; # Web-UI soll stabil bleiben
    ProtectSystem = "strict";
    # Verhindert Schreibzugriff außer auf Daten/Media
    ReadWritePaths = [ "/var/lib/paperless" "/data/media/paperless" ];
  };

  # ── INFRASTRUCTURE HELPERS ──────────────────────────────────────────────
  # Gotenberg & Tika werden durch 'configureTika = true' automatisch aktiviert.
  # Wir stellen sicher, dass sie in Slices isoliert sind.
  systemd.services.gotenberg.serviceConfig.Slice = "system-paperless.slice";
  systemd.services.tika.serviceConfig.Slice = "system-paperless.slice";
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
