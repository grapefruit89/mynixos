/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        SERVICE_TEMPLATE
 * TRACE-ID:     NIXH-SRV-019
 * REQ-REF:      REQ-SRV
 * LAYER:        30
 * STATUS:       Stable
 * INTEGRITY:    SHA256:41d7b195aabc5611c5a1f4ee0a061f64663fc649aafc61d3be70b9563a265255
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
