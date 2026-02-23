{ config, lib, pkgs, ... }:
let
  domain = "m7c5.de";
in
{
  # 1. Pocket ID Service konfigurieren
  services.pocket-id = {
    enable = false;
    dataDir = "/var/lib/pocket-id";
    settings = {
      # Die externe URL, unter der der Dienst erreichbar ist
      issuer = "https://nix-auth.${domain}";

      # Das Secret zum Signieren der Tokens, wird aus der sops-Datei gelesen
      secret = config.sops.secrets.pocket_id_secret.path;

      # Standard-Titel für die Login-Seite
      title = "m7c5 Login";

      # Ersten Admin-Benutzer festlegen (kann nach dem ersten Login geändert werden)
      # users = builtins.toJSON [
      #   {
      #     email = "moritzbaumeister@gmail.com";
      #     name = "Moritz";
      #     admin = true;
      #   }
      # ];
    };
  };

  # 2. Pocket ID über Traefik erreichbar machen
  services.traefik.dynamicConfigOptions.http = {
    routers.pocket-id = {
      rule = "Host(`nix-auth.${domain}`)";
      entryPoints = [ "websecure" ];
      "tls.certResolver" = "letsencrypt";
      # Die Middlewares für sichere Header anwenden
      middlewares = [ "secure-headers@file" ];
      service = "pocket-id";
    };
    services."pocket-id" = {
      loadBalancer.servers = [{
        # Pocket ID lauscht standardmäßig auf Port 3000
        url = "http://127.0.0.1:3000";
      }];
    };
  };
}
