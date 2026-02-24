{
  # Unified local service port map.
  # New local services should continue at 20006+.
  ports = {
    homepage = 20000;
    vaultwarden = 20001;
    n8n = 20002;
    sabnzbd = 20003;
    audiobookshelf = 20004;

    # Jellyfin is kept on default unless managed differently.
    jellyfin = 8096;
  };

  # Traefik upstream targets.
  upstreams = {
    agentzero = "http://agentzero:50080";
    audiobookrequest = "http://audiobookrequest:8000";
    authelia = "http://Authelia:9091";
    bentopdf = "http://bentopdf:8080";
    freshrss = "http://freshrss:80";
    it-tools = "http://it-tools:80";
    jellysweep = "http://Jellysweep:3003";
    lazylibrarian = "http://lazylibrarian:5299";
    linkding = "http://linkding:9090";
    listenarr = "http://listenarr:5000";
    openclaw = "http://172.18.0.1:13379";
    openwebui = "http://openwebui:1981";
    profilarr = "http://Profilarr:6868";
    radarr = "http://radarr:7878";
    readarr = "http://readarr-fork:8787";
    readeck = "http://readeck:8000";
    recommendarr = "http://Recommendarr:3060";
    research = "http://LocalDeepResearch:5000";
    seerr = "http://seerr:5055";
    semaphore = "http://semaphore:3000";
    sonarr = "http://sonarr:8989";
  };
}
