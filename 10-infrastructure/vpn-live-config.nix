{ lib, ... }:
{
  my.configs.vpn.privado = {
    publicKey = lib.mkForce "KgTUh3KLijVluDvNpzDCJJfrJ7EyLzYLmdHCksG4sRg=";
    endpoint = lib.mkForce "91.148.237.38:51820";
    address = lib.mkForce "100.64.3.155/32";
    dns = lib.mkForce ["198.18.0.1" "198.18.0.2"];
  };
}
