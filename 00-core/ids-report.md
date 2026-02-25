## CFG.identity.domain

Sources:
- /etc/nixos/00-core/configs.nix:26

Sinks:
- /etc/nixos/10-infrastructure/cloudflared-tunnel.nix:20
- /etc/nixos/10-infrastructure/ddns-updater.nix:3
- /etc/nixos/10-infrastructure/homepage.nix:3
- /etc/nixos/10-infrastructure/pocket-id.nix:3
- /etc/nixos/10-infrastructure/traefik-core.nix:3
- /etc/nixos/10-infrastructure/traefik-routes-internal.nix:3
- /etc/nixos/20-services/apps/audiobookshelf.nix:3
- /etc/nixos/20-services/apps/miniflux.nix:3
- /etc/nixos/20-services/apps/monica.nix:3
- /etc/nixos/20-services/apps/n8n.nix:4
- /etc/nixos/20-services/apps/paperless.nix:3
- /etc/nixos/20-services/apps/readeck.nix:3
- /etc/nixos/20-services/apps/scrutiny.nix:3
- /etc/nixos/20-services/apps/vaultwarden.nix:4
- /etc/nixos/20-services/media/media-stack.nix:4
- /etc/nixos/20-services/media/services-common.nix:35

## CFG.identity.email

Sources:
- /etc/nixos/00-core/configs.nix:32

Sinks:
- /etc/nixos/10-infrastructure/traefik-core.nix:61

## CFG.identity.host

Sources:
- /etc/nixos/00-core/configs.nix:113
- /etc/nixos/00-core/configs.nix:44

Sinks:
- /etc/nixos/00-core/host.nix:23

## CFG.identity.user

Sources:
- /etc/nixos/00-core/configs.nix:110
- /etc/nixos/00-core/configs.nix:38

Sinks:
- /etc/nixos/00-core/ssh.nix:10
- /etc/nixos/00-core/system.nix:33
- /etc/nixos/00-core/users.nix:9

## CFG.network.acmeResolvers

Sources:
- /etc/nixos/00-core/configs.nix:100

Sinks:
- /etc/nixos/10-infrastructure/traefik-core.nix:67

## CFG.network.dnsBootstrap

Sources:
- /etc/nixos/00-core/configs.nix:94

Sinks:
- /etc/nixos/10-infrastructure/adguardhome.nix:23

## CFG.network.dnsDoH

Sources:
- /etc/nixos/00-core/configs.nix:85

Sinks:
- /etc/nixos/10-infrastructure/adguardhome.nix:21

## CFG.network.dnsFallback

Sources:
- /etc/nixos/00-core/configs.nix:74

Sinks:
- /etc/nixos/00-core/locale.nix:73

## CFG.network.dnsNamed

Sources:
- /etc/nixos/00-core/configs.nix:65

Sinks:
- /etc/nixos/00-core/locale.nix:63

## CFG.network.lanCidrs

Sources:
- /etc/nixos/00-core/configs.nix:53

Sinks:
- /etc/nixos/00-core/fail2ban.nix:10
- /etc/nixos/00-core/firewall.nix:11
- /etc/nixos/00-core/ssh.nix:14
- /etc/nixos/10-infrastructure/traefik-core.nix:128
- /etc/nixos/10-infrastructure/traefik-core.nix:163
- /etc/nixos/10-infrastructure/traefik-core.nix:5

## CFG.network.tailnetCidrs

Sources:
- /etc/nixos/00-core/configs.nix:59

Sinks:
- /etc/nixos/00-core/fail2ban.nix:12
- /etc/nixos/00-core/firewall.nix:13
- /etc/nixos/00-core/ssh.nix:16
- /etc/nixos/10-infrastructure/traefik-core.nix:129
- /etc/nixos/10-infrastructure/traefik-core.nix:164
- /etc/nixos/10-infrastructure/traefik-core.nix:6

