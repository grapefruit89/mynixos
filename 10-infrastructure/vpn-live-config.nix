/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        VPN Live Config (Runtime)
 * TRACE-ID:     NIXH-INF-014
 * PURPOSE:      Speicherort für zur Laufzeit eingespielte VPN-Parameter (wird von secret-ingest überschrieben).
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   []
 * LAYER:        10-infra
 * STATUS:       Experimental (Runtime Managed)
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
