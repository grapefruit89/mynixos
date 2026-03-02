# 🏗️ NixHome System Architecture (NMS v2.3)

```mermaid
graph TB
    subgraph Layer00 [00-Core: The Foundation]
        direction TB
        Configs[configs.nix]
        Ports[ports.nix]
        Secrets[secrets.nix]
        Networking[network.nix]
        SSH[ssh.nix]
        Storage[storage.nix]
        Users[users.nix]
    end

    subgraph Layer10 [10-Infrastructure: Shared Services]
        direction TB
        Caddy[caddy.nix]
        AdGuard[adguardhome.nix]
        Postgres[postgresql.nix]
        Tailscale[tailscale.nix]
        PocketID[pocket-id.nix]
    end

    subgraph Layer20 [20-Services: Applications]
        subgraph MediaStack [Media & Download]
            Sonarr[sonarr.nix]
            Radarr[radarr.nix]
            SABnzbd[sabnzbd.nix]
            Jellyfin[jellyfin.nix]
        end
        subgraph Automation [Automation & Smart Home]
            n8n[n8n.nix]
            HA[home-assistant.nix]
            Zigbee[zigbee-stack.nix]
        end
        subgraph Utils [Utilities]
            Paperless[paperless.nix]
            Vaultwarden[vaultwarden.nix]
        end
    end

    subgraph Layer90 [90-Policy: Compliance]
        Assertions[security-assertions.nix]
    end

    %% Dependencies
    Layer00 --> Layer10
    Layer10 --> Layer20
    Layer20 --> Layer90
    
    %% Special Flows
    Secrets -.-> Layer10
    Secrets -.-> Layer20
    Caddy --> Layer20
    Networking --> Caddy
    Storage --> MediaStack
```

### 🛰️ Core Hardware Specs
- **CPU**: Intel i3-9100 (Fujitsu Q958)
- **RAM**: 16GB (Optimized Targets Active)
- **GPU**: UHD 630 (i915 driver, GuC/HuC enabled)
- **Storage**: ABC-Tiering (NVMe / SSD-Pool / HDD-Media)

### 📚 Documentation Reference
- **Master Index**: `/etc/nixos/docs/00_MASTER_INDEX.md`
- **SRE Standards**: `/etc/nixos/docs/09_METADATA_STANDARDS_INTEGRITY.md`
