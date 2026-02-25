# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: Firewall — nftables-only Backend (iptables legacy entfernt)
#   specIds: [SEC-NET-SSH-001, SEC-NET-SSH-002, SEC-NET-EDGE-001]

{ lib, config, ... }:
let
  # source-id: CFG.ports.ssh
  # sink: SSH-Dienstport in Interface- und Input-Regeln
  sshPort = config.my.ports.ssh;

  # source-id: CFG.network.lanCidrs
  # sink: nftables source-range set für interne Netze
  lanCidrs = if config ? my && config.my ? configs && config.my.configs ? network && config.my.configs.network ? lanCidrs
    then config.my.configs.network.lanCidrs
    else [ "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16" ];

  # source-id: CFG.network.tailnetCidrs
  # sink: nftables source-range set für Tailnet
  tailnetCidrs = if config ? my && config.my ? configs && config.my.configs ? network && config.my.configs.network ? tailnetCidrs
    then config.my.configs.network.tailnetCidrs
    else [ "100.64.0.0/10" ];

  rfc1918 = lib.concatStringsSep ", " lanCidrs;
  tailnet = lib.concatStringsSep ", " tailnetCidrs;
in
{
  config = {
    # source-id: CFG.firewall.backend
    # sink: aktiviert nftables als einziges Firewall-Backend
    networking.nftables.enable = true;

    # source-id: CFG.firewall.enabled
    # sink: globale Host-Firewall aktiv
    networking.firewall.enable = true;

    # source-id: CFG.ports.traefikHttps
    # sink: global eingehender Edge-Port (HTTPS)
    networking.firewall.allowedTCPPorts = lib.mkForce [ config.my.ports.traefikHttps ];

    # source-id: CFG.firewall.globalUdp
    # sink: globales UDP-Expose (nur mDNS)
    networking.firewall.allowedUDPPorts = lib.mkForce [ 5353 ];

    # source-id: CFG.ports.ssh
    # sink: explizite SSH-Freigabe auf tailscale0
    networking.firewall.interfaces.tailscale0.allowedTCPPorts = lib.mkForce [ sshPort ];

    # source-id: CFG.network.lanCidrs
    # sink: interne Allow-Regeln für SSH/DNS/mDNS
    networking.firewall.extraInputRules = lib.mkForce ''
      # SSH nur aus privaten Ranges + Tailnet
      ip saddr { ${rfc1918}, ${tailnet} } tcp dport ${toString sshPort} accept

      # DNS nur intern
      ip saddr { ${rfc1918}, ${tailnet} } tcp dport 53 accept
      ip saddr { ${rfc1918}, ${tailnet} } udp dport 53 accept

      # mDNS nur aus RFC1918-LAN
      ip saddr { ${rfc1918} } udp dport 5353 accept
    '';
  };
}
