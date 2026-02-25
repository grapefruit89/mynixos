# meta:
#   owner: core
#   status: draft
#   scope: shared
#   summary: centralization plan (no changes applied)
#
# purpose:
#   Blanko-Dokument, das beschreibt welche Werte zentralisiert werden sollen
#   und von wo nach wo sie wandern wuerden. Noch ohne Umstellung.
#
# proposed central keys:
#   identity.user
#   identity.host
#   identity.domain
#   identity.email
#   network.lanCidrs
#   network.tailnetCidrs
#   network.dnsServers
#   network.ntpServers
#   network.listenAddrs
#   security.trustedProxyCidrs
#   security.sshAllowCidrs
#   security.firewallBackend
#   services.traefik.email
#   services.traefik.domain
#   services.homepage.domain
#   services.adguard.listenAddr
#   secrets.paths
#
# mapping template (fill later):
#   - value: "m7c5.de"
#     current: /etc/nixos/10-infrastructure/traefik-core.nix
#     target: 00-core/configs.nix -> identity.domain
#   - value: "moritzbaumeister@gmail.com"
#     current: /etc/nixos/10-infrastructure/traefik-core.nix
#     target: 00-core/configs.nix -> identity.email
#
# notes:
#   - no migration yet
#   - docs/archive and hardware-configuration are excluded

{ ... }:
{
}
