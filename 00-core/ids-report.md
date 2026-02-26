# IDs Report (automatisch generiert)

> Generiert von: scripts/scan-ids.sh
> Stand: 2026-02-26

## CFG.firewall.backend

Sources:
- /etc/nixos/00-core/firewall.nix:31

Sinks:

## CFG.firewall.enabled

Sources:
- /etc/nixos/00-core/firewall.nix:35

Sinks:

## CFG.firewall.globalUdp

Sources:
- /etc/nixos/00-core/firewall.nix:46

Sinks:

## CFG.<gruppe>.<key>

Sources:

Sinks:

## CFG.identity.domain

Sources:
- /etc/nixos/00-core/configs.nix:11
- /etc/nixos/10-infrastructure/traefik-routes-internal.nix:3
- /etc/nixos/10-infrastructure/traefik-core.nix:3
- /etc/nixos/10-infrastructure/homepage.nix:3
- /etc/nixos/10-infrastructure/ddns-updater.nix:3
- /etc/nixos/10-infrastructure/pocket-id.nix:3
- /etc/nixos/10-infrastructure/cloudflared-tunnel.nix:20
- /etc/nixos/20-services/apps/n8n.nix:3
- /etc/nixos/20-services/apps/audiobookshelf.nix:3
- /etc/nixos/20-services/apps/readeck.nix:3
- /etc/nixos/20-services/apps/paperless.nix:3
- /etc/nixos/20-services/apps/scrutiny.nix:3
- /etc/nixos/20-services/apps/miniflux.nix:3
- /etc/nixos/20-services/apps/vaultwarden.nix:3
- /etc/nixos/20-services/apps/monica.nix:3
- /etc/nixos/20-services/media/services-common.nix:35
- /etc/nixos/20-services/media/media-stack.nix:4

Sinks:

## CFG.identity.email

Sources:
- /etc/nixos/00-core/configs.nix:18
- /etc/nixos/10-infrastructure/traefik-core.nix:70

Sinks:

## CFG.identity.host

Sources:
- /etc/nixos/00-core/host.nix:9
- /etc/nixos/00-core/configs.nix:32
- /etc/nixos/00-core/configs.nix:146

Sinks:

## CFG.identity.user

Sources:
- /etc/nixos/00-core/configs.nix:25
- /etc/nixos/00-core/system.nix:75
- /etc/nixos/90-policy/security-assertions.nix:17

Sinks:

## CFG.infrastructure.traefik.modules

Sources:
- /etc/nixos/10-infrastructure/traefik.nix:21

Sinks:

## CFG.network.acmeResolvers

Sources:
- /etc/nixos/00-core/configs.nix:86
- /etc/nixos/10-infrastructure/traefik-core.nix:77

Sinks:

## CFG.network.dnsBootstrap

Sources:
- /etc/nixos/00-core/configs.nix:65
- /etc/nixos/10-infrastructure/adguardhome.nix:22

Sinks:

## CFG.network.dnsDoH

Sources:
- /etc/nixos/00-core/configs.nix:55
- /etc/nixos/10-infrastructure/adguardhome.nix:18

Sinks:

## CFG.network.dnsFallback

Sources:
- /etc/nixos/00-core/locale.nix:83
- /etc/nixos/00-core/configs.nix:79

Sinks:

## CFG.network.dnsNamed

Sources:
- /etc/nixos/00-core/locale.nix:73
- /etc/nixos/00-core/configs.nix:72

Sinks:

## CFG.network.lanCidrs

Sources:
- /etc/nixos/00-core/firewall.nix:14
- /etc/nixos/00-core/firewall.nix:50
- /etc/nixos/00-core/fail2ban.nix:10
- /etc/nixos/00-core/configs.nix:41
- /etc/nixos/10-infrastructure/traefik-core.nix:7

Sinks:

## CFG.network.tailnetCidrs

Sources:
- /etc/nixos/00-core/firewall.nix:20
- /etc/nixos/00-core/fail2ban.nix:12
- /etc/nixos/00-core/configs.nix:48
- /etc/nixos/10-infrastructure/traefik-core.nix:11

Sinks:

## CFG.policy.assertions.canonical

Sources:
- /etc/nixos/00-core/server-rules.nix:12

Sinks:

## CFG.ports.pocketId

Sources:
- /etc/nixos/10-infrastructure/traefik-core.nix:116
- /etc/nixos/10-infrastructure/pocket-id.nix:7
- /etc/nixos/10-infrastructure/pocket-id.nix:31

Sinks:

## CFG.ports.ssh

Sources:
- /etc/nixos/00-core/firewall.nix:10

Sinks:

## CFG.ports.traefikHttps

Sources:
- /etc/nixos/00-core/firewall.nix:39

Sinks:

## CFG.secrets.sharedEnv

Sources:
- /etc/nixos/10-infrastructure/wireguard-vpn.nix:3

Sinks:

## CFG.secrets.traefikEnv

Sources:
- /etc/nixos/00-core/secrets.nix:18

Sinks:

## CFG.secrets.wgPrivadoPrivateKeyVarName

Sources:
- /etc/nixos/10-infrastructure/wireguard-vpn.nix:11

Sinks:

## CFG.secrets.wireguardPrivadoConf

Sources:
- /etc/nixos/10-infrastructure/wireguard-vpn.nix:7

Sinks:

## CFG.server.bindAddresses

Sources:

Sinks:

## CFG.server.lanIP

Sources:
- /etc/nixos/00-core/configs.nix:95
- /etc/nixos/00-core/configs.nix:152
- /etc/nixos/10-infrastructure/adguardhome.nix:10
- /etc/nixos/10-infrastructure/adguardhome.nix:27

Sinks:

## CFG.server.tailscaleIP

Sources:
- /etc/nixos/00-core/configs.nix:103
- /etc/nixos/00-core/configs.nix:158
- /etc/nixos/10-infrastructure/adguardhome.nix:14
- /etc/nixos/10-infrastructure/adguardhome.nix:28

Sinks:

## CFG.system.stateVersion

Sources:
- /etc/nixos/configuration.nix:47

Sinks:

## CFG.system.swap

Sources:
- /etc/nixos/configuration.nix:51

Sinks:

## CFG.vpn.privado.address

Sources:
- /etc/nixos/00-core/configs.nix:114
- /etc/nixos/10-infrastructure/wireguard-vpn.nix:15
- /etc/nixos/10-infrastructure/wireguard-vpn.nix:32

Sinks:

## CFG.vpn.privado.dns

Sources:
- /etc/nixos/00-core/configs.nix:121
- /etc/nixos/10-infrastructure/wireguard-vpn.nix:19
- /etc/nixos/10-infrastructure/wireguard-vpn.nix:33
- /etc/nixos/20-services/media/sabnzbd.nix:30

Sinks:

## CFG.vpn.privado.endpoint

Sources:
- /etc/nixos/00-core/configs.nix:128
- /etc/nixos/10-infrastructure/wireguard-vpn.nix:27
- /etc/nixos/10-infrastructure/wireguard-vpn.nix:35

Sinks:

## CFG.vpn.privado.publicKey

Sources:
- /etc/nixos/00-core/configs.nix:135
- /etc/nixos/10-infrastructure/wireguard-vpn.nix:23
- /etc/nixos/10-infrastructure/wireguard-vpn.nix:34

Sinks:

