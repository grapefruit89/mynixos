/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Vpn Live Config
 * TRACE-ID:     NIXH-INF-017
 * REQ-REF:      REQ-INF
 * LAYER:        20
 * STATUS:       Stable
 * INTEGRITY:    SHA256:10fa4c82df3b742a39c0bcaf461dd4d997be8bc811aca8de4e1075fa705dbc03
 */

{ lib, ... }:
{
  my.configs.vpn.privado = {
    publicKey = lib.mkForce "KgTUh3KLijVluDvNpzDCJJfrJ7EyLzYLmdHCksG4sRg=";
    endpoint = lib.mkForce "91.148.237.38:51820";
    address = lib.mkForce "100.64.3.155/32";
    dns = lib.mkForce ["198.18.0.1" "198.18.0.2"];
  };
}
