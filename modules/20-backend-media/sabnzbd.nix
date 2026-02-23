{ config, lib, pkgs, ... }:
let
  domain = "m7c5.de";
  netnsPath = "/run/netns/wg"; # Pfad für den VPN-Netzwerknamensraum
in
{
  # 3. SABnzbd-Dienst konfigurieren
  services.sabnzbd = {
    enable = true;
  };

  # 4. SABnzbd in den VPN-Namespace "einsperren" (Native NixOS-Lösung)
  # HINWEIS: Der Netzwerknamensraum selbst (z.B. wg-interface in den netns verschieben, Routing)
  # muss noch separat konfiguriert werden. Dies hier weist SABnzbd nur an,
  # diesen Namespace zu nutzen.
  # systemd.services.sabnzbd.serviceConfig.NetworkNamespacePath = netnsPath;

  # # Sicherstellen, dass das Verzeichnis für Netzwerknamensräume existiert
  # systemd.tmpfiles.rules = [
  #   "d ${netnsPath} 0755 root root -"
  # ];

  # 5. SABnzbd über Traefik erreichbar machen und mit Pocket ID absichern
  services.traefik.dynamicConfigOptions.http = {
    routers.sabnzbd = {
      rule = "Host(`nix-sabnzbd.${domain}`)";
      entryPoints = [ "websecure" ];
      tls.certResolver = "letsencrypt";
      middlewares = [
        # "pocket-id-auth@file" # Assuming this middleware is defined elsewhere
        "secure-headers@file" # Assuming this middleware is defined elsewhere
      ];
      service = "sabnzbd";
    };
    services.sabnzbd.loadBalancer.servers = [{
      url = "http://127.0.0.1:8080";
    }];
  };
}
