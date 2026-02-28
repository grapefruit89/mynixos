/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Firewall
 * TRACE-ID:     NIXH-CORE-004
 * REQ-REF:      REQ-CORE
 * LAYER:        10
 * STATUS:       Stable
 * INTEGRITY:    SHA256:2b267833ceb9adf7736472aa0a41254e1bd3ef9b2cec41217e363d3ab39a18d2
 */

{ lib, config, ... }:
let
  # source-id: CFG.identity.bastelmodus
  bastelmodus = config.my.configs.bastelmodus;

  # source-id: CFG.ports.ssh
  sshPort = config.my.ports.ssh;

  # source-id: CFG.network.lanCidrs
  lanCidrs = config.my.configs.network.lanCidrs;
  tailnetCidrs = config.my.configs.network.tailnetCidrs;

  rfc1918 = lib.concatStringsSep ", " lanCidrs;
  tailnet = lib.concatStringsSep ", " tailnetCidrs;
in
{
  # source-id: CFG.firewall.enabled
  networking.firewall.enable = !bastelmodus;

  # Trust tailscale0 interface
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # source-id: CFG.firewall.backend
  networking.nftables.enable = true;

  # source-id: CFG.ports.edgeHttps / CFG.ports.ssh
  networking.firewall.allowedTCPPorts = lib.mkForce [ 
    config.my.ports.edgeHttps 80 
    sshPort 
  ];

  # source-id: CFG.firewall.globalUdp
  networking.firewall.allowedUDPPorts = lib.mkForce [ 5353 ];

  # source-id: CFG.network.lanCidrs
  networking.firewall.extraInputRules = lib.mkForce ''
    # DNS nur intern
    ip saddr { ${rfc1918}, ${tailnet} } tcp dport 53 accept
    ip saddr { ${rfc1918}, ${tailnet} } udp dport 53 accept

    # mDNS nur aus RFC1918-LAN
    ip saddr { ${rfc1918} } udp dport 5353 accept
  '';
}
