/**
 * ---
 * nms_version: 2.1
 * unit:
 *   id: NIXH-20-APP-SRV-034
 *   title: "SERVICE_TEMPLATE"
 *   layer: 20
 *   req_refs: [REQ-SRV]
 *   status: stable
 * traceability:
 *   parent: NIXH-20-SYS-ROOT
 *   depends_on: []
 *   conflicts_with: []
 * security:
 *   integrity_hash: "sha256:1227034f1d2e8a80dce2a7326d613309d47d07fe96fbf946a9370923a202eb53"
 *   trust_level: 5
 *   last_audit: "2026-02-28"
 * automation:
 *   complexity_score: 2
 *   auto_fix: true
 * ---
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
