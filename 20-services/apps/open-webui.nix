/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-011
 *   title: "Open WebUI (SRE Hardened)"
 *   layer: 20
 * summary: User-friendly WebUI for LLMs, tightly sandboxed with DynamicUser.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/open-webui.nix
 * ---
 */
{ config, lib, pkgs, ... }:
let
  port = config.my.ports.openWebui;
  domain = config.my.configs.identity.domain;
in
{
  # 🚀 OPEN-WEBUI EXHAUSTION
  services.open-webui = {
    enable = true;
    host = "127.0.0.1";
    port = port;
    
    # ── AI WIRING (Ollama Integration) ────────────────────────────────────
    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
      # SRE: Privacy & Performance
      SCARF_NO_ANALYTICS = "True";
      DO_NOT_TRACK = "True";
      ANONYMIZED_TELEMETRY = "False";
    };
  };

  # ── CADDY INTEGRATION ────────────────────────────────────────────────────
  services.caddy.virtualHosts."ai.${domain}" = {
    extraConfig = ''
      import sso_auth
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };

  # ── SRE SANDBOXING (Level: High) ─────────────────────────────────────────
  systemd.services.open-webui.serviceConfig = {
    # Aus nixpkgs übernommen: Maximale Isolation
    DynamicUser = true;
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    PrivateDevices = true;
    
    # render group ermöglicht Zugriff auf GPU (iHD Treiber)
    SupplementaryGroups = [ "render" "video" ];
    
    # System-Call Filter
    SystemCallFilter = [ "@system-service" "~@privileged" ];
    
    # OOM-Schutz: KI-Frontends können Speicher-intensiv sein
    OOMScoreAdjust = 200;
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
