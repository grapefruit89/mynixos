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
      description = "Aktiviert das Hardware-Profil für Fujitsu Q958.";
    };

    networking.systemd-networkd.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Nutzt systemd-networkd statt NetworkManager.";
    };

    services = {
      vpn-killswitch.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Aktiviert den NFTables VPN Killswitch.";
      };
      
      pocket-id.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Aktiviert den Pocket-ID Authentifizierungsdienst.";
      };

      storage-pool.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Aktiviert die MergerFS Speicher-Architektur.";
      };
    };
  };
}
