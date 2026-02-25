# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: SSH nur aus Heimnetzen/Tailnet, niemals offen ins Internet

{ lib, config, ... }:
let
  # source-id: CFG.ports.ssh
  # sink: SSH-Dienstport in Interface- und Input-Regeln
  sshPort = config.my.ports.ssh;
  useNft = config.my.firewall.backend == "nftables";
  # source-id: CFG.network.lanCidrs
  lanCidrs = config.my.configs.network.lanCidrs;
  # source-id: CFG.network.tailnetCidrs
  tailnetCidrs = config.my.configs.network.tailnetCidrs;
  rfc1918 = lib.concatStringsSep ", " lanCidrs;
  tailnet = lib.concatStringsSep ", " tailnetCidrs;
in
{
  options.my.firewall.backend = lib.mkOption {
    type = lib.types.enum [ "iptables" "nftables" ];
    default = "iptables";
    description = "Firewall backend selector. Keep iptables until nftables is explicitly enabled.";
  };

  config = {
    networking.nftables.enable = useNft;
    networking.firewall.enable = true;

    # [SEC-NET-EDGE-001] Global inbound bleibt minimal: nur HTTPS.
    networking.firewall.allowedTCPPorts = lib.mkForce [ config.my.ports.traefikHttps ];
    # mDNS for .local (Avahi)
    networking.firewall.allowedUDPPorts = lib.mkForce [ 5353 ];

    # [SEC-NET-SSH-002] SSH explizit ueber Tailscale Interface.
    networking.firewall.interfaces.tailscale0.allowedTCPPorts = lib.mkForce [ sshPort ];

    # [SEC-NET-SSH-001]/[SEC-NET-SSH-002] SSH und DNS nur aus Heimnetzen + Tailscale-CGNAT.
    # NOTE: extraInputRules are nftables-only; keep iptables mirror below for legacy backend.
    networking.firewall.extraInputRules = lib.mkForce ''
      ip saddr { ${rfc1918}, ${tailnet} } tcp dport ${toString sshPort} accept

      ip saddr { ${rfc1918}, ${tailnet} } tcp dport 53 accept
      ip saddr { ${rfc1918}, ${tailnet} } udp dport 53 accept

      ip saddr { ${rfc1918} } udp dport 5353 accept
    '';

    # iptables backend mirror for LAN/Tailscale rules.
    networking.firewall.extraCommands = lib.mkIf (!useNft) (lib.mkAfter ''
      ${lib.concatMapStrings (cidr:
        "/run/current-system/sw/bin/iptables -A nixos-fw -s ${cidr} -p tcp --dport ${toString sshPort} -j nixos-fw-accept\n"
      ) (lanCidrs ++ tailnetCidrs)}

      ${lib.concatMapStrings (cidr:
        "/run/current-system/sw/bin/iptables -A nixos-fw -s ${cidr} -p tcp --dport 53 -j nixos-fw-accept\n"
      ) (lanCidrs ++ tailnetCidrs)}

      ${lib.concatMapStrings (cidr:
        "/run/current-system/sw/bin/iptables -A nixos-fw -s ${cidr} -p udp --dport 53 -j nixos-fw-accept\n"
      ) (lanCidrs ++ tailnetCidrs)}

      ${lib.concatMapStrings (cidr:
        "/run/current-system/sw/bin/iptables -A nixos-fw -s ${cidr} -p udp --dport 5353 -j nixos-fw-accept\n"
      ) lanCidrs}
    '');

    networking.firewall.extraStopCommands = lib.mkIf (!useNft) (lib.mkAfter ''
      ${lib.concatMapStrings (cidr:
        "/run/current-system/sw/bin/iptables -D nixos-fw -s ${cidr} -p tcp --dport ${toString sshPort} -j nixos-fw-accept || true\n"
      ) (lanCidrs ++ tailnetCidrs)}

      ${lib.concatMapStrings (cidr:
        "/run/current-system/sw/bin/iptables -D nixos-fw -s ${cidr} -p tcp --dport 53 -j nixos-fw-accept || true\n"
      ) (lanCidrs ++ tailnetCidrs)}

      ${lib.concatMapStrings (cidr:
        "/run/current-system/sw/bin/iptables -D nixos-fw -s ${cidr} -p udp --dport 53 -j nixos-fw-accept || true\n"
      ) (lanCidrs ++ tailnetCidrs)}

      ${lib.concatMapStrings (cidr:
        "/run/current-system/sw/bin/iptables -D nixos-fw -s ${cidr} -p udp --dport 5353 -j nixos-fw-accept || true\n"
      ) lanCidrs}
    '');
  };
}
