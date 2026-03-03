# 🛰️ NixHome SPEC REGISTRY (SSoT)
Dieses Dokument ist die zentrale Master-Source für Traceability und Inspirationen.

## 🧬 Traceability Matrix

> [!warning] SRE Audit Befunde (Stand 2026-03-02)
> *   **CRITICAL BUG:** `PrivateDevices = true` in `jellyfin.nix` bricht das Hardware-Transcoding. (BEHOBEN in v4.0)
> *   **ARCHITECTURAL GAP:** Fehlendes `mkEnableOption` Pattern. (BEHOBEN in v4.0 via registry.nix)
> *   **DEPRECATION:** Deprecated Intel-Treiber entfernt. (BEHOBEN in v4.0)

| ID | Nix-Modul | Dokumentation (MetaBib) | Inspiration / Vorbild |
|---|---|---|---|
| NIXH-00-COR-001 | `00-core/.secrets-local.nix` | [.secrets-local.nix](../../home/moritz/documents/MetaBibliothek/00-core/.secrets-local.md) | [Link unten](#NIXH-00-COR-001) |
| NIXH-00-COR-002 | `00-core/ai-tools.nix` | [ai-tools.nix](../../home/moritz/documents/MetaBibliothek/00-core/ai-tools.md) | [Link unten](#NIXH-00-COR-002) |
| NIXH-00-COR-003 | `00-core/auto-locale.nix` | [auto-locale.nix](../../home/moritz/documents/MetaBibliothek/00-core/auto-locale.md) | [Link unten](#NIXH-00-COR-003) |
| NIXH-00-COR-004 | `00-core/backup.nix` | [backup.nix](../../home/moritz/documents/MetaBibliothek/00-core/backup.md) | [Link unten](#NIXH-00-COR-004) |
| NIXH-00-COR-005 | `00-core/boot-safeguard.nix` | [boot-safeguard.nix](../../home/moritz/documents/MetaBibliothek/00-core/boot-safeguard.md) | [Link unten](#NIXH-00-COR-005) |
| NIXH-00-COR-006 | `00-core/central-configs-plan.nix` | [central-configs-plan.nix](../../home/moritz/documents/MetaBibliothek/00-core/central-configs-plan.md) | [Link unten](#NIXH-00-COR-006) |
| NIXH-00-COR-007 | `00-core/config-merger.nix` | [config-merger.nix](../../home/moritz/documents/MetaBibliothek/00-core/config-merger.md) | [Link unten](#NIXH-00-COR-007) |
| NIXH-00-COR-008 | `00-core/configs.nix` | [configs.nix](../../home/moritz/documents/MetaBibliothek/00-core/configs.md) | [Link unten](#NIXH-00-COR-008) |
| NIXH-00-COR-009 | `00-core/defaults.nix` | [defaults.nix](../../home/moritz/documents/MetaBibliothek/00-core/defaults.md) | [Link unten](#NIXH-00-COR-009) |
| NIXH-00-COR-010 | `00-core/fail2ban.nix` | [fail2ban.nix](../../home/moritz/documents/MetaBibliothek/00-core/fail2ban.md) | [Link unten](#NIXH-00-COR-010) |
| NIXH-00-COR-011 | `00-core/firewall.nix` | [firewall.nix](../../home/moritz/documents/MetaBibliothek/00-core/firewall.md) | [Link unten](#NIXH-00-COR-011) |
| NIXH-00-COR-012 | `00-core/hardware-configuration.nix` | [hardware-configuration.nix](../../home/moritz/documents/MetaBibliothek/00-core/hardware-configuration.md) | [Link unten](#NIXH-00-COR-012) |
| NIXH-00-COR-013 | `00-core/home-manager.nix` | [home-manager.nix](../../home/moritz/documents/MetaBibliothek/00-core/home-manager.md) | [Link unten](#NIXH-00-COR-013) |
| NIXH-00-COR-014 | `00-core/host-q958-hardware-configuration.nix` | [host-q958-hardware-configuration.nix](../../home/moritz/documents/MetaBibliothek/00-core/host-q958-hardware-configuration.md) | [Link unten](#NIXH-00-COR-014) |
| NIXH-00-COR-015 | `00-core/host-q958-hardware-profile.nix` | [host-q958-hardware-profile.nix](../../home/moritz/documents/MetaBibliothek/00-core/host-q958-hardware-profile.md) | [Link unten](#NIXH-00-COR-015) |
| NIXH-00-COR-016 | `00-core/host.nix` | [host.nix](../../home/moritz/documents/MetaBibliothek/00-core/host.md) | [Link unten](#NIXH-00-COR-016) |
| NIXH-00-COR-017 | `00-core/kernel-slim.nix` | [kernel-slim.nix](../../home/moritz/documents/MetaBibliothek/00-core/kernel-slim.md) | [Link unten](#NIXH-00-COR-017) |
| NIXH-00-COR-018 | `00-core/lib-helpers-meta.nix` | [lib-helpers-meta.nix](../../home/moritz/documents/MetaBibliothek/00-core/lib-helpers-meta.md) | [Link unten](#NIXH-00-COR-018) |
| NIXH-00-COR-019 | `00-core/lib-helpers.nix` | [lib-helpers.nix](../../home/moritz/documents/MetaBibliothek/00-core/lib-helpers.md) | [Link unten](#NIXH-00-COR-019) |
| NIXH-00-COR-020 | `00-core/locale.nix` | [locale.nix](../../home/moritz/documents/MetaBibliothek/00-core/locale.md) | [Link unten](#NIXH-00-COR-020) |
| NIXH-00-COR-021 | `00-core/logging.nix` | [logging.nix](../../home/moritz/documents/MetaBibliothek/00-core/logging.md) | [Link unten](#NIXH-00-COR-021) |
| NIXH-00-COR-022 | `00-core/motd.nix` | [motd.nix](../../home/moritz/documents/MetaBibliothek/00-core/motd.md) | [Link unten](#NIXH-00-COR-022) |
| NIXH-00-COR-023 | `00-core/network.nix` | [network.nix](../../home/moritz/documents/MetaBibliothek/00-core/network.md) | [Link unten](#NIXH-00-COR-023) |
| NIXH-00-COR-024 | `00-core/nix-tuning.nix` | [nix-tuning.nix](../../home/moritz/documents/MetaBibliothek/00-core/nix-tuning.md) | [Link unten](#NIXH-00-COR-024) |
| NIXH-00-COR-025 | `00-core/ports.nix` | [ports.nix](../../home/moritz/documents/MetaBibliothek/00-core/ports.md) | [Link unten](#NIXH-00-COR-025) |
| NIXH-00-COR-026 | `00-core/principles.nix` | [principles.nix](../../home/moritz/documents/MetaBibliothek/00-core/principles.md) | [Link unten](#NIXH-00-COR-026) |
| NIXH-00-COR-027 | `00-core/registry.nix` | [registry.nix](../../home/moritz/documents/MetaBibliothek/00-core/registry.md) | [Link unten](#NIXH-00-COR-027) |
| NIXH-00-COR-028 | `00-core/secrets.nix` | [secrets.nix](../../home/moritz/documents/MetaBibliothek/00-core/secrets.md) | [Link unten](#NIXH-00-COR-028) |
| NIXH-00-COR-029 | `00-core/shell-premium.nix` | [shell-premium.nix](../../home/moritz/documents/MetaBibliothek/00-core/shell-premium.md) | [Link unten](#NIXH-00-COR-029) |
| NIXH-00-COR-030 | `00-core/shell.nix` | [shell.nix](../../home/moritz/documents/MetaBibliothek/00-core/shell.md) | [Link unten](#NIXH-00-COR-030) |
| NIXH-00-COR-031 | `00-core/ssh-rescue.nix` | [ssh-rescue.nix](../../home/moritz/documents/MetaBibliothek/00-core/ssh-rescue.md) | [Link unten](#NIXH-00-COR-031) |
| NIXH-00-COR-032 | `00-core/ssh.nix` | [ssh.nix](../../home/moritz/documents/MetaBibliothek/00-core/ssh.md) | [Link unten](#NIXH-00-COR-032) |
| NIXH-00-COR-033 | `00-core/symbiosis.nix` | [symbiosis.nix](../../home/moritz/documents/MetaBibliothek/00-core/symbiosis.md) | [Link unten](#NIXH-00-COR-033) |
| NIXH-00-COR-034 | `00-core/system-stability.nix` | [system-stability.nix](../../home/moritz/documents/MetaBibliothek/00-core/system-stability.md) | [Link unten](#NIXH-00-COR-034) |
| NIXH-00-COR-035 | `00-core/system.nix` | [system.nix](../../home/moritz/documents/MetaBibliothek/00-core/system.md) | [Link unten](#NIXH-00-COR-035) |
| NIXH-00-COR-036 | `00-core/tty-info.nix` | [tty-info.nix](../../home/moritz/documents/MetaBibliothek/00-core/tty-info.md) | [Link unten](#NIXH-00-COR-036) |
| NIXH-00-COR-037 | `00-core/user-moritz-home.nix` | [user-moritz-home.nix](../../home/moritz/documents/MetaBibliothek/00-core/user-moritz-home.md) | [Link unten](#NIXH-00-COR-037) |
| NIXH-00-COR-038 | `00-core/user-preferences.nix` | [user-preferences.nix](../../home/moritz/documents/MetaBibliothek/00-core/user-preferences.md) | [Link unten](#NIXH-00-COR-038) |
| NIXH-00-COR-039 | `00-core/users.nix` | [users.nix](../../home/moritz/documents/MetaBibliothek/00-core/users.md) | [Link unten](#NIXH-00-COR-039) |
| NIXH-00-COR-040 | `00-core/zram-swap.nix` | [zram-swap.nix](../../home/moritz/documents/MetaBibliothek/00-core/zram-swap.md) | [Link unten](#NIXH-00-COR-040) |
| NIXH-10-GTW-001 | `10-gateway/adguardhome.nix` | [adguardhome.nix](../../home/moritz/documents/MetaBibliothek/10-gateway/adguardhome.md) | [Link unten](#NIXH-10-GTW-001) |
| NIXH-10-GTW-002 | `10-gateway/caddy.nix` | [caddy.nix](../../home/moritz/documents/MetaBibliothek/10-gateway/caddy.md) | [Link unten](#NIXH-10-GTW-002) |
| NIXH-10-GTW-003 | `10-gateway/cloudflared-tunnel.nix` | [cloudflared-tunnel.nix](../../home/moritz/documents/MetaBibliothek/10-gateway/cloudflared-tunnel.md) | [Link unten](#NIXH-10-GTW-003) |
| NIXH-10-GTW-004 | `10-gateway/ddns-updater.nix` | [ddns-updater.nix](../../home/moritz/documents/MetaBibliothek/10-gateway/ddns-updater.md) | [Link unten](#NIXH-10-GTW-004) |
| NIXH-10-GTW-005 | `10-gateway/dns-automation.nix` | [dns-automation.nix](../../home/moritz/documents/MetaBibliothek/10-gateway/dns-automation.md) | [Link unten](#NIXH-10-GTW-005) |
| NIXH-10-GTW-006 | `10-gateway/dns-map.nix` | [dns-map.nix](../../home/moritz/documents/MetaBibliothek/10-gateway/dns-map.md) | [Link unten](#NIXH-10-GTW-006) |
| NIXH-10-GTW-007 | `10-gateway/homepage.nix` | [homepage.nix](../../home/moritz/documents/MetaBibliothek/10-gateway/homepage.md) | [Link unten](#NIXH-10-GTW-007) |
| NIXH-10-GTW-008 | `10-gateway/landing-zone-ui.nix` | [landing-zone-ui.nix](../../home/moritz/documents/MetaBibliothek/10-gateway/landing-zone-ui.md) | [Link unten](#NIXH-10-GTW-008) |
| NIXH-10-GTW-009 | `10-gateway/pocket-id.nix` | [pocket-id.nix](../../home/moritz/documents/MetaBibliothek/10-gateway/pocket-id.md) | [Link unten](#NIXH-10-GTW-009) |
| NIXH-10-GTW-010 | `10-gateway/sso.nix` | [sso.nix](../../home/moritz/documents/MetaBibliothek/10-gateway/sso.md) | [Link unten](#NIXH-10-GTW-010) |
| NIXH-10-GTW-011 | `10-gateway/tailscale.nix` | [tailscale.nix](../../home/moritz/documents/MetaBibliothek/10-gateway/tailscale.md) | [Link unten](#NIXH-10-GTW-011) |
| NIXH-20-INF-001 | `20-infrastructure/clamav.nix` | [clamav.nix](../../home/moritz/documents/MetaBibliothek/20-infrastructure/clamav.md) | [Link unten](#NIXH-20-INF-001) |
| NIXH-20-INF-002 | `20-infrastructure/postgresql.nix` | [postgresql.nix](../../home/moritz/documents/MetaBibliothek/20-infrastructure/postgresql.md) | [Link unten](#NIXH-20-INF-002) |
| NIXH-20-INF-003 | `20-infrastructure/secret-ingest.nix` | [secret-ingest.nix](../../home/moritz/documents/MetaBibliothek/20-infrastructure/secret-ingest.md) | [Link unten](#NIXH-20-INF-003) |
| NIXH-20-INF-004 | `20-infrastructure/service-app-zigbee-stack.nix` | [service-app-zigbee-stack.nix](../../home/moritz/documents/MetaBibliothek/20-infrastructure/service-app-zigbee-stack.md) | [Link unten](#NIXH-20-INF-004) |
| NIXH-20-INF-005 | `20-infrastructure/storage.nix` | [storage.nix](../../home/moritz/documents/MetaBibliothek/20-infrastructure/storage.md) | [Link unten](#NIXH-20-INF-005) |
| NIXH-20-INF-006 | `20-infrastructure/valkey.nix` | [valkey.nix](../../home/moritz/documents/MetaBibliothek/20-infrastructure/valkey.md) | [Link unten](#NIXH-20-INF-006) |
| NIXH-20-INF-007 | `20-infrastructure/vpn-confinement.nix` | [vpn-confinement.nix](../../home/moritz/documents/MetaBibliothek/20-infrastructure/vpn-confinement.md) | [Link unten](#NIXH-20-INF-007) |
| NIXH-20-INF-008 | `20-infrastructure/vpn-live-config.nix` | [vpn-live-config.nix](../../home/moritz/documents/MetaBibliothek/20-infrastructure/vpn-live-config.md) | [Link unten](#NIXH-20-INF-008) |
| NIXH-30-AUT-001 | `30-automation/automation.nix` | [automation.nix](../../home/moritz/documents/MetaBibliothek/30-automation/automation.md) | [Link unten](#NIXH-30-AUT-001) |
| NIXH-30-AUT-002 | `30-automation/service-app-ai-agents.nix` | [service-app-ai-agents.nix](../../home/moritz/documents/MetaBibliothek/30-automation/service-app-ai-agents.md) | [Link unten](#NIXH-30-AUT-002) |
| NIXH-30-AUT-003 | `30-automation/service-app-home-assistant.nix` | [service-app-home-assistant.nix](../../home/moritz/documents/MetaBibliothek/30-automation/service-app-home-assistant.md) | [Link unten](#NIXH-30-AUT-003) |
| NIXH-30-AUT-004 | `30-automation/service-app-n8n.nix` | [service-app-n8n.nix](../../home/moritz/documents/MetaBibliothek/30-automation/service-app-n8n.md) | [Link unten](#NIXH-30-AUT-004) |
| NIXH-30-AUT-005 | `30-automation/service-app-olivetin.nix` | [service-app-olivetin.nix](../../home/moritz/documents/MetaBibliothek/30-automation/service-app-olivetin.md) | [Link unten](#NIXH-30-AUT-005) |
| NIXH-30-AUT-006 | `30-automation/service-app-semaphore.nix` | [service-app-semaphore.nix](../../home/moritz/documents/MetaBibliothek/30-automation/service-app-semaphore.md) | [Link unten](#NIXH-30-AUT-006) |
| NIXH-40-MED-001 | `40-media/media-stack.nix` | [media-stack.nix](../../home/moritz/documents/MetaBibliothek/40-media/media-stack.md) | [Link unten](#NIXH-40-MED-001) |
| NIXH-40-MED-002 | `40-media/service-app-audiobookshelf.nix` | [service-app-audiobookshelf.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-app-audiobookshelf.md) | [Link unten](#NIXH-40-MED-002) |
| NIXH-40-MED-003 | `40-media/service-media-_lib.nix` | [service-media-_lib.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-_lib.md) | [Link unten](#NIXH-40-MED-003) |
| NIXH-40-MED-004 | `40-media/service-media-_servarr-factory.nix` | [service-media-_servarr-factory.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-_servarr-factory.md) | [Link unten](#NIXH-40-MED-004) |
| NIXH-40-MED-005 | `40-media/service-media-arr-wire.nix` | [service-media-arr-wire.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-arr-wire.md) | [Link unten](#NIXH-40-MED-005) |
| NIXH-40-MED-006 | `40-media/service-media-default.nix` | [service-media-default.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-default.md) | [Link unten](#NIXH-40-MED-006) |
| NIXH-40-MED-007 | `40-media/service-media-jellyfin.nix` | [service-media-jellyfin.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-jellyfin.md) | [Link unten](#NIXH-40-MED-007) |
| NIXH-40-MED-008 | `40-media/service-media-jellyseerr.nix` | [service-media-jellyseerr.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-jellyseerr.md) | [Link unten](#NIXH-40-MED-008) |
| NIXH-40-MED-009 | `40-media/service-media-lidarr.nix` | [service-media-lidarr.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-lidarr.md) | [Link unten](#NIXH-40-MED-009) |
| NIXH-40-MED-010 | `40-media/service-media-media-stack.nix` | [service-media-media-stack.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-media-stack.md) | [Link unten](#NIXH-40-MED-010) |
| NIXH-40-MED-011 | `40-media/service-media-prowlarr.nix` | [service-media-prowlarr.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-prowlarr.md) | [Link unten](#NIXH-40-MED-011) |
| NIXH-40-MED-012 | `40-media/service-media-radarr.nix` | [service-media-radarr.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-radarr.md) | [Link unten](#NIXH-40-MED-012) |
| NIXH-40-MED-013 | `40-media/service-media-readarr.nix` | [service-media-readarr.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-readarr.md) | [Link unten](#NIXH-40-MED-013) |
| NIXH-40-MED-014 | `40-media/service-media-recyclarr.nix` | [service-media-recyclarr.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-recyclarr.md) | [Link unten](#NIXH-40-MED-014) |
| NIXH-40-MED-015 | `40-media/service-media-sabnzbd.nix` | [service-media-sabnzbd.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-sabnzbd.md) | [Link unten](#NIXH-40-MED-015) |
| NIXH-40-MED-016 | `40-media/service-media-services-common.nix` | [service-media-services-common.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-services-common.md) | [Link unten](#NIXH-40-MED-016) |
| NIXH-40-MED-017 | `40-media/service-media-sonarr.nix` | [service-media-sonarr.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-sonarr.md) | [Link unten](#NIXH-40-MED-017) |
| NIXH-50-KNW-001 | `50-knowledge/service-app-linkding.nix` | [service-app-linkding.nix](../../home/moritz/documents/MetaBibliothek/50-knowledge/service-app-linkding.md) | [Link unten](#NIXH-50-KNW-001) |
| NIXH-50-KNW-002 | `50-knowledge/service-app-miniflux.nix` | [service-app-miniflux.nix](../../home/moritz/documents/MetaBibliothek/50-knowledge/service-app-miniflux.md) | [Link unten](#NIXH-50-KNW-002) |
| NIXH-50-KNW-003 | `50-knowledge/service-app-paperless.nix` | [service-app-paperless.nix](../../home/moritz/documents/MetaBibliothek/50-knowledge/service-app-paperless.md) | [Link unten](#NIXH-50-KNW-003) |
| NIXH-50-KNW-004 | `50-knowledge/service-app-readeck.nix` | [service-app-readeck.nix](../../home/moritz/documents/MetaBibliothek/50-knowledge/service-app-readeck.md) | [Link unten](#NIXH-50-KNW-004) |
| NIXH-60-APP-001 | `60-apps/SERVICE_TEMPLATE.nix` | [SERVICE_TEMPLATE.nix](../../home/moritz/documents/MetaBibliothek/60-apps/SERVICE_TEMPLATE.md) | [Link unten](#NIXH-60-APP-001) |
| NIXH-60-APP-002 | `60-apps/service-app-couchdb.nix` | [service-app-couchdb.nix](../../home/moritz/documents/MetaBibliothek/60-apps/service-app-couchdb.md) | [Link unten](#NIXH-60-APP-002) |
| NIXH-60-APP-003 | `60-apps/service-app-filebrowser.nix` | [service-app-filebrowser.nix](../../home/moritz/documents/MetaBibliothek/60-apps/service-app-filebrowser.md) | [Link unten](#NIXH-60-APP-003) |
| NIXH-60-APP-004 | `60-apps/service-app-karakeep.nix` | [service-app-karakeep.nix](../../home/moritz/documents/MetaBibliothek/60-apps/service-app-karakeep.md) | [Link unten](#NIXH-60-APP-004) |
| NIXH-60-APP-005 | `60-apps/service-app-matrix-conduit.nix` | [service-app-matrix-conduit.nix](../../home/moritz/documents/MetaBibliothek/60-apps/service-app-matrix-conduit.md) | [Link unten](#NIXH-60-APP-005) |
| NIXH-60-APP-006 | `60-apps/service-app-monica.nix` | [service-app-monica.nix](../../home/moritz/documents/MetaBibliothek/60-apps/service-app-monica.md) | [Link unten](#NIXH-60-APP-006) |
| NIXH-60-APP-007 | `60-apps/service-app-vaultwarden.nix` | [service-app-vaultwarden.nix](../../home/moritz/documents/MetaBibliothek/60-apps/service-app-vaultwarden.md) | [Link unten](#NIXH-60-APP-007) |
| NIXH-80-MON-001 | `80-monitoring/cockpit.nix` | [cockpit.nix](../../home/moritz/documents/MetaBibliothek/80-monitoring/cockpit.md) | [Link unten](#NIXH-80-MON-001) |
| NIXH-80-MON-002 | `80-monitoring/service-netdata.nix` | [service-netdata.nix](../../home/moritz/documents/MetaBibliothek/80-monitoring/service-netdata.md) | [Link unten](#NIXH-80-MON-002) |
| NIXH-80-MON-003 | `80-monitoring/service-scrutiny.nix` | [service-scrutiny.nix](../../home/moritz/documents/MetaBibliothek/80-monitoring/service-scrutiny.md) | [Link unten](#NIXH-80-MON-003) |
| NIXH-80-MON-004 | `80-monitoring/uptime-kuma.nix` | [uptime-kuma.nix](../../home/moritz/documents/MetaBibliothek/80-monitoring/uptime-kuma.md) | [Link unten](#NIXH-80-MON-004) |
| NIXH-90-POL-001 | `90-policy/binary-only.nix` | [binary-only.nix](../../home/moritz/documents/MetaBibliothek/90-policy/binary-only.md) | [Link unten](#NIXH-90-POL-001) |
| NIXH-90-POL-002 | `90-policy/flat-layout.nix` | [flat-layout.nix](../../home/moritz/documents/MetaBibliothek/90-policy/flat-layout.md) | [Link unten](#NIXH-90-POL-002) |
| NIXH-90-POL-003 | `90-policy/no-legacy.nix` | [no-legacy.nix](../../home/moritz/documents/MetaBibliothek/90-policy/no-legacy.md) | [Link unten](#NIXH-90-POL-003) |
| NIXH-90-POL-004 | `90-policy/security-assertions.nix` | [security-assertions.nix](../../home/moritz/documents/MetaBibliothek/90-policy/security-assertions.md) | [Link unten](#NIXH-90-POL-004) |

---

## 💎 Inspiration & Development Registry

### [00-core]
#### .secrets-local.nix <a name="NIXH-00-COR-001"></a>
- [ryan4yin/nix-config (Secrets)](https://github.com/ryan4yin/nix-config/tree/main/hosts/common/core/sops.nix)
- [Mic92/sops-nix](https://github.com/Mic92/sops-nix)

#### ai-tools.nix <a name="NIXH-00-COR-002"></a>
- [NixOS Search: ai-tools](https://search.nixos.org/packages?query=ollama)

#### auto-locale.nix <a name="NIXH-00-COR-003"></a>
- [NixOS Manual: Localization](https://nixos.org/manual/nixos/stable/#ch-localization)

#### backup.nix <a name="NIXH-00-COR-004"></a>
- [NixOS Search: restic](https://search.nixos.org/options?query=services.restic)
- [ironicbadger/infra (Backup)](https://github.com/ironicbadger/infra/blob/master/nixos/backup.nix)

#### boot-safeguard.nix <a name="NIXH-00-COR-005"></a>
- [mitchellh/nixos-config (Boot)](https://github.com/mitchellh/nixos-config/blob/main/system/boot.nix)

#### central-configs-plan.nix <a name="NIXH-00-COR-006"></a>
- [Architecture Blueprint](https://nixos.wiki/wiki/Module)

#### config-merger.nix <a name="NIXH-00-COR-007"></a>
- [JSON Nix Integration](https://nixos.org/manual/nix/stable/expressions/builtins.html#builtins-fromJSON)

#### configs.nix <a name="NIXH-00-COR-008"></a>
- [Global Options Pattern](https://nixos.wiki/wiki/NixOS_modules#Options)

#### defaults.nix <a name="NIXH-00-COR-009"></a>
- [Misterio77/nix-starter-configs](https://github.com/Misterio77/nix-starter-configs)

#### fail2ban.nix <a name="NIXH-00-COR-010"></a>
- [NixOS Search: fail2ban](https://search.nixos.org/options?query=services.fail2ban)

#### firewall.nix <a name="NIXH-00-COR-011"></a>
- [NixOS Manual: Firewall](https://nixos.org/manual/nixos/stable/#sec-firewall)

#### hardware-configuration.nix <a name="NIXH-00-COR-012"></a>
- [NixOS Hardware (GitHub)](https://github.com/NixOS/nixos-hardware)

#### home-manager.nix <a name="NIXH-00-COR-013"></a>
- [nix-community/home-manager](https://github.com/nix-community/home-manager)

#### kernel-slim.nix <a name="NIXH-00-COR-017"></a>
- [IronicBadger: Kernel Hardening](https://github.com/ironicbadger/infra/blob/master/nixos/kernel.nix)

#### network.nix <a name="NIXH-00-COR-023"></a>
- [NixOS Manual: Networkd](https://nixos.org/manual/nixos/stable/#sec-systemd-networkd)

#### nix-tuning.nix <a name="NIXH-00-COR-024"></a>
- [NixOS Wiki: Storage optimization](https://nixos.wiki/wiki/Storage_optimization)

#### registry.nix <a name="NIXH-00-COR-027"></a>
- [Modular Design Patterns](https://github.com/ryan4yin/nix-config)

#### secrets.nix <a name="NIXH-00-COR-028"></a>
- [Mic92/sops-nix Examples](https://github.com/Mic92/sops-nix/tree/master/examples)

#### shell-premium.nix <a name="NIXH-00-COR-029"></a>
- [ryan4yin/nix-config (Shell)](https://github.com/ryan4yin/nix-config/tree/main/modules/nixos/base/shell)

### [10-gateway]
#### adguardhome.nix <a name="NIXH-10-GTW-001"></a>
- [NixOS Search: adguardhome](https://search.nixos.org/options?query=services.adguardhome)

#### caddy.nix <a name="NIXH-10-GTW-002"></a>
- [ironicbadger/infra (Caddy)](https://github.com/ironicbadger/infra/blob/master/nixos/caddy.nix)
- [Caddy Docs: Docker Proxy Pattern](https://caddyserver.com/docs/quick-start/reverse-proxy)

#### cloudflared-tunnel.nix <a name="NIXH-10-GTW-003"></a>
- [NixOS Search: cloudflared](https://search.nixos.org/options?query=services.cloudflared)

#### ddns-updater.nix <a name="NIXH-10-GTW-004"></a>
- [Upstream: qdm12/ddns-updater](https://github.com/qdm12/ddns-updater)

#### homepage.nix <a name="NIXH-10-GTW-007"></a>
- [gethomepage/homepage](https://github.com/gethomepage/homepage)

#### pocket-id.nix <a name="NIXH-10-GTW-009"></a>
- [pocket-id/pocket-id](https://github.com/pocket-id/pocket-id)

#### tailscale.nix <a name="NIXH-10-GTW-011"></a>
- [tailscale/tailscale](https://github.com/tailscale/tailscale)
- [NixOS Wiki: Tailscale](https://nixos.wiki/wiki/Tailscale)

### [20-infrastructure]
#### postgresql.nix <a name="NIXH-20-INF-002"></a>
- [NixOS Manual: PostgreSQL](https://nixos.org/manual/nixos/stable/#module-services-postgres)

#### service-app-zigbee-stack.nix <a name="NIXH-20-INF-004"></a>
- [zigbee2mqtt/zigbee2mqtt](https://github.com/Koenkk/zigbee2mqtt)

#### storage.nix <a name="NIXH-20-INF-005"></a>
- [mergerfs GitHub](https://github.com/trapexit/mergerfs)
- [IronicBadger: Perfect Media Server](https://github.com/ironicbadger/book-perfectmediaserver)

#### valkey.nix <a name="NIXH-20-INF-006"></a>
- [valkey-io/valkey](https://github.com/valkey-io/valkey)

#### vpn-confinement.nix <a name="NIXH-20-INF-007"></a>
- [Maroka-chan/VPN-Confinement](https://github.com/Maroka-chan/VPN-Confinement)

### [30-automation]
#### service-app-home-assistant.nix <a name="NIXH-30-AUT-003"></a>
- [home-assistant/core](https://github.com/home-assistant/core)

#### service-app-n8n.nix <a name="NIXH-30-AUT-004"></a>
- [n8n-io/n8n](https://github.com/n8n-io/n8n)

#### service-app-olivetin.nix <a name="NIXH-30-AUT-005"></a>
- [OliveTin/OliveTin](https://github.com/OliveTin/OliveTin)

#### service-app-semaphore.nix <a name="NIXH-30-AUT-006"></a>
- [ansible-semaphore/semaphore](https://github.com/ansible-semaphore/semaphore)

### [40-media]
#### media-stack.nix <a name="NIXH-40-MED-001"></a>
- [nix-media-server/nixarr](https://github.com/nix-media-server/nixarr)
- [kiriwalawren/nixflix](https://github.com/kiriwalawren/nixflix)

#### service-app-audiobookshelf.nix <a name="NIXH-40-MED-002"></a>
- [advplyr/audiobookshelf](https://github.com/advplyr/audiobookshelf)

#### service-media-jellyfin.nix <a name="NIXH-40-MED-007"></a>
- [jellyfin/jellyfin](https://github.com/jellyfin/jellyfin)

#### service-media-jellyseerr.nix <a name="NIXH-40-MED-008"></a>
- [Fallenbagel/jellyseerr](https://github.com/Fallenbagel/jellyseerr)

#### service-media-lidarr.nix <a name="NIXH-40-MED-009"></a>
- [Lidarr/Lidarr](https://github.com/Lidarr/Lidarr)

#### service-media-prowlarr.nix <a name="NIXH-40-MED-011"></a>
- [Prowlarr/Prowlarr](https://github.com/Prowlarr/Prowlarr)

#### service-media-radarr.nix <a name="NIXH-40-MED-012"></a>
- [Radarr/Radarr](https://github.com/Radarr/Radarr)

#### service-media-readarr.nix <a name="NIXH-40-MED-013"></a>
- [Readarr/Readarr](https://github.com/Readarr/Readarr)

#### service-media-recyclarr.nix <a name="NIXH-40-MED-014"></a>
- [recyclarr/recyclarr](https://github.com/recyclarr/recyclarr)

#### service-media-sabnzbd.nix <a name="NIXH-40-MED-015"></a>
- [sabnzbd/sabnzbd](https://github.com/sabnzbd/sabnzbd)

#### service-media-sonarr.nix <a name="NIXH-40-MED-017"></a>
- [Sonarr/Sonarr](https://github.com/Sonarr/Sonarr)

### [50-knowledge]
#### service-app-linkding.nix <a name="NIXH-50-KNW-001"></a>
- [sissis/linkding](https://github.com/sissis/linkding)

#### service-app-miniflux.nix <a name="NIXH-50-KNW-002"></a>
- [miniflux/v2](https://github.com/miniflux/v2)

#### service-app-paperless.nix <a name="NIXH-50-KNW-003"></a>
- [paperless-ngx/paperless-ngx](https://github.com/paperless-ngx/paperless-ngx)

#### service-app-readeck.nix <a name="NIXH-50-KNW-004"></a>
- [readeck/readeck](https://github.com/readeck/readeck)

### [60-apps]
#### service-app-karakeep.nix <a name="NIXH-60-APP-004"></a>
- [karakeep-app/karakeep](https://github.com/karakeep-app/karakeep)

#### service-app-matrix-conduit.nix <a name="NIXH-60-APP-005"></a>
- [girlbossceo/conduit](https://github.com/girlbossceo/conduit)

#### service-app-monica.nix <a name="NIXH-60-APP-006"></a>
- [monicahq/monica](https://github.com/monicahq/monica)

#### service-app-vaultwarden.nix <a name="NIXH-60-APP-007"></a>
- [dani-garcia/vaultwarden](https://github.com/dani-garcia/vaultwarden)

### [80-monitoring]
#### cockpit.nix <a name="NIXH-80-MON-001"></a>
- [cockpit-project/cockpit](https://github.com/cockpit-project/cockpit)

#### service-netdata.nix <a name="NIXH-80-MON-002"></a>
- [netdata/netdata](https://github.com/netdata/netdata)

#### service-scrutiny.nix <a name="NIXH-80-MON-003"></a>
- [AnalogJ/scrutiny](https://github.com/AnalogJ/scrutiny)

#### uptime-kuma.nix <a name="NIXH-80-MON-004"></a>
- [louislam/uptime-kuma](https://github.com/louislam/uptime-kuma)

### [90-policy]
#### binary-only.nix <a name="NIXH-90-POL-001"></a>
- [NixOS Wiki: Binary Cache](https://nixos.wiki/wiki/Binary_Cache)

#### security-assertions.nix <a name="NIXH-90-POL-004"></a>
- [NixOS Wiki: Hardening](https://nixos.wiki/wiki/Hardening)
