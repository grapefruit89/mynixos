/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-016
 *   title: "Uptime Kuma (SRE Hardened)"
 *   layer: 10
 * summary: Self-hosted monitoring tool, tightly sandboxed.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/monitoring/uptime-kuma.nix
 * ---
 */
{ config, lib, ... }:
let
  port = config.my.ports.uptimeKuma;
in
{
  # 🚀 UPTIME KUMA EXHAUSTION
  services.uptime-kuma = {
    enable = true;
    # SSoT: Port über Zentrale Registry
    settings.PORT = toString port;
  };

  # ── CADDY INTEGRATION ────────────────────────────────────────────────────
  services.caddy.virtualHosts."status.${config.my.configs.identity.domain}" = {
    extraConfig = ''
      import sso_auth
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };

  # ── SRE SANDBOXING ───────────────────────────────────────────────────────
  systemd.services.uptime-kuma.serviceConfig = {
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    PrivateDevices = true;
    NoNewPrivileges = true;
    # Uptime Kuma braucht nur Netzwerk-Zugriff für Pings
    CapabilityBoundingSet = [ "CAP_NET_RAW" ];
    AmbientCapabilities = [ "CAP_NET_RAW" ];
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
