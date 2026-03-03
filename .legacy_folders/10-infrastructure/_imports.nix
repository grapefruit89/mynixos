{ ... }:
{
  imports = [
    ./adguardhome.nix
    ./caddy.nix
    ./clamav.nix
    ./cloudflared-tunnel.nix
    ./cockpit.nix
    ./ddns-updater.nix
    ./dns-automation.nix
    ./homepage.nix
    ./landing-zone-ui.nix
    ./pocket-id.nix
    ./postgresql.nix
    ./secret-ingest.nix
    ./sso.nix
    ./tailscale.nix
    ./uptime-kuma.nix
    ./valkey.nix
    ./vpn-confinement.nix
    ./vpn-live-config.nix
  ];
}
