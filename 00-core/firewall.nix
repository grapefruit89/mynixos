/**
 * ---
 * nms_version: 2.1
 * unit:
 *   id: NIXH-00-SYS-CORE-008
 *   title: "Firewall"
 *   layer: 00
 *   req_refs: [REQ-CORE]
 *   status: stable
 * traceability:
 *   parent: NIXH-00-SYS-ROOT
 *   depends_on: []
 *   conflicts_with: []
 * security:
 *   integrity_hash: "sha256:5f254b4c22d6722678ab57f43eeb18861aba3ef457cd044a66c1794484e82c94"
 *   trust_level: 5
 *   last_audit: "2026-02-28"
 * automation:
 *   complexity_score: 2
 *   auto_fix: true
 * ---
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
