# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: Zentrales Feature-Register (Toggles für Profile und Dienste)

{ lib, ... }:
{
  options.my.profiles = {
    hardware.q958.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Aktiviert das Hardware-Profil für Fujitsu Q958 (Intel GPU, Microcode).";
    };

    networking.systemd-networkd.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Nutzt systemd-networkd statt NetworkManager für DHCP + Avahi.";
    };

    services.vpn-killswitch.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Aktiviert den NFTables-basierten VPN Killswitch für die Download-Gruppe.";
    };
  };
}
