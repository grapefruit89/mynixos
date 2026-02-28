/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Service Blueprint Template
 * TRACE-ID:     NIXH-SRV-033
 * PURPOSE:      Standard-Vorlage für neue Dienste mit systemd-Hardening & Proxy-Anbindung.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [00-core/configs.nix, 00-core/ports.nix]
 * LAYER:        20-services
 * STATUS:       Template
 */

{ config, lib, pkgs, ... }:

let
  domain = config.my.configs.identity.domain;
  # servicePort = config.my.ports.<service-name>;
  serviceName = "<service-name>";
in
{
  services.${serviceName} = {
    enable = true;
  };

  # ── SYSTEMD HARDENING ───────────────────────────────────────────────────
  systemd.services.${serviceName}.serviceConfig = {
    NoNewPrivileges = lib.mkForce true;
    PrivateTmp = lib.mkForce true;
    PrivateDevices = lib.mkForce true;
    ProtectHome = lib.mkForce true;
    ProtectSystem = lib.mkForce "strict";
    ProtectKernelTunables = lib.mkForce true;
    ProtectKernelModules = lib.mkForce true;
    ProtectControlGroups = lib.mkForce true;
    RestrictRealtime = lib.mkForce true;
    RestrictSUIDSGID = lib.mkForce true;
    RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
  };
}
