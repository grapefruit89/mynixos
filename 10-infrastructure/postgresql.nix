/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-018
 *   title: "PostgreSQL"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ config, lib, pkgs, ... }:
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    ensureDatabases = [ "miniflux" "paperless" "n8n" ];
    ensureUsers = [
      { name = "miniflux"; ensureDBOwnership = true; }
      { name = "paperless"; ensureDBOwnership = true; }
      { name = "n8n"; ensureDBOwnership = true; }
    ];
  };

  systemd.services.miniflux.after = [ "postgresql.service" ];
  systemd.services.paperless.after = [ "postgresql.service" ];
  systemd.services.n8n.after = [ "postgresql.service" ];
}
