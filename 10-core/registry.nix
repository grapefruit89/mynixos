/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Registry
 * TRACE-ID:     NIXH-CORE-002
 * REQ-REF:      REQ-CORE
 * LAYER:        10
 * STATUS:       Stable
 * INTEGRITY:    SHA256:0ed3a51243a71eb1c9468f760edc46bad608f5be07bc66a18e3f1aea955d4716
 */

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
        type = lib.types.enum [ "caddy" "none" ];
        default = "caddy";
        description = "Aktiver Reverse-Proxy. Muss Port 443 binden.";
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
