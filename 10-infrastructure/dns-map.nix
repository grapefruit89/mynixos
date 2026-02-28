{
  useNixSubdomain = true;
  dnsMapping = {
    jellyfin = "jellyfin.nix.m7c5.de";
    traefik = "traefik.nix.m7c5.de";
    sonarr = "sonarr.nix.m7c5.de";
    radarr = "radarr.nix.m7c5.de";
    prowlarr = "prowlarr.nix.m7c5.de";
    readarr = "readarr.nix.m7c5.de";
    vault = "vault.nix.m7c5.de";
    auth = "auth.nix.m7c5.de";
    miniflux = "miniflux.nix.m7c5.de";
    monica = "monica.nix.m7c5.de";
    audiobookshelf = "audiobookshelf.nix.m7c5.de";
    paperless = "paperless.nix.m7c5.de";
    n8n = "n8n.nix.m7c5.de";
    scrutiny = "scrutiny.nix.m7c5.de";
    filebrowser = "filebrowser.nix.m7c5.de";
    sabnzbd = "nix-sabnzbd.m7c5.de";
    dashboard = "nixhome.m7c5.de";
  };
  baseDomain = "m7c5.de";
}
