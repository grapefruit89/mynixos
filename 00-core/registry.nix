/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-020
 *   title: "Registry"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-CORE]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
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












/**
 * ---
 * technical_integrity:
 *   checksum: sha256:c4d022dfed31ace3cc2343974298d9c647713531fa5427300214caac5eeb7cae
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
