{ config, lib, pkgs, ... }:

let
  # Hier den Domainnamen eintragen
  domain = "m7c5.de";
in
{
  # ── TRAEFIK (Reverse Proxy) ────────────────────────────────────────────────
  # Leitet Anfragen an die richtigen Dienste weiter und kümmert sich um TLS.
  services.traefik = {
    enable = true;
    dataDir = "/var/lib/traefik";

    # Wir definieren einen Zertifikat-Resolver namens "letsencrypt"
    staticConfigOptions = {
      certificatesResolvers.letsencrypt = {
        acme = {
          email = "moritzbaumeister@gmail.com"; # E-Mail für Let's Encrypt-Benachrichtigungen
          # storage = "${config.services.traefik.dataDir}/acme.json";
          # dnsChallenge = {
          #   provider = "cloudflare";
          #   # Die Umgebungsvariable wird durch das sops-nix Modul gesetzt
          #   # Der Pfad zur Datei wird in sops.nix definiert
          #   environment.CLOUDFLARE_DNS_API_TOKEN_FILE = config.sops.secrets."traefik/cloudflare_token".path;
          # };
        };
      };
    };

    dynamicConfigOptions = {
      http.middlewares = {
        # Middleware für die Umleitung von HTTP zu HTTPS
        https-redirect.redirectscheme = {
          scheme = "https";
          permanent = true;
        };
        # Middleware für empfohlene Sicherheitseinstellungen
        secure-headers.headers = {
          sslRedirect = true;
          stsSeconds = 31536000;
          stsIncludeSubdomains = true;
          stsPreload = true;
          forceSTSHeader = true;
          browserXssFilter = true;
          contentTypeNosniff = true;
          frameDeny = true;
        };
      };

      # Definition der Entrypoints (web für HTTP, websecure für HTTPS)
      http.entryPoints = {
        web.address = ":80";
        # Leitet allen Traffic auf den websecure Entrypoint um
        web.http.redirections.entryPoint = {
          to = "websecure";
          scheme = "https";
        };
        websecure = {
          address = ":443";
          # Hier wird der "letsencrypt" Resolver für TLS aktiviert
          # http.tls.certResolver = "letsencrypt";
          # http.tls.domains = [{
          #   main = domain;
          #   sans = [ "*.${domain}" ]; # Wildcard-Zertifikat
          # }];
        };
      };
    };
  };

  # sops-nix Konfiguration für das Traefik-Geheimnis
  # sops.secrets."traefik/cloudflare_token" = {
  #   # Besitzer und Gruppe auf 'traefik' setzen, damit der Dienst die Datei lesen kann
  #   owner = config.services.traefik.user;
  #   group = config.services.traefik.group;
  # };
}
