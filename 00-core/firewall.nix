/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-008
 *   title: "Firewall (nftables Pro)"
 *   layer: 00
 * summary: Modern nftables configuration with clean separation of zones.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/nftables.nix
 * ---
 */
{ lib, config, ... }:
let
  bastelmodus = config.my.configs.bastelmodus;
  sshPort = config.my.ports.ssh;
  lanCidrs = config.my.configs.network.lanCidrs;
  tailnetCidrs = config.my.configs.network.tailnetCidrs;

  rfc1918 = lib.concatStringsSep ", " lanCidrs;
  tailnet = lib.concatStringsSep ", " tailnetCidrs;
in
{
  # ── NFTABLES BACKEND ──────────────────────────────────────────────────────
  networking.nftables.enable = true;
  networking.firewall.enable = !bastelmodus;

  # Tailscale wird als internes Interface voll vertraut
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # ── GLOBAL PORTS (Public) ────────────────────────────────────────────────
  networking.firewall.allowedTCPPorts = lib.mkForce [ 
    config.my.ports.edgeHttps 
    80 
    sshPort 
    22 
  ];

  # ── INTERNAL RULES (Restricted) ─────────────────────────────────────────
  networking.firewall.extraInputRules = lib.mkForce ''
    # DNS-Auflösung nur für interne Clients erlauben
    ip saddr { ${rfc1918}, ${tailnet} } tcp dport 53 accept
    ip saddr { ${rfc1918}, ${tailnet} } udp dport 53 accept

    # mDNS (Local Discovery) nur im physischen LAN erlauben
    ip saddr { ${rfc1918} } udp dport 5353 accept
    
    # 🕵️ SRE Monitoring: Erlaube ICMP (Ping) für Health-Checks
    ip protocol icmp accept
  '';

  # Optimierung: Verhindert Log-Spam durch verworfene Pakete
  networking.firewall.logRefusedConnections = false;
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
