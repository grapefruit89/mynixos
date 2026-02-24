{ ... }:
{
  # source: services.tailscale.* options here
  # sink:   tailscaled systemd unit + firewall behavior
  services.tailscale = {
    enable = true;

    # Keep firewall policy centralized in 00-core/firewall.nix.
    openFirewall = false;

    # No subnet-router / exit-node behavior unless explicitly enabled later.
    useRoutingFeatures = "none";
  };
}
