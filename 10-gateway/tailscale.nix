{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-10-INF-015";
    title = "Tailscale (Zero-Touch)";
    description = "Declarative VPN with autoconnect pattern and SOPS-nix secret integration.";
    layer = 10;
    nixpkgs.category = "services/networking";
    capabilities = [ "network/vpn" "security/tailscale" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };
in
{
  options.my.meta.tailscale = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for tailscale module";
  };


  config = lib.mkIf config.my.services.tailscale.enable {
    services.tailscale = { enable = true; openFirewall = false; useRoutingFeatures = "client"; extraUpFlags = [ "--ssh" "--accept-dns=true" "--accept-routes=true" ]; permitCertUid = config.services.caddy.user; };
    systemd.services.tailscale-autoconnect = {
      description = "Automatic Tailscale Login";
      after = [ "tailscaled.service" "network-online.target" ]; wants = [ "tailscaled.service" "network-online.target" ]; wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "tailscale-auth" "sleep 2; status=$(${pkgs.tailscale}/bin/tailscale status --json | ${pkgs.jq}/bin/jq -r .BackendState); if [ '$status' = 'NeedsLogin' ] || [ '$status' = 'Stopped' ]; then ${pkgs.tailscale}/bin/tailscale up --authkey='$(cat ${config.sops.secrets.tailscale_token.path})'; fi";
      };
    };
    systemd.services.tailscaled = { stopIfChanged = false; serviceConfig = { Restart = "always"; RestartSec = "2s"; OOMScoreAdjust = -1000; }; };
  };
}
