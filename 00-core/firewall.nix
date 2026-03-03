{ lib, config, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-00-CORE-008";
    title = "Firewall (nftables Pro)";
    description = "Modern nftables configuration with clean separation of zones.";
    layer = 00;
    nixpkgs.category = "system/networking";
    capabilities = [ "network/firewall" "security/nftables" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

  bastelmodus = config.my.configs.bastelmodus;
  sshPort = config.my.ports.ssh;
  lanCidrs = config.my.configs.network.lanCidrs;
  tailnetCidrs = config.my.configs.network.tailnetCidrs;
  rfc1918 = lib.concatStringsSep ", " lanCidrs;
  tailnet = lib.concatStringsSep ", " tailnetCidrs;
in
{
  options.my.meta.firewall = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for firewall module";
  };

  config = {
    networking.nftables.enable = true;
    networking.firewall.enable = !bastelmodus;
    networking.firewall.trustedInterfaces = [ "tailscale0" ];
    networking.firewall.allowedTCPPorts = lib.mkForce [ config.my.ports.edgeHttps 80 sshPort 22 ];
    networking.firewall.extraInputRules = lib.mkForce ''
      ip saddr { ${rfc1918}, ${tailnet} } tcp dport 53 accept
      ip saddr { ${rfc1918}, ${tailnet} } udp dport 53 accept
      ip saddr { ${rfc1918} } udp dport 5353 accept
      ip protocol icmp accept
    '';
    networking.firewall.logRefusedConnections = false;
  };
}
