{ config, lib, pkgs, inputs, ... }:
let
  domain = "m7c5.de";
in
{
  # 3. SABnzbd-Dienst konfigurieren
  services.sabnzbd = {
    enable = true;
    stateDir = "/var/lib/sabnzbd"; # Appdata auf der NVMe
    user = "sabnzbd";
    group = "sabnzbd";
    settings = {
      misc = {
        host = "127.0.0.1"; # Nur lokal lauschen
        port = 8080;
        # WICHTIG: Den SABnzbd API-Key musst du nach dem ersten Start manuell über die Web-Oberfläche setzen.
        # Wenn du den Key in eine Datei auslagern möchtest, kannst du hier den Pfad angeben:
        # api_key_file = "/path/to/your/sabnzbd_api_key_file";
      };
    };
  };

  # 4. SABnzbd in den VPN-Namespace "einsperren"
  systemd.services.sabnzbd.vpnConfinement = {
    enable = true;
    vpnNamespace = "privado"; # Use the 'privado' namespace defined in wireguard-vpn.nix
  };

  # 5. SABnzbd über Traefik erreichbar machen und mit Pocket ID absichern
  services.traefik.dynamicConfigOptions.http = {
    routers.sabnzbd = {
      rule = "Host(`nix-sabnzbd.${domain}`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [
        "pocket-id-auth@file" # Assuming this middleware is defined elsewhere
        "secure-headers@file" # Assuming this middleware is defined elsewhere
      ];
      service = "sabnzbd";
    };
    services.sabnzbd.loadBalancer.servers = [{
      url = "http://127.0.0.1:8080";
    }];
  };
}
