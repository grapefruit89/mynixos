# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: VPN Confinement via Netzwerk-Namespaces (Zero-Leak Strategie)

{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.networking.vpn-confinement;
  vpnName = "vpn";
in
{
  config = lib.mkIf cfg.enable {
    # ── NAMESPACE SETUP ──────────────────────────────────────────────────────
    # Erstellt den Namespace 'vpn' beim Systemstart
    systemd.services.netns-vpn = {
      description = "VPN Network Namespace";
      before = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = ''
          ${pkgs.iproute2}/bin/ip netns add ${vpnName} || true
          ${pkgs.iproute2}/bin/ip netns exec ${vpnName} ${pkgs.iproute2}/bin/ip link set lo up
        '';
        ExecStop = "${pkgs.iproute2}/bin/ip netns del ${vpnName}";
      };
    };

    # ── WIREGUARD INTEGRATION ────────────────────────────────────────────────
    # Wir binden das Wireguard-Interface direkt in den Namespace
    # (Dies erfordert Anpassungen in wireguard-vpn.nix - wir nutzen hier den Pfad)
    
    # [NOTIZ] Für volle Nixarr-Funktionalität müssten wir Dienste
    # mit 'NetworkNamespacePath=/run/netns/vpn' starten.
  };
}
