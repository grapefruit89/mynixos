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

    networking = {
      systemd-networkd.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Nutzt systemd-networkd statt NetworkManager.";
      };
      
      vpn-confinement.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Nutzt Netzwerk-Namespaces für maximale VPN-Sicherheit.";
      };

      reverseProxy = lib.mkOption {
        type = lib.types.enum [ "caddy" "traefik" "none" ];
        default = "caddy";
        description = "Aktiver Reverse-Proxy. Nur EINER darf Port 443 binden.";
      };
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

      scrutiny.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Aktiviert das Scrutiny Dashboard.";
      };

      cockpit.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Aktiviert das Cockpit Admin-Dashboard.";
      };

      filebrowser.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Aktiviert den FileBrowser.";
      };
    };
  };
}
