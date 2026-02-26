# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: VPN Confinement via Netzwerk-Namespaces (Nixarr-Inspiration)

{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.networking.vpn-confinement;
  vpnName = "vpn";
in
{
  config = lib.mkIf cfg.enable {
    # ── NAMESPACE SETUP ──────────────────────────────────────────────────────
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

    # ── WIREGUARD NAMESPACE INTEGRATION ─────────────────────────────────────
    # Hinweis: Damit das funktioniert, muss das Wireguard-Interface 'privado' 
    # beim Start in den Namespace verschoben werden.
    # Wir bereiten hier die Logik vor, um Dienste via 'NetworkNamespacePath' 
    # im systemd-Service zu isolieren.
  };
}
