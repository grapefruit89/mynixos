{ config, lib, pkgs, inputs, ... }:
let
  domain = "m7c5.de";
in
{
  # 1. Das VPN-Confinement-Modul von Maroka-chan importieren
  # imports = [
  #   inputs.vpn-confinement.nixosModules.default
  # ];

  # 2. Den VPN-Namespace mit der Konfiguration aus dem sops-Geheimnis definieren
  # Temporär deaktiviert, da das Geheimnis `privado_wg_conf` fehlt.
  # vpnNamespaces.privado = {
  #   wireguardConf.source = ../../privado_wg_temp.conf; # TODO: In sops verschieben
  #   
  #   # Erlaube dem eingesperrten Dienst, mit dem Host-System zu kommunizieren
  #   # (z.B. für Traefik, um den Dienst zu erreichen)
  #   allowedIps = [ "127.0.0.1/32" ];
  #
  #   # Port-Mapping, damit Traefik den SABnzbd-Dienst auf Port 8080 erreichen kann
  #   portMappings = [
  #     { local = 8080; remote = 8080; }
  #   ];
  # };

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
        # SABnzbd kann den API-Key aus einer Datei lesen.
        # Wir übergeben hier den Pfad zur von sops-nix erstellten Datei.
        api_key_file = config.sops.secrets.sabnzbd_api_key.path;
      };
    };
  };

  # 4. SABnzbd in den VPN-Namespace "einsperren"
  # Temporär deaktiviert, da das Geheimnis `privado_wg_conf` fehlt.
  # systemd.services.sabnzbd.vpnConfinement = {
  #   enable = true;
  #   vpnNamespace = "privado";
  # };

  # 5. SABnzbd über Traefik erreichbar machen und mit Pocket ID absichern
  services.traefik.dynamicConfigOptions.http = {
    routers.sabnzbd = {
      rule = "Host(`nix-sabnzbd.${domain}`)";
      entryPoints = [ "websecure" ];
      "tls.certResolver" = "letsencrypt";
      middlewares = [
        "pocket-id-auth@file"
        "secure-headers@file"
      ];
      service = "sabnzbd";
    };
    services.sabnzbd = {
      loadBalancer.servers = [{
        url = "http://127.0.0.1:8080";
      }];
    };
  };
}
