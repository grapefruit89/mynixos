# 🛰️ NixHome SPEC REGISTRY (SSoT)
Dieses Dokument ist die zentrale Master-Source für Traceability und Inspirationen.

## 🧬 Traceability Matrix

> [!warning] SRE Audit Befunde (Stand 2026-03-02)
> *   **CRITICAL BUG:** `PrivateDevices = true` in `jellyfin.nix` bricht das Hardware-Transcoding. (BEHOBEN in v4.0)
> *   **ARCHITECTURAL GAP:** Fehlendes `mkEnableOption` Pattern. (BEHOBEN in v4.0 via registry.nix)
> *   **DEPRECATION:** Deprecated Intel-Treiber entfernt. (BEHOBEN in v4.0)

| ID | Nix-Modul | Dokumentation (MetaBib) | Inspiration / Vorbild |
|---|---|---|---|
| NIXH-00-.SE | `00-core/.secrets-local.nix` | [.secrets-local.nix](../../home/moritz/documents/MetaBibliothek/00-core/.secrets-local.md) | [Link unten](#NIXH-00-.SE) |
| NIXH-00-AI- | `00-core/ai-tools.nix` | [ai-tools.nix](../../home/moritz/documents/MetaBibliothek/00-core/ai-tools.md) | [Link unten](#NIXH-00-AI-) |
| NIXH-00-AUT | `00-core/auto-locale.nix` | [auto-locale.nix](../../home/moritz/documents/MetaBibliothek/00-core/auto-locale.md) | [Link unten](#NIXH-00-AUT) |
| NIXH-00-BAC | `00-core/backup.nix` | [backup.nix](../../home/moritz/documents/MetaBibliothek/00-core/backup.md) | [Link unten](#NIXH-00-BAC) |
| NIXH-00-BOO | `00-core/boot-safeguard.nix` | [boot-safeguard.nix](../../home/moritz/documents/MetaBibliothek/00-core/boot-safeguard.md) | [Link unten](#NIXH-00-BOO) |
| NIXH-00-CEN | `00-core/central-configs-plan.nix` | [central-configs-plan.nix](../../home/moritz/documents/MetaBibliothek/00-core/central-configs-plan.md) | [Link unten](#NIXH-00-CEN) |
| NIXH-00-CON | `00-core/config-merger.nix` | [config-merger.nix](../../home/moritz/documents/MetaBibliothek/00-core/config-merger.md) | [Link unten](#NIXH-00-CON) |
| NIXH-00-CON | `00-core/configs.nix` | [configs.nix](../../home/moritz/documents/MetaBibliothek/00-core/configs.md) | [Link unten](#NIXH-00-CON) |
| NIXH-00-DEF | `00-core/defaults.nix` | [defaults.nix](../../home/moritz/documents/MetaBibliothek/00-core/defaults.md) | [Link unten](#NIXH-00-DEF) |
| NIXH-00-FAI | `00-core/fail2ban.nix` | [fail2ban.nix](../../home/moritz/documents/MetaBibliothek/00-core/fail2ban.md) | [Link unten](#NIXH-00-FAI) |
| NIXH-00-FIR | `00-core/firewall.nix` | [firewall.nix](../../home/moritz/documents/MetaBibliothek/00-core/firewall.md) | [Link unten](#NIXH-00-FIR) |
| NIXH-00-HAR | `00-core/hardware-configuration.nix` | [hardware-configuration.nix](../../home/moritz/documents/MetaBibliothek/00-core/hardware-configuration.md) | [Link unten](#NIXH-00-HAR) |
| NIXH-00-HOM | `00-core/home-manager.nix` | [home-manager.nix](../../home/moritz/documents/MetaBibliothek/00-core/home-manager.md) | [Link unten](#NIXH-00-HOM) |
| NIXH-00-HOS | `00-core/host-q958-hardware-configuration.nix` | [host-q958-hardware-configuration.nix](../../home/moritz/documents/MetaBibliothek/00-core/host-q958-hardware-configuration.md) | [Link unten](#NIXH-00-HOS) |
| NIXH-00-HOS | `00-core/host-q958-hardware-profile.nix` | [host-q958-hardware-profile.nix](../../home/moritz/documents/MetaBibliothek/00-core/host-q958-hardware-profile.md) | [Link unten](#NIXH-00-HOS) |
| NIXH-00-HOS | `00-core/host.nix` | [host.nix](../../home/moritz/documents/MetaBibliothek/00-core/host.md) | [Link unten](#NIXH-00-HOS) |
| NIXH-00-KER | `00-core/kernel-slim.nix` | [kernel-slim.nix](../../home/moritz/documents/MetaBibliothek/00-core/kernel-slim.md) | [Link unten](#NIXH-00-KER) |
| NIXH-00-LIB | `00-core/lib-helpers.nix` | [lib-helpers.nix](../../home/moritz/documents/MetaBibliothek/00-core/lib-helpers.md) | [Link unten](#NIXH-00-LIB) |
| NIXH-00-LOC | `00-core/locale.nix` | [locale.nix](../../home/moritz/documents/MetaBibliothek/00-core/locale.md) | [Link unten](#NIXH-00-LOC) |
| NIXH-00-LOG | `00-core/logging.nix` | [logging.nix](../../home/moritz/documents/MetaBibliothek/00-core/logging.md) | [Link unten](#NIXH-00-LOG) |
| NIXH-00-MOT | `00-core/motd.nix` | [motd.nix](../../home/moritz/documents/MetaBibliothek/00-core/motd.md) | [Link unten](#NIXH-00-MOT) |
| NIXH-00-NET | `00-core/network.nix` | [network.nix](../../home/moritz/documents/MetaBibliothek/00-core/network.md) | [Link unten](#NIXH-00-NET) |
| NIXH-00-NIX | `00-core/nix-tuning.nix` | [nix-tuning.nix](../../home/moritz/documents/MetaBibliothek/00-core/nix-tuning.md) | [Link unten](#NIXH-00-NIX) |
| NIXH-00-POR | `00-core/ports.nix` | [ports.nix](../../home/moritz/documents/MetaBibliothek/00-core/ports.md) | [Link unten](#NIXH-00-POR) |
| NIXH-00-PRI | `00-core/principles.nix` | [principles.nix](../../home/moritz/documents/MetaBibliothek/00-core/principles.md) | [Link unten](#NIXH-00-PRI) |
| NIXH-00-REG | `00-core/registry.nix` | [registry.nix](../../home/moritz/documents/MetaBibliothek/00-core/registry.md) | [Link unten](#NIXH-00-REG) |
| NIXH-00-SEC | `00-core/secrets.nix` | [secrets.nix](../../home/moritz/documents/MetaBibliothek/00-core/secrets.md) | [Link unten](#NIXH-00-SEC) |
| NIXH-00-SHE | `00-core/shell-premium.nix` | [shell-premium.nix](../../home/moritz/documents/MetaBibliothek/00-core/shell-premium.md) | [Link unten](#NIXH-00-SHE) |
| NIXH-00-SHE | `00-core/shell.nix` | [shell.nix](../../home/moritz/documents/MetaBibliothek/00-core/shell.md) | [Link unten](#NIXH-00-SHE) |
| NIXH-00-SSH | `00-core/ssh-rescue.nix` | [ssh-rescue.nix](../../home/moritz/documents/MetaBibliothek/00-core/ssh-rescue.md) | [Link unten](#NIXH-00-SSH) |
| NIXH-00-SSH | `00-core/ssh.nix` | [ssh.nix](../../home/moritz/documents/MetaBibliothek/00-core/ssh.md) | [Link unten](#NIXH-00-SSH) |
| NIXH-00-SYM | `00-core/symbiosis.nix` | [symbiosis.nix](../../home/moritz/documents/MetaBibliothek/00-core/symbiosis.md) | [Link unten](#NIXH-00-SYM) |
| NIXH-00-SYS | `00-core/system-stability.nix` | [system-stability.nix](../../home/moritz/documents/MetaBibliothek/00-core/system-stability.md) | [Link unten](#NIXH-00-SYS) |
| NIXH-00-SYS | `00-core/system.nix` | [system.nix](../../home/moritz/documents/MetaBibliothek/00-core/system.md) | [Link unten](#NIXH-00-SYS) |
| NIXH-00-TTY | `00-core/tty-info.nix` | [tty-info.nix](../../home/moritz/documents/MetaBibliothek/00-core/tty-info.md) | [Link unten](#NIXH-00-TTY) |
| NIXH-00-USE | `00-core/user-moritz-home.nix` | [user-moritz-home.nix](../../home/moritz/documents/MetaBibliothek/00-core/user-moritz-home.md) | [Link unten](#NIXH-00-USE) |
| NIXH-00-USE | `00-core/user-preferences.nix` | [user-preferences.nix](../../home/moritz/documents/MetaBibliothek/00-core/user-preferences.md) | [Link unten](#NIXH-00-USE) |
| NIXH-00-USE | `00-core/users.nix` | [users.nix](../../home/moritz/documents/MetaBibliothek/00-core/users.md) | [Link unten](#NIXH-00-USE) |
| NIXH-00-ZRA | `00-core/zram-swap.nix` | [zram-swap.nix](../../home/moritz/documents/MetaBibliothek/00-core/zram-swap.md) | [Link unten](#NIXH-00-ZRA) |
| NIXH-10-ADG | `10-gateway/adguardhome.nix` | [adguardhome.nix](../../home/moritz/documents/MetaBibliothek/10-gateway/adguardhome.md) | [Link unten](#NIXH-10-ADG) |
| NIXH-10-CAD | `10-gateway/caddy.nix` | [caddy.nix](../../home/moritz/documents/MetaBibliothek/10-gateway/caddy.md) | [Link unten](#NIXH-10-CAD) |
| NIXH-10-CLO | `10-gateway/cloudflared-tunnel.nix` | [cloudflared-tunnel.nix](../../home/moritz/documents/MetaBibliothek/10-gateway/cloudflared-tunnel.md) | [Link unten](#NIXH-10-CLO) |
| NIXH-10-DDN | `10-gateway/ddns-updater.nix` | [ddns-updater.nix](../../home/moritz/documents/MetaBibliothek/10-gateway/ddns-updater.md) | [Link unten](#NIXH-10-DDN) |
| NIXH-10-DNS | `10-gateway/dns-automation.nix` | [dns-automation.nix](../../home/moritz/documents/MetaBibliothek/10-gateway/dns-automation.md) | [Link unten](#NIXH-10-DNS) |
| NIXH-10-DNS | `10-gateway/dns-map.nix` | [dns-map.nix](../../home/moritz/documents/MetaBibliothek/10-gateway/dns-map.md) | [Link unten](#NIXH-10-DNS) |
| NIXH-10-HOM | `10-gateway/homepage.nix` | [homepage.nix](../../home/moritz/documents/MetaBibliothek/10-gateway/homepage.md) | [Link unten](#NIXH-10-HOM) |
| NIXH-10-LAN | `10-gateway/landing-zone-ui.nix` | [landing-zone-ui.nix](../../home/moritz/documents/MetaBibliothek/10-gateway/landing-zone-ui.md) | [Link unten](#NIXH-10-LAN) |
| NIXH-10-POC | `10-gateway/pocket-id.nix` | [pocket-id.nix](../../home/moritz/documents/MetaBibliothek/10-gateway/pocket-id.md) | [Link unten](#NIXH-10-POC) |
| NIXH-10-SSO | `10-gateway/sso.nix` | [sso.nix](../../home/moritz/documents/MetaBibliothek/10-gateway/sso.md) | [Link unten](#NIXH-10-SSO) |
| NIXH-10-TAI | `10-gateway/tailscale.nix` | [tailscale.nix](../../home/moritz/documents/MetaBibliothek/10-gateway/tailscale.md) | [Link unten](#NIXH-10-TAI) |
| NIXH-20-CLA | `20-infrastructure/clamav.nix` | [clamav.nix](../../home/moritz/documents/MetaBibliothek/20-infrastructure/clamav.md) | [Link unten](#NIXH-20-CLA) |
| NIXH-20-POS | `20-infrastructure/postgresql.nix` | [postgresql.nix](../../home/moritz/documents/MetaBibliothek/20-infrastructure/postgresql.md) | [Link unten](#NIXH-20-POS) |
| NIXH-20-SEC | `20-infrastructure/secret-ingest.nix` | [secret-ingest.nix](../../home/moritz/documents/MetaBibliothek/20-infrastructure/secret-ingest.md) | [Link unten](#NIXH-20-SEC) |
| NIXH-20-SER | `20-infrastructure/service-app-zigbee-stack.nix` | [service-app-zigbee-stack.nix](../../home/moritz/documents/MetaBibliothek/20-infrastructure/service-app-zigbee-stack.md) | [Link unten](#NIXH-20-SER) |
| NIXH-20-STO | `20-infrastructure/storage.nix` | [storage.nix](../../home/moritz/documents/MetaBibliothek/20-infrastructure/storage.md) | [Link unten](#NIXH-20-STO) |
| NIXH-20-VAL | `20-infrastructure/valkey.nix` | [valkey.nix](../../home/moritz/documents/MetaBibliothek/20-infrastructure/valkey.md) | [Link unten](#NIXH-20-VAL) |
| NIXH-20-VPN | `20-infrastructure/vpn-confinement.nix` | [vpn-confinement.nix](../../home/moritz/documents/MetaBibliothek/20-infrastructure/vpn-confinement.md) | [Link unten](#NIXH-20-VPN) |
| NIXH-20-VPN | `20-infrastructure/vpn-live-config.nix` | [vpn-live-config.nix](../../home/moritz/documents/MetaBibliothek/20-infrastructure/vpn-live-config.md) | [Link unten](#NIXH-20-VPN) |
| NIXH-30-AUT | `30-automation/automation.nix` | [automation.nix](../../home/moritz/documents/MetaBibliothek/30-automation/automation.md) | [Link unten](#NIXH-30-AUT) |
| NIXH-30-SER | `30-automation/service-app-ai-agents.nix` | [service-app-ai-agents.nix](../../home/moritz/documents/MetaBibliothek/30-automation/service-app-ai-agents.md) | [Link unten](#NIXH-30-SER) |
| NIXH-30-SER | `30-automation/service-app-home-assistant.nix` | [service-app-home-assistant.nix](../../home/moritz/documents/MetaBibliothek/30-automation/service-app-home-assistant.md) | [Link unten](#NIXH-30-SER) |
| NIXH-30-SER | `30-automation/service-app-n8n.nix` | [service-app-n8n.nix](../../home/moritz/documents/MetaBibliothek/30-automation/service-app-n8n.md) | [Link unten](#NIXH-30-SER) |
| NIXH-30-SER | `30-automation/service-app-olivetin.nix` | [service-app-olivetin.nix](../../home/moritz/documents/MetaBibliothek/30-automation/service-app-olivetin.md) | [Link unten](#NIXH-30-SER) |
| NIXH-30-SER | `30-automation/service-app-semaphore.nix` | [service-app-semaphore.nix](../../home/moritz/documents/MetaBibliothek/30-automation/service-app-semaphore.md) | [Link unten](#NIXH-30-SER) |
| NIXH-40-MED | `40-media/media-stack.nix` | [media-stack.nix](../../home/moritz/documents/MetaBibliothek/40-media/media-stack.md) | [Link unten](#NIXH-40-MED) |
| NIXH-40-SER | `40-media/service-app-audiobookshelf.nix` | [service-app-audiobookshelf.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-app-audiobookshelf.md) | [Link unten](#NIXH-40-SER) |
| NIXH-40-SER | `40-media/service-media-_lib.nix` | [service-media-_lib.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-_lib.md) | [Link unten](#NIXH-40-SER) |
| NIXH-40-SER | `40-media/service-media-_servarr-factory.nix` | [service-media-_servarr-factory.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-_servarr-factory.md) | [Link unten](#NIXH-40-SER) |
| NIXH-40-SER | `40-media/service-media-arr-wire.nix` | [service-media-arr-wire.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-arr-wire.md) | [Link unten](#NIXH-40-SER) |
| NIXH-40-SER | `40-media/service-media-default.nix` | [service-media-default.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-default.md) | [Link unten](#NIXH-40-SER) |
| NIXH-40-SER | `40-media/service-media-jellyfin.nix` | [service-media-jellyfin.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-jellyfin.md) | [Link unten](#NIXH-40-SER) |
| NIXH-40-SER | `40-media/service-media-jellyseerr.nix` | [service-media-jellyseerr.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-jellyseerr.md) | [Link unten](#NIXH-40-SER) |
| NIXH-40-SER | `40-media/service-media-lidarr.nix` | [service-media-lidarr.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-lidarr.md) | [Link unten](#NIXH-40-SER) |
| NIXH-40-SER | `40-media/service-media-media-stack.nix` | [service-media-media-stack.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-media-stack.md) | [Link unten](#NIXH-40-SER) |
| NIXH-40-SER | `40-media/service-media-prowlarr.nix` | [service-media-prowlarr.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-prowlarr.md) | [Link unten](#NIXH-40-SER) |
| NIXH-40-SER | `40-media/service-media-radarr.nix` | [service-media-radarr.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-radarr.md) | [Link unten](#NIXH-40-SER) |
| NIXH-40-SER | `40-media/service-media-readarr.nix` | [service-media-readarr.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-readarr.md) | [Link unten](#NIXH-40-SER) |
| NIXH-40-SER | `40-media/service-media-recyclarr.nix` | [service-media-recyclarr.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-recyclarr.md) | [Link unten](#NIXH-40-SER) |
| NIXH-40-SER | `40-media/service-media-sabnzbd.nix` | [service-media-sabnzbd.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-sabnzbd.md) | [Link unten](#NIXH-40-SER) |
| NIXH-40-SER | `40-media/service-media-services-common.nix` | [service-media-services-common.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-services-common.md) | [Link unten](#NIXH-40-SER) |
| NIXH-40-SER | `40-media/service-media-sonarr.nix` | [service-media-sonarr.nix](../../home/moritz/documents/MetaBibliothek/40-media/service-media-sonarr.md) | [Link unten](#NIXH-40-SER) |
| NIXH-50-SER | `50-knowledge/service-app-linkding.nix` | [service-app-linkding.nix](../../home/moritz/documents/MetaBibliothek/50-knowledge/service-app-linkding.md) | [Link unten](#NIXH-50-SER) |
| NIXH-50-SER | `50-knowledge/service-app-miniflux.nix` | [service-app-miniflux.nix](../../home/moritz/documents/MetaBibliothek/50-knowledge/service-app-miniflux.md) | [Link unten](#NIXH-50-SER) |
| NIXH-50-SER | `50-knowledge/service-app-paperless.nix` | [service-app-paperless.nix](../../home/moritz/documents/MetaBibliothek/50-knowledge/service-app-paperless.md) | [Link unten](#NIXH-50-SER) |
| NIXH-50-SER | `50-knowledge/service-app-readeck.nix` | [service-app-readeck.nix](../../home/moritz/documents/MetaBibliothek/50-knowledge/service-app-readeck.md) | [Link unten](#NIXH-50-SER) |
| NIXH-60-SER | `60-apps/SERVICE_TEMPLATE.nix` | [SERVICE_TEMPLATE.nix](../../home/moritz/documents/MetaBibliothek/60-apps/SERVICE_TEMPLATE.md) | [Link unten](#NIXH-60-SER) |
| NIXH-60-SER | `60-apps/service-app-couchdb.nix` | [service-app-couchdb.nix](../../home/moritz/documents/MetaBibliothek/60-apps/service-app-couchdb.md) | [Link unten](#NIXH-60-SER) |
| NIXH-60-SER | `60-apps/service-app-filebrowser.nix` | [service-app-filebrowser.nix](../../home/moritz/documents/MetaBibliothek/60-apps/service-app-filebrowser.md) | [Link unten](#NIXH-60-SER) |
| NIXH-60-SER | `60-apps/service-app-karakeep.nix` | [service-app-karakeep.nix](../../home/moritz/documents/MetaBibliothek/60-apps/service-app-karakeep.md) | [Link unten](#NIXH-60-SER) |
| NIXH-60-SER | `60-apps/service-app-matrix-conduit.nix` | [service-app-matrix-conduit.nix](../../home/moritz/documents/MetaBibliothek/60-apps/service-app-matrix-conduit.md) | [Link unten](#NIXH-60-SER) |
| NIXH-60-SER | `60-apps/service-app-monica.nix` | [service-app-monica.nix](../../home/moritz/documents/MetaBibliothek/60-apps/service-app-monica.md) | [Link unten](#NIXH-60-SER) |
| NIXH-60-SER | `60-apps/service-app-vaultwarden.nix` | [service-app-vaultwarden.nix](../../home/moritz/documents/MetaBibliothek/60-apps/service-app-vaultwarden.md) | [Link unten](#NIXH-60-SER) |
| NIXH-80-COC | `80-monitoring/cockpit.nix` | [cockpit.nix](../../home/moritz/documents/MetaBibliothek/80-monitoring/cockpit.md) | [Link unten](#NIXH-80-COC) |
| NIXH-80-SER | `80-monitoring/service-netdata.nix` | [service-netdata.nix](../../home/moritz/documents/MetaBibliothek/80-monitoring/service-netdata.md) | [Link unten](#NIXH-80-SER) |
| NIXH-80-SER | `80-monitoring/service-scrutiny.nix` | [service-scrutiny.nix](../../home/moritz/documents/MetaBibliothek/80-monitoring/service-scrutiny.md) | [Link unten](#NIXH-80-SER) |
| NIXH-80-UPT | `80-monitoring/uptime-kuma.nix` | [uptime-kuma.nix](../../home/moritz/documents/MetaBibliothek/80-monitoring/uptime-kuma.md) | [Link unten](#NIXH-80-UPT) |
| NIXH-90-BIN | `90-policy/binary-only.nix` | [binary-only.nix](../../home/moritz/documents/MetaBibliothek/90-policy/binary-only.md) | [Link unten](#NIXH-90-BIN) |
| NIXH-90-FLA | `90-policy/flat-layout.nix` | [flat-layout.nix](../../home/moritz/documents/MetaBibliothek/90-policy/flat-layout.md) | [Link unten](#NIXH-90-FLA) |
| NIXH-90-NO- | `90-policy/no-legacy.nix` | [no-legacy.nix](../../home/moritz/documents/MetaBibliothek/90-policy/no-legacy.md) | [Link unten](#NIXH-90-NO-) |
| NIXH-90-SEC | `90-policy/security-assertions.nix` | [security-assertions.nix](../../home/moritz/documents/MetaBibliothek/90-policy/security-assertions.md) | [Link unten](#NIXH-90-SEC) |

---

## 💎 Inspiration & Development Registry
Füge hier deine Links und Notizen zu den jeweiligen Modulen ein.

### [00-core]
#### .secrets-local.nix <a name="NIXH-00-.SE"></a>
- **ID:** `NIXH-00-.SE`
- **Links:** 

#### ai-tools.nix <a name="NIXH-00-AI-"></a>
- **ID:** `NIXH-00-AI-`
- **Links:** 

#### auto-locale.nix <a name="NIXH-00-AUT"></a>
- **ID:** `NIXH-00-AUT`
- **Links:** 

#### backup.nix <a name="NIXH-00-BAC"></a>
- **ID:** `NIXH-00-BAC`
- **Links:** 

#### boot-safeguard.nix <a name="NIXH-00-BOO"></a>
- **ID:** `NIXH-00-BOO`
- **Links:** 

#### central-configs-plan.nix <a name="NIXH-00-CEN"></a>
- **ID:** `NIXH-00-CEN`
- **Links:** 

#### config-merger.nix <a name="NIXH-00-CON"></a>
- **ID:** `NIXH-00-CON`
- **Links:** 

#### configs.nix <a name="NIXH-00-CON"></a>
- **ID:** `NIXH-00-CON`
- **Links:** 

#### defaults.nix <a name="NIXH-00-DEF"></a>
- **ID:** `NIXH-00-DEF`
- **Links:** 

#### fail2ban.nix <a name="NIXH-00-FAI"></a>
- **ID:** `NIXH-00-FAI`
- **Links:** 

#### firewall.nix <a name="NIXH-00-FIR"></a>
- **ID:** `NIXH-00-FIR`
- **Links:** 

#### hardware-configuration.nix <a name="NIXH-00-HAR"></a>
- **ID:** `NIXH-00-HAR`
- **Links:** 

#### home-manager.nix <a name="NIXH-00-HOM"></a>
- **ID:** `NIXH-00-HOM`
- **Links:** 

#### host-q958-hardware-configuration.nix <a name="NIXH-00-HOS"></a>
- **ID:** `NIXH-00-HOS`
- **Links:** 

#### host-q958-hardware-profile.nix <a name="NIXH-00-HOS"></a>
- **ID:** `NIXH-00-HOS`
- **Links:** 

#### host.nix <a name="NIXH-00-HOS"></a>
- **ID:** `NIXH-00-HOS`
- **Links:** 

#### kernel-slim.nix <a name="NIXH-00-KER"></a>
- **ID:** `NIXH-00-KER`
- **Links:** 

#### lib-helpers.nix <a name="NIXH-00-LIB"></a>
- **ID:** `NIXH-00-LIB`
- **Links:** 

#### locale.nix <a name="NIXH-00-LOC"></a>
- **ID:** `NIXH-00-LOC`
- **Links:** 

#### logging.nix <a name="NIXH-00-LOG"></a>
- **ID:** `NIXH-00-LOG`
- **Links:** 

#### motd.nix <a name="NIXH-00-MOT"></a>
- **ID:** `NIXH-00-MOT`
- **Links:** 

#### network.nix <a name="NIXH-00-NET"></a>
- **ID:** `NIXH-00-NET`
- **Links:** 

#### nix-tuning.nix <a name="NIXH-00-NIX"></a>
- **ID:** `NIXH-00-NIX`
- **Links:** 

#### ports.nix <a name="NIXH-00-POR"></a>
- **ID:** `NIXH-00-POR`
- **Links:** 

#### principles.nix <a name="NIXH-00-PRI"></a>
- **ID:** `NIXH-00-PRI`
- **Links:** 

#### registry.nix <a name="NIXH-00-REG"></a>
- **ID:** `NIXH-00-REG`
- **Links:** 

#### secrets.nix <a name="NIXH-00-SEC"></a>
- **ID:** `NIXH-00-SEC`
- **Links:** 

#### shell-premium.nix <a name="NIXH-00-SHE"></a>
- **ID:** `NIXH-00-SHE`
- **Links:** 

#### shell.nix <a name="NIXH-00-SHE"></a>
- **ID:** `NIXH-00-SHE`
- **Links:** 

#### ssh-rescue.nix <a name="NIXH-00-SSH"></a>
- **ID:** `NIXH-00-SSH`
- **Links:** 

#### ssh.nix <a name="NIXH-00-SSH"></a>
- **ID:** `NIXH-00-SSH`
- **Links:** 

#### symbiosis.nix <a name="NIXH-00-SYM"></a>
- **ID:** `NIXH-00-SYM`
- **Links:** 

#### system-stability.nix <a name="NIXH-00-SYS"></a>
- **ID:** `NIXH-00-SYS`
- **Links:** 

#### system.nix <a name="NIXH-00-SYS"></a>
- **ID:** `NIXH-00-SYS`
- **Links:** 

#### tty-info.nix <a name="NIXH-00-TTY"></a>
- **ID:** `NIXH-00-TTY`
- **Links:** 

#### user-moritz-home.nix <a name="NIXH-00-USE"></a>
- **ID:** `NIXH-00-USE`
- **Links:** 

#### user-preferences.nix <a name="NIXH-00-USE"></a>
- **ID:** `NIXH-00-USE`
- **Links:** 

#### users.nix <a name="NIXH-00-USE"></a>
- **ID:** `NIXH-00-USE`
- **Links:** 

#### zram-swap.nix <a name="NIXH-00-ZRA"></a>
- **ID:** `NIXH-00-ZRA`
- **Links:** 


### [10-gateway]
#### adguardhome.nix <a name="NIXH-10-ADG"></a>
- **ID:** `NIXH-10-ADG`
- **Links:** 

#### caddy.nix <a name="NIXH-10-CAD"></a>
- **ID:** `NIXH-10-CAD`
- **Links:** 

#### cloudflared-tunnel.nix <a name="NIXH-10-CLO"></a>
- **ID:** `NIXH-10-CLO`
- **Links:** 

#### ddns-updater.nix <a name="NIXH-10-DDN"></a>
- **ID:** `NIXH-10-DDN`
- **Links:** 

#### dns-automation.nix <a name="NIXH-10-DNS"></a>
- **ID:** `NIXH-10-DNS`
- **Links:** 

#### dns-map.nix <a name="NIXH-10-DNS"></a>
- **ID:** `NIXH-10-DNS`
- **Links:** 

#### homepage.nix <a name="NIXH-10-HOM"></a>
- **ID:** `NIXH-10-HOM`
- **Links:** 

#### landing-zone-ui.nix <a name="NIXH-10-LAN"></a>
- **ID:** `NIXH-10-LAN`
- **Links:** 

#### pocket-id.nix <a name="NIXH-10-POC"></a>
- **ID:** `NIXH-10-POC`
- **Links:** 

#### sso.nix <a name="NIXH-10-SSO"></a>
- **ID:** `NIXH-10-SSO`
- **Links:** 

#### tailscale.nix <a name="NIXH-10-TAI"></a>
- **ID:** `NIXH-10-TAI`
- **Links:** 


### [20-infrastructure]
#### clamav.nix <a name="NIXH-20-CLA"></a>
- **ID:** `NIXH-20-CLA`
- **Links:** 

#### postgresql.nix <a name="NIXH-20-POS"></a>
- **ID:** `NIXH-20-POS`
- **Links:** 

#### secret-ingest.nix <a name="NIXH-20-SEC"></a>
- **ID:** `NIXH-20-SEC`
- **Links:** 

#### service-app-zigbee-stack.nix <a name="NIXH-20-SER"></a>
- **ID:** `NIXH-20-SER`
- **Links:** 

#### storage.nix <a name="NIXH-20-STO"></a>
- **ID:** `NIXH-20-STO`
- **Links:** 

#### valkey.nix <a name="NIXH-20-VAL"></a>
- **ID:** `NIXH-20-VAL`
- **Links:** 

#### vpn-confinement.nix <a name="NIXH-20-VPN"></a>
- **ID:** `NIXH-20-VPN`
- **Links:** 

#### vpn-live-config.nix <a name="NIXH-20-VPN"></a>
- **ID:** `NIXH-20-VPN`
- **Links:** 


### [30-automation]
#### automation.nix <a name="NIXH-30-AUT"></a>
- **ID:** `NIXH-30-AUT`
- **Links:** 

#### service-app-ai-agents.nix <a name="NIXH-30-SER"></a>
- **ID:** `NIXH-30-SER`
- **Links:** 

#### service-app-home-assistant.nix <a name="NIXH-30-SER"></a>
- **ID:** `NIXH-30-SER`
- **Links:** 

#### service-app-n8n.nix <a name="NIXH-30-SER"></a>
- **ID:** `NIXH-30-SER`
- **Links:** 

#### service-app-olivetin.nix <a name="NIXH-30-SER"></a>
- **ID:** `NIXH-30-SER`
- **Links:** 

#### service-app-semaphore.nix <a name="NIXH-30-SER"></a>
- **ID:** `NIXH-30-SER`
- **Links:** 


### [40-media]
#### media-stack.nix <a name="NIXH-40-MED"></a>
- **ID:** `NIXH-40-MED`
- **Links:** 

#### service-app-audiobookshelf.nix <a name="NIXH-40-SER"></a>
- **ID:** `NIXH-40-SER`
- **Links:** 

#### service-media-_lib.nix <a name="NIXH-40-SER"></a>
- **ID:** `NIXH-40-SER`
- **Links:** 

#### service-media-_servarr-factory.nix <a name="NIXH-40-SER"></a>
- **ID:** `NIXH-40-SER`
- **Links:** 

#### service-media-arr-wire.nix <a name="NIXH-40-SER"></a>
- **ID:** `NIXH-40-SER`
- **Links:** 

#### service-media-default.nix <a name="NIXH-40-SER"></a>
- **ID:** `NIXH-40-SER`
- **Links:** 

#### service-media-jellyfin.nix <a name="NIXH-40-SER"></a>
- **ID:** `NIXH-40-SER`
- **Links:** 

#### service-media-jellyseerr.nix <a name="NIXH-40-SER"></a>
- **ID:** `NIXH-40-SER`
- **Links:** 

#### service-media-lidarr.nix <a name="NIXH-40-SER"></a>
- **ID:** `NIXH-40-SER`
- **Links:** 

#### service-media-media-stack.nix <a name="NIXH-40-SER"></a>
- **ID:** `NIXH-40-SER`
- **Links:** 

#### service-media-prowlarr.nix <a name="NIXH-40-SER"></a>
- **ID:** `NIXH-40-SER`
- **Links:** 

#### service-media-radarr.nix <a name="NIXH-40-SER"></a>
- **ID:** `NIXH-40-SER`
- **Links:** 

#### service-media-readarr.nix <a name="NIXH-40-SER"></a>
- **ID:** `NIXH-40-SER`
- **Links:** 

#### service-media-recyclarr.nix <a name="NIXH-40-SER"></a>
- **ID:** `NIXH-40-SER`
- **Links:** 

#### service-media-sabnzbd.nix <a name="NIXH-40-SER"></a>
- **ID:** `NIXH-40-SER`
- **Links:** 

#### service-media-services-common.nix <a name="NIXH-40-SER"></a>
- **ID:** `NIXH-40-SER`
- **Links:** 

#### service-media-sonarr.nix <a name="NIXH-40-SER"></a>
- **ID:** `NIXH-40-SER`
- **Links:** 


### [50-knowledge]
#### service-app-linkding.nix <a name="NIXH-50-SER"></a>
- **ID:** `NIXH-50-SER`
- **Links:** 

#### service-app-miniflux.nix <a name="NIXH-50-SER"></a>
- **ID:** `NIXH-50-SER`
- **Links:** 

#### service-app-paperless.nix <a name="NIXH-50-SER"></a>
- **ID:** `NIXH-50-SER`
- **Links:** 

#### service-app-readeck.nix <a name="NIXH-50-SER"></a>
- **ID:** `NIXH-50-SER`
- **Links:** 


### [60-apps]
#### SERVICE_TEMPLATE.nix <a name="NIXH-60-SER"></a>
- **ID:** `NIXH-60-SER`
- **Links:** 

#### service-app-couchdb.nix <a name="NIXH-60-SER"></a>
- **ID:** `NIXH-60-SER`
- **Links:** 

#### service-app-filebrowser.nix <a name="NIXH-60-SER"></a>
- **ID:** `NIXH-60-SER`
- **Links:** 

#### service-app-karakeep.nix <a name="NIXH-60-SER"></a>
- **ID:** `NIXH-60-SER`
- **Links:** 

#### service-app-matrix-conduit.nix <a name="NIXH-60-SER"></a>
- **ID:** `NIXH-60-SER`
- **Links:** 

#### service-app-monica.nix <a name="NIXH-60-SER"></a>
- **ID:** `NIXH-60-SER`
- **Links:** 

#### service-app-vaultwarden.nix <a name="NIXH-60-SER"></a>
- **ID:** `NIXH-60-SER`
- **Links:** 


### [80-monitoring]
#### cockpit.nix <a name="NIXH-80-COC"></a>
- **ID:** `NIXH-80-COC`
- **Links:** 

#### service-netdata.nix <a name="NIXH-80-SER"></a>
- **ID:** `NIXH-80-SER`
- **Links:** 

#### service-scrutiny.nix <a name="NIXH-80-SER"></a>
- **ID:** `NIXH-80-SER`
- **Links:** 

#### uptime-kuma.nix <a name="NIXH-80-UPT"></a>
- **ID:** `NIXH-80-UPT`
- **Links:** 


### [90-policy]
#### binary-only.nix <a name="NIXH-90-BIN"></a>
- **ID:** `NIXH-90-BIN`
- **Links:** 

#### flat-layout.nix <a name="NIXH-90-FLA"></a>
- **ID:** `NIXH-90-FLA`
- **Links:** 

#### no-legacy.nix <a name="NIXH-90-NO-"></a>
- **ID:** `NIXH-90-NO-`
- **Links:** 

#### security-assertions.nix <a name="NIXH-90-SEC"></a>
- **ID:** `NIXH-90-SEC`
- **Links:** 

