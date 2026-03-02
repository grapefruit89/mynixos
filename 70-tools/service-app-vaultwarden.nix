/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-017
 *   title: "Vaultwarden (SRE Exhausted)"
 *   layer: 20
 * summary: Tightly sandboxed password manager with Wake-on-Access (Socket Activation).
 * ---
 */
{ config, lib, ... }:
let
  port = config.my.ports.vaultwarden;
in
{
  services.vaultwarden = {
    enable = true;
    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = port;
      SIGNUPS_ALLOWED = false;
      INVITATIONS_ALLOWED = true;
      SHOW_PASSWORD_HINT = false;
      DATABASE_MAX_CONNS = 10;
    };
    environmentFile = config.sops.secrets.vaultwarden_env.path;
  };

  # ── WAKE-ON-ACCESS (Socket Activation) ──────────────────────────────────
  systemd.sockets.vaultwarden = {
    description = "Vaultwarden Socket (Wake-on-Access)";
    wantedBy = [ "sockets.target" ];
    listenStreams = [ (toString port) ];
  };

  # ── SRE SANDBOXING (Aviation Grade) ──────────────────────────────────────
  systemd.services.vaultwarden = {
    # Verhindert Autostart, wird erst durch Socket-Zugriff geweckt
    wantedBy = lib.mkForce [ ]; 
    requires = [ "vaultwarden.socket" ];
    after = [ "vaultwarden.socket" ];

    serviceConfig = {
      ProtectSystem = lib.mkForce "strict";
      ReadWritePaths = [ "/var/lib/vaultwarden" ];
      MemoryDenyWriteExecute = lib.mkForce true;
      RestrictAddressFamilies = lib.mkForce [ "AF_INET" "AF_UNIX" ];
      SystemCallFilter = lib.mkForce [ "@system-service" "~@privileged" "~@resources" ];
      CapabilityBoundingSet = lib.mkForce "";
      NoNewPrivileges = lib.mkForce true;
      PrivateDevices = lib.mkForce true;
      PrivateTmp = lib.mkForce true;
      ProtectProc = lib.mkForce "invisible";
      ProcSubset = lib.mkForce "pid";
      OOMScoreAdjust = 200; # Darf im Leerlauf schlafen
    };
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 * ---
 */
