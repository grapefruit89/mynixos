# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: ports Modul

{ lib, ... }:
{
  options.my.ports = lib.mkOption {
    type = lib.types.attrsOf lib.types.port;
    default = { };
    description = "Central port registry. Each service port is defined once.";
  };

  config.my.ports = {
    ssh = 53844;

    # HTTPS-only edge. Port 80 is intentionally not exposed.
    traefikHttps = 443;
    adguard = 3000;
    netdata = 19999;
    uptimeKuma = 3001;
    homepage = 8082;
    ddnsUpdater = 8001;
    pocketId = 3000;

    jellyfin = 8096;
    audiobookshelf = 8000;
    sonarr = 8989;
    radarr = 7878;
    readarr = 8787;
    prowlarr = 9696;
    sabnzbd = 8080;
    jellyseerr = 5055;

    vaultwarden = 2002;
    miniflux = 2016;
    n8n = 2017;
    paperless = 28981;
    scrutiny = 2020;
    readeck = 2007;
    monica = 2031;
  };
}
