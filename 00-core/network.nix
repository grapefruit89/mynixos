# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: Modernes Networking (systemd-networkd + Avahi / mDNS)

{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.networking.systemd-networkd;
  host = config.my.configs.identity.host;
in
{
  config = lib.mkIf cfg.enable {
    # ── NETWORKD ─────────────────────────────────────────────────────────────
    networking.useNetworkd = true;
    networking.useDHCP = false; # Wir nutzen DHCP pro Interface via networkd

    systemd.network = {
      enable = true;
      networks."10-lan" = {
        matchConfig.Name = "en*"; # Matcht Ethernet (enp... etc)
        networkConfig.DHCP = "yes";
        linkConfig.RequiredForOnline = "yes";
      };
    };

    # ── AVAHI (mDNS) ──────────────────────────────────────────────────────────
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };

    # ── RESOLVED ─────────────────────────────────────────────────────────────
    services.resolved.enable = true;

    # ── DISABLE NETWORKMANAGER ──────────────────────────────────────────────
    # NM kollidiert oft mit networkd
    networking.networkmanager.enable = lib.mkForce false;
  };
}
