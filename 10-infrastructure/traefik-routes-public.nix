{ lib, ... }:
let
  serviceMap = import ../00-core/service-map.nix;
  u = serviceMap.upstreams;

  # Source -> drain mapping (single source of truth for public routing).
  # Key: router id, used to derive "<id>-service".
  routes = {
    agentzero = { rule = "Host(`agentzero.m7c5.de`)"; upstream = u.agentzero; };
    audiobookrequest = { rule = "Host(`audiobookrequest.m7c5.de`)"; upstream = u.audiobookrequest; };
    authelia = { rule = "Host(`auth.m7c5.de`)"; upstream = u.authelia; };
    bentopdf = { rule = "Host(`pdf.m7c5.de`) || Host(`bentopdf.m7c5.de`)"; upstream = u.bentopdf; };
    freshrss = { rule = "Host(`rss.m7c5.de`)"; upstream = u.freshrss; };
    "it-tools" = { rule = "Host(`tools.m7c5.de`)"; upstream = u."it-tools"; };
    jellysweep = { rule = "Host(`sweep.m7c5.de`)"; upstream = u.jellysweep; };
    lazylibrarian = { rule = "Host(`lazylibrarian.m7c5.de`)"; upstream = u.lazylibrarian; };
    linkding = { rule = "Host(`links.m7c5.de`)"; upstream = u.linkding; };
    listenarr = { rule = "Host(`listenarr.m7c5.de`)"; upstream = u.listenarr; };
    openclaw = { rule = "Host(`claw.m7c5.de`)"; upstream = u.openclaw; };
    openwebui = { rule = "Host(`openwebui.m7c5.de`)"; upstream = u.openwebui; };
    profilarr = { rule = "Host(`profilarr.m7c5.de`)"; upstream = u.profilarr; };
    radarr = { rule = "Host(`radarr.m7c5.de`)"; upstream = u.radarr; };
    readarr = { rule = "Host(`readarr.m7c5.de`)"; upstream = u.readarr; };
    readeck = { rule = "Host(`readeck.m7c5.de`) || Host(`read.m7c5.de`)"; upstream = u.readeck; };
    recommendarr = { rule = "Host(`recommendarr.m7c5.de`)"; upstream = u.recommendarr; };
    research = { rule = "Host(`research.m7c5.de`)"; upstream = u.research; };
    seerr = { rule = "Host(`seerr.m7c5.de`)"; upstream = u.seerr; };
    semaphore = { rule = "Host(`semaphore.m7c5.de`)"; upstream = u.semaphore; };
    sonarr = { rule = "Host(`sonarr.m7c5.de`)"; upstream = u.sonarr; };
  };

  mkRouter = name: cfg: {
    rule = cfg.rule;
    entryPoints = [ "websecure" ];
    middlewares = [ "secured-chain@file" ];
    service = "${name}-service";
    tls.certResolver = "letsencrypt";
  };
in
{
  services.traefik.dynamicConfigOptions.http = {
    # Public hosts (source) -> traefik services (drain handles).
    routers = lib.mapAttrs mkRouter routes;

    # Service handles (source) -> upstream URL (drain target).
    services =
      lib.mapAttrs'
        (name: cfg: lib.nameValuePair "${name}-service" { loadBalancer.servers = [{ url = cfg.upstream; }]; })
        routes;
  };
}
