/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-20-APP-SRV-034
 *   title: "SERVICE_TEMPLATE"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   status: audited
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

/**
 * ---
 * technical_integrity:
 *   checksum: sha256:1227034f1d2e8a80dce2a7326d613309d47d07fe96fbf946a9370923a202eb53
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
