# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: Firewall — nftables-only Backend (Bastelmodus-aware)
#   specIds: [SEC-NET-SSH-001, SEC-NET-SSH-002, SEC-NET-EDGE-001]

{ lib, config, ... }:
let
  # source-id: CFG.identity.bastelmodus
  bastelmodus = config.my.configs.bastelmodus;

  # source-id: CFG.ports.ssh
  # sink: SSH-Dienstport in Interface- und Input-Regeln
  sshPort = config.my.ports.ssh;

  # source-id: CFG.network.lanCidrs
  lanCidrs = config.my.configs.network.lanCidrs;
  tailnetCidrs = config.my.configs.network.tailnetCidrs;

  rfc1918 = lib.concatStringsSep ", " lanCidrs;
  tailnet = lib.concatStringsSep ", " tailnetCidrs;
in
{
  config = {
    # source-id: CFG.firewall.enabled
    # sink: globale Host-Firewall (im Bastelmodus AUS)
    networking.firewall.enable = !bastelmodus;

    # source-id: CFG.firewall.backend
    # sink: aktiviert nftables als einziges Firewall-Backend
    networking.nftables.enable = true;

    # source-id: CFG.ports.traefikHttps / CFG.ports.ssh
    # sink: global eingehende Ports (HTTPS + SSH)
    networking.firewall.allowedTCPPorts = lib.mkForce [ 
      config.my.ports.traefikHttps 
      sshPort 
    ];

    # source-id: CFG.firewall.globalUdp
    # sink: globales UDP-Expose (nur mDNS)
    networking.firewall.allowedUDPPorts = lib.mkForce [ 5353 ];

    # source-id: CFG.network.lanCidrs
    # sink: interne Allow-Regeln für DNS/mDNS
    networking.firewall.extraInputRules = lib.mkForce ''
      # DNS nur intern
      ip saddr { ${rfc1918}, ${tailnet} } tcp dport 53 accept
      ip saddr { ${rfc1918}, ${tailnet} } udp dport 53 accept

      # mDNS nur aus RFC1918-LAN
      ip saddr { ${rfc1918} } udp dport 5353 accept
    '';
  };
}
