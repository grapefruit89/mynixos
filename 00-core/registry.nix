{ lib, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-00-CORE-020";
    title = "Registry";
    description = "Master switchboard for all system services, hardware profiles, and architectural toggles.";
    layer = 00;
    nixpkgs.category = "system/settings";
    capabilities = [ "system/feature-flags" "architecture/modularity" "ssot/registry" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 3;
  };
in
{
  options.my.meta.registry = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for registry module";
  };

  options.my = {
    # ── HARDWARE & SYSTEM PROFILES ──────────────────────────────────────────
    profiles = {
      hardware.q958.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Fujitsu Esprimo Q958 profile."; };
      networking = {
        systemd-networkd.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Use systemd-networkd."; };
        vpn-confinement.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Use netns for VPN."; };
        reverseProxy = lib.mkOption { type = lib.types.enum [ "caddy" "none" ]; default = "caddy"; description = "Edge proxy selection."; };
      };
    };

    # ── CENTRAL SERVICE REGISTRY (A-Z) ──────────────────────────────────────
    services = {
      adguardhome.enable = lib.mkEnableOption "AdGuard Home (DNS Filter)";
      aiAgents.enable = lib.mkEnableOption "AI Agents (Ollama & Claude)";
      audiobookshelf.enable = lib.mkEnableOption "Audiobookshelf (Media)";
      backup.enable = lib.mkEnableOption "Restic Backup (Daily)";
      bootSafeguard.enable = lib.mkEnableOption "Boot Partition Protection";
      clamav.enable = lib.mkEnableOption "ClamAV Antivirus";
      cloudflaredTunnel.enable = lib.mkEnableOption "Cloudflare Tunnel (Ingress)";
      cockpit.enable = lib.mkEnableOption "Cockpit (Admin Web)";
      configMerger.enable = lib.mkEnableOption "Config Merger (User JSON)";
      ddnsUpdater.enable = lib.mkEnableOption "DDNS Updater";
      dnsAutomation.enable = lib.mkEnableOption "DNS Automation (Cloudflare)";
      fail2ban.enable = lib.mkEnableOption "Fail2ban (Security)";
      filebrowser.enable = lib.mkEnableOption "Filebrowser (Files)";
      homeAssistant.enable = lib.mkEnableOption "Home Assistant (IoT)";
      homepage.enable = lib.mkEnableOption "Homepage Dashboard";
      jellyfin.enable = lib.mkEnableOption "Jellyfin (Media)";
      jellyseerr.enable = lib.mkEnableOption "Jellyseerr (Requests)";
      karakeep.enable = lib.mkEnableOption "Karakeep (Bookmarks)";
      kernelSlim.enable = lib.mkEnableOption "Kernel Slim Optimization";
      lidarr.enable = lib.mkEnableOption "Lidarr (Music)";
      matrixConduit.enable = lib.mkEnableOption "Matrix Conduit (Chat)";
      miniflux.enable = lib.mkEnableOption "Miniflux (RSS)";
      monica.enable = lib.mkEnableOption "Monica (CRM)";
      n8n.enable = lib.mkEnableOption "n8n (Workflows)";
      netdata.enable = lib.mkEnableOption "Netdata (Monitoring)";
      olivetin.enable = lib.mkEnableOption "OliveTin (Control Panel)";
      paperless.enable = lib.mkEnableOption "Paperless-ngx (Docs)";
      pocketId.enable = lib.mkEnableOption "Pocket-ID (SSO)";
      postgresql.enable = lib.mkEnableOption "PostgreSQL (Database)";
      prowlarr.enable = lib.mkEnableOption "Prowlarr (Indexer)";
      radarr.enable = lib.mkEnableOption "Radarr (Movies)";
      readarr.enable = lib.mkEnableOption "Readarr (Books)";
      recyclarr.enable = lib.mkEnableOption "Recyclarr (Arr-Sync)";
      sabnzbd.enable = lib.mkEnableOption "SABnzbd (Usenet)";
      scrutiny.enable = lib.mkEnableOption "Scrutiny (HDD Health)";
      sonarr.enable = lib.mkEnableOption "Sonarr (TV)";
      sshRescue.enable = lib.mkEnableOption "SSH Recovery Window";
      storagePool.enable = lib.mkEnableOption "MergerFS Storage Pool";
      tailscale.enable = lib.mkEnableOption "Tailscale (VPN)";
      uptimeKuma.enable = lib.mkEnableOption "Uptime Kuma (Status)";
      valkey.enable = lib.mkEnableOption "Valkey (Redis Cache)";
      zigbeeStack.enable = lib.mkEnableOption "Zigbee Stack (MQTT/Z2M)";
    };
  };

  # ── DEFAULT ACTIVATION (Set your desired active state here) ───────────────
  config.my.services = {
    adguardhome.enable = lib.mkDefault true;
    aiAgents.enable = lib.mkDefault true;
    audiobookshelf.enable = lib.mkDefault true;
    backup.enable = lib.mkDefault true;
    bootSafeguard.enable = lib.mkDefault true;
    clamav.enable = lib.mkDefault true;
    cloudflaredTunnel.enable = lib.mkDefault true;
    cockpit.enable = lib.mkDefault true;
    configMerger.enable = lib.mkDefault true;
    ddnsUpdater.enable = lib.mkDefault true;
    dnsAutomation.enable = lib.mkDefault true;
    fail2ban.enable = lib.mkDefault true;
    filebrowser.enable = lib.mkDefault true;
    homeAssistant.enable = lib.mkDefault true;
    homepage.enable = lib.mkDefault true;
    jellyfin.enable = lib.mkDefault true;
    jellyseerr.enable = lib.mkDefault true;
    karakeep.enable = lib.mkDefault true;
    kernelSlim.enable = lib.mkDefault true;
    lidarr.enable = lib.mkDefault true;
    matrixConduit.enable = lib.mkDefault true;
    miniflux.enable = lib.mkDefault true;
    monica.enable = lib.mkDefault true;
    n8n.enable = lib.mkDefault true;
    netdata.enable = lib.mkDefault true;
    olivetin.enable = lib.mkDefault true;
    paperless.enable = lib.mkDefault true;
    pocketId.enable = lib.mkDefault true;
    postgresql.enable = lib.mkDefault true;
    prowlarr.enable = lib.mkDefault true;
    radarr.enable = lib.mkDefault true;
    readarr.enable = lib.mkDefault true;
    recyclarr.enable = lib.mkDefault true;
    sabnzbd.enable = lib.mkDefault true;
    scrutiny.enable = lib.mkDefault true;
    sonarr.enable = lib.mkDefault true;
    sshRescue.enable = lib.mkDefault true;
    storagePool.enable = lib.mkDefault true;
    tailscale.enable = lib.mkDefault true;
    uptimeKuma.enable = lib.mkDefault true;
    valkey.enable = lib.mkDefault true;
    zigbeeStack.enable = lib.mkDefault true;
  };
}
