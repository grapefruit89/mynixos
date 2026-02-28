{ config, pkgs, lib, ... }:
let
  # source-id: CFG.identity.domain
  domain = config.my.configs.identity.domain;
in
{
  # Simple local test endpoint, intentionally internal-only.
  virtualisation.oci-containers.containers.whoami = lib.mkIf (config.my.profiles.networking.reverseProxy == "traefik") {
    image = "traefik/whoami";
    extraOptions = [
      "--label=traefik.enable=true"
      "--label=traefik.http.routers.whoami.rule=Host(`nix-whoami.${domain}`)"
      "--label=traefik.http.routers.whoami.entrypoints=websecure"
      "--label=traefik.http.routers.whoami.middlewares=internal-only-chain@file"
      "--label=traefik.http.routers.whoami.tls.certresolver=letsencrypt"
      "--label=traefik.http.services.whoami.loadbalancer.server.port=80"
    ];
  };
}
