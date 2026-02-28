/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Traefik Internal Routes
 * TRACE-ID:     NIXH-INF-004
 * PURPOSE:      Definition interner Test-Routen und WhoAmI-Container für Traefik.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [10-infra/traefik-core.nix]
 * LAYER:        10-infra
 * STATUS:       Stable
 */

{ config, pkgs, lib, ... }:
let
  domain = config.my.configs.identity.domain;
in
{
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
