{ lib, ... }:
let
  nms = {
    id = "NIXH-00-CORE-020";
    title = "Registry";
    description = "Master switchboard for all system services.";
    layer = 00;
    nixpkgs.category = "system/settings";
    capabilities = [ "system/feature-flags" "architecture/modularity" "ssot/registry" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 3;
  };
in
{
  options.my.meta.registry = lib.mkOption { type = lib.types.attrs; default = nms; readOnly = true; };

  options.my = {
    profiles = {
      hardware.q958.enable = lib.mkOption { type = lib.types.bool; default = true; };
      networking = {
        systemd-networkd.enable = lib.mkOption { type = lib.types.bool; default = true; };
        vpn-confinement.enable = lib.mkOption { type = lib.types.bool; default = true; };
        reverseProxy = lib.mkOption { type = lib.types.enum [ "caddy" "none" ]; default = "caddy"; };
      };
    };

    services = {
      adguardhome.enable = lib.mkEnableOption "AdGuard Home";
      aiAgents.enable = lib.mkEnableOption "AI Agents";
      audiobookshelf.enable = lib.mkEnableOption "Audiobookshelf";
      backup.enable = lib.mkEnableOption "Restic Backup";
      bootSafeguard.enable = lib.mkEnableOption "Boot Partition Protection";
      clamav.enable = lib.mkEnableOption "ClamAV";
      cloudflaredTunnel.enable = lib.mkEnableOption "Cloudflare Tunnel";
      cockpit.enable = lib.mkEnableOption "Cockpit";
      configMerger.enable = lib.mkEnableOption "Config Merger";
      ddnsUpdater.enable = lib.mkEnableOption "DDNS Updater";
      dnsAutomation.enable = lib.mkEnableOption "DNS Automation";
      fail2ban.enable = lib.mkEnableOption "Fail2ban";
      filebrowser.enable = lib.mkEnableOption "Filebrowser";
      homeAssistant.enable = lib.mkEnableOption "Home Assistant";
      homepage.enable = lib.mkEnableOption "Homepage Dashboard";
      jellyfin.enable = lib.mkEnableOption "Jellyfin";
      jellyseerr.enable = lib.mkEnableOption "Jellyseerr";
      karakeep.enable = lib.mkEnableOption "Karakeep";
      kernelSlim.enable = lib.mkEnableOption "Kernel Slim";
      lidarr.enable = lib.mkEnableOption "Lidarr";
      linkding.enable = lib.mkEnableOption "Linkding";
      matrixConduit.enable = lib.mkEnableOption "Matrix Conduit";
      mediaStack.enable = lib.mkEnableOption "Media Stack Canonical Layout";
      miniflux.enable = lib.mkEnableOption "Miniflux";
      monica.enable = lib.mkEnableOption "Monica";
      n8n.enable = lib.mkEnableOption "n8n";
      netdata.enable = lib.mkEnableOption "Netdata";
      olivetin.enable = lib.mkEnableOption "OliveTin";
      paperless.enable = lib.mkEnableOption "Paperless-ngx";
      pocketId.enable = lib.mkEnableOption "Pocket-ID";
      postgresql.enable = lib.mkEnableOption "PostgreSQL";
      prowlarr.enable = lib.mkEnableOption "Prowlarr";
      radarr.enable = lib.mkEnableOption "Radarr";
      readarr.enable = lib.mkEnableOption "Readarr";
      readeck.enable = lib.mkEnableOption "Readeck";
      recyclarr.enable = lib.mkEnableOption "Recyclarr";
      sabnzbd.enable = lib.mkEnableOption "SABnzbd";
      scrutiny.enable = lib.mkEnableOption "Scrutiny";
      secretIngest.enable = lib.mkEnableOption "Secret Ingest Agent";
      semaphore.enable = lib.mkEnableOption "Semaphore";
      sonarr.enable = lib.mkEnableOption "Sonarr";
      sshRescue.enable = lib.mkEnableOption "SSH Recovery Window";
      storagePool.enable = lib.mkEnableOption "MergerFS Storage Pool";
      tailscale.enable = lib.mkEnableOption "Tailscale";
      uptimeKuma.enable = lib.mkEnableOption "Uptime Kuma";
      valkey.enable = lib.mkEnableOption "Valkey";
      vaultwarden.enable = lib.mkEnableOption "Vaultwarden";
      zigbeeStack.enable = lib.mkEnableOption "Zigbee Stack";
    };
  };

  config.my.services = {
    adguardhome.enable = lib.mkDefault true; aiAgents.enable = lib.mkDefault true; audiobookshelf.enable = lib.mkDefault true;
    backup.enable = lib.mkDefault true; bootSafeguard.enable = lib.mkDefault true; clamav.enable = lib.mkDefault true;
    cloudflaredTunnel.enable = lib.mkDefault true; cockpit.enable = lib.mkDefault true; configMerger.enable = lib.mkDefault true;
    ddnsUpdater.enable = lib.mkDefault true; dnsAutomation.enable = lib.mkDefault true; fail2ban.enable = lib.mkDefault true;
    filebrowser.enable = lib.mkDefault true; homeAssistant.enable = lib.mkDefault true; homepage.enable = lib.mkDefault true;
    jellyfin.enable = lib.mkDefault true; jellyseerr.enable = lib.mkDefault true; karakeep.enable = lib.mkDefault true;
    kernelSlim.enable = lib.mkDefault true; lidarr.enable = lib.mkDefault true; linkding.enable = lib.mkDefault true;
    matrixConduit.enable = lib.mkDefault true; mediaStack.enable = lib.mkDefault true; miniflux.enable = lib.mkDefault true;
    monica.enable = lib.mkDefault true; n8n.enable = lib.mkDefault true; netdata.enable = lib.mkDefault true;
    olivetin.enable = lib.mkDefault true; paperless.enable = lib.mkDefault true; pocketId.enable = lib.mkDefault true;
    postgresql.enable = lib.mkDefault true; prowlarr.enable = lib.mkDefault true; radarr.enable = lib.mkDefault true;
    readarr.enable = lib.mkDefault true; readeck.enable = lib.mkDefault true; recyclarr.enable = lib.mkDefault true;
    sabnzbd.enable = lib.mkDefault true; scrutiny.enable = lib.mkDefault true; secretIngest.enable = lib.mkDefault true;
    semaphore.enable = lib.mkDefault true; sonarr.enable = lib.mkDefault true; sshRescue.enable = lib.mkDefault true;
    storagePool.enable = lib.mkDefault true; tailscale.enable = lib.mkDefault true; uptimeKuma.enable = lib.mkDefault true;
    valkey.enable = lib.mkDefault true; vaultwarden.enable = lib.mkDefault true; zigbeeStack.enable = lib.mkDefault true;
  };
}
