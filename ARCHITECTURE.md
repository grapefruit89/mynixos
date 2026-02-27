I will search for "media-vault" and "veth" in the `/etc/nixos` directory to understand the network namespace isolation and Traefik bridging configuration.
I'll read `10-infrastructure/vpn-confinement.nix` to extract the specific IP addresses and routing logic for the `media-vault` namespace and then search for references to those IPs in the Traefik configuration.
I'll examine `10-infrastructure/traefik.nix` to confirm how Traefik is configured to route traffic to the `media-vault` namespace via the `veth` bridge.
I'll read `10-infrastructure/traefik-core.nix` and `10-infrastructure/traefik-routes-internal.nix` to find the Traefik routing configuration for services in the `media-vault` namespace.
I'll check `20-services/media/media-stack.nix`, `20-services/media/default.nix`, and the individual service files like `20-services/media/sonarr.nix` to understand how the services in the `media-vault` namespace are exposed to Traefik.
```mermaid
graph TD
    subgraph HostNS ["Host Network Namespace"]
        direction TB
        Traefik["Traefik Proxy<br/>(Aggregator)"]
        VethHost["veth-host<br/>10.200.1.1"]
        NIC["Physical NIC<br/>(Internet/LAN)"]
        
        Traefik -->|Routes to 10.200.1.2| VethHost
        NIC ---|UDP Tunnel| Internet
    end

    subgraph VaultNS ["'media-vault' Namespace (Isolated)"]
        direction TB
        VethVault["veth-vault<br/>10.200.1.2"]
        VPN["privado (WireGuard)<br/>Default Gateway"]
        
        subgraph MediaServices ["Media Stack"]
            Sonarr["Sonarr"]
            Radarr["Radarr"]
            Prowlarr["Prowlarr"]
            SABnzbd["SABnzbd"]
        end

        VethVault -->|Port 8989| Sonarr
        VethVault -->|Port 7878| Radarr
        VethVault -->|Port 9696| Prowlarr
        VethVault -->|Port 8080| SABnzbd

        MediaServices -->|All Outbound Traffic| VPN
    end

    %% Bridge Connection
    VethHost <== "veth pair (L2 Bridge)" ==> VethVault
    
    %% VPN Tunneling
    VPN -.->|Encapsulated Traffic| NIC
    
    classDef ns fill:#f9f,stroke:#333,stroke-width:2px;
    classDef vault fill:#bbf,stroke:#333,stroke-width:2px;
    class HostNS ns;
    class VaultNS vault;
```
