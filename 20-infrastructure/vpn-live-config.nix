{ lib, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-10-INF-019";
    title = "Vpn Live Config";
    description = "Dynamic runtime configuration for VPN credentials and endpoints.";
    layer = 10;
    nixpkgs.category = "data/networking";
    capabilities = [ "network/vpn-config" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 1;
  };
in
{
  options.my.meta.vpn_live_config = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for vpn-live-config module";
  };

  config = {
    my.configs.vpn.privado = {
      publicKey = lib.mkForce "KgTUh3KLijVluDvNpzDCJJfrJ7EyLzYLmdHCksG4sRg=";
      endpoint = lib.mkForce "91.148.237.38:51820";
      address = lib.mkForce "100.64.3.155/32";
      dns = lib.mkForce ["198.18.0.1" "198.18.0.2"];
    };
  };
}
