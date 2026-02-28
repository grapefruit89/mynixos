/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-034
 *   title: "SERVICE_TEMPLATE"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
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
 *   checksum: sha256:e65582938a05f0432f212849ad80e0e18034b4f5f6333a6913b6075f3ccbae10
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
