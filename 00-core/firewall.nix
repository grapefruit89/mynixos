/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-008
 *   title: "Firewall"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-CORE]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
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




/**
 * ---
 * technical_integrity:
 *   checksum: sha256:a01d33b08a4d597a0a94ba12fe0e0cf630e771c27e1cef305bd990ff4d5abfb4
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
