# IDs Report (automatisch generiert)

> Generiert von: scripts/scan-ids.sh
> Stand: 2026-02-25T21:02:53+00:00

## CFG.firewall.backend

Sources:
- 00-core/firewall.nix:31

Sinks:
- 00-core/ids-report.md:6
- 00-core/firewall.nix:31

## CFG.firewall.enabled

Sources:
- 00-core/firewall.nix:35

Sinks:
- 00-core/ids-report.md:15
- 00-core/firewall.nix:35

## CFG.firewall.extraInputRules

Sources:
- 90-policy/security-assertions.nix:33

Sinks:
- 90-policy/security-assertions.nix:33
- 00-core/ids-report.md:24

## CFG.firewall.globalUdp

Sources:
- 00-core/firewall.nix:43

Sinks:
- 00-core/ids-report.md:33
- 00-core/firewall.nix:43

## CFG.identity.domain

Sources:
- 00-core/configs.nix:11
- 10-infrastructure/traefik-core.nix:3
- 10-infrastructure/pocket-id.nix:3

Sinks:
- 10-infrastructure/traefik-core.nix:3
- 10-infrastructure/pocket-id.nix:3
- 00-core/ids-report.md:42
- 00-core/configs.nix:11

## CFG.identity.email

Sources:
- 10-infrastructure/traefik-core.nix:62
- 00-core/configs.nix:18

Sinks:
- 10-infrastructure/traefik-core.nix:62
- 00-core/ids-report.md:55
- 00-core/configs.nix:18

## CFG.identity.host

Sources:
- 00-core/host.nix:9
- 00-core/configs.nix:32
- 00-core/configs.nix:125

Sinks:
- 00-core/ids-report.md:66
- 00-core/configs.nix:32
- 00-core/configs.nix:125
- 00-core/host.nix:9

## CFG.identity.user

Sources:
- 90-policy/security-assertions.nix:15
- 00-core/configs.nix:25

Sinks:
- 90-policy/security-assertions.nix:15
- 00-core/ids-report.md:79
- 00-core/configs.nix:25

## CFG.infrastructure.traefik.modules

Sources:
- 10-infrastructure/traefik.nix:21

Sinks:
- 00-core/ids-report.md:90
- 10-infrastructure/traefik.nix:21

## CFG.network.dnsBootstrap

Sources:
- 10-infrastructure/adguardhome.nix:22
- 00-core/configs.nix:65

Sinks:
- 00-core/ids-report.md:99
- 10-infrastructure/adguardhome.nix:22
- 00-core/configs.nix:65

## CFG.network.dnsDoH

Sources:
- 10-infrastructure/adguardhome.nix:18
- 00-core/configs.nix:55

Sinks:
- 00-core/ids-report.md:110
- 00-core/configs.nix:55
- 10-infrastructure/adguardhome.nix:18

## CFG.network.lanCidrs

Sources:
- 10-infrastructure/traefik-core.nix:7
- 00-core/firewall.nix:14
- 00-core/firewall.nix:51
- 00-core/configs.nix:41

Sinks:
- 00-core/ids-report.md:121
- 00-core/configs.nix:41
- 10-infrastructure/traefik-core.nix:7
- 00-core/firewall.nix:14
- 00-core/firewall.nix:51

## CFG.network.tailnetCidrs

Sources:
- 10-infrastructure/traefik-core.nix:11
- 00-core/firewall.nix:20
- 00-core/configs.nix:48

Sinks:
- 10-infrastructure/traefik-core.nix:11
- 00-core/ids-report.md:136
- 00-core/configs.nix:48
- 00-core/firewall.nix:20

## CFG.policy.assertions.canonical

Sources:
- 00-core/server-rules.nix:12

Sinks:
- 00-core/server-rules.nix:12
- 00-core/ids-report.md:149

## CFG.ports.pocketId

Sources:
- 10-infrastructure/pocket-id.nix:7
- 10-infrastructure/pocket-id.nix:31
- 10-infrastructure/traefik-core.nix:116

Sinks:
- 10-infrastructure/traefik-core.nix:116
- 10-infrastructure/pocket-id.nix:7
- 10-infrastructure/pocket-id.nix:31
- 00-core/ids-report.md:158

## CFG.ports.ssh

Sources:
- 00-core/firewall.nix:10
- 00-core/firewall.nix:47
- 90-policy/security-assertions.nix:21

Sinks:
- 90-policy/security-assertions.nix:21
- 00-core/ids-report.md:171
- 00-core/firewall.nix:10
- 00-core/firewall.nix:47

## CFG.ports.traefikHttps

Sources:
- 90-policy/security-assertions.nix:25
- 00-core/firewall.nix:39

Sinks:
- 90-policy/security-assertions.nix:25
- 00-core/ids-report.md:184
- 00-core/firewall.nix:39

## CFG.secrets.sharedEnv

Sources:
- 90-policy/security-assertions.nix:29
- 10-infrastructure/wireguard-vpn.nix:3

Sinks:
- 90-policy/security-assertions.nix:29
- 10-infrastructure/wireguard-vpn.nix:3
- 00-core/ids-report.md:195

## CFG.secrets.wgPrivadoPrivateKeyVarName

Sources:
- 10-infrastructure/wireguard-vpn.nix:11

Sinks:
- 00-core/ids-report.md:206
- 10-infrastructure/wireguard-vpn.nix:11

## CFG.secrets.wireguardPrivadoConf

Sources:
- 10-infrastructure/wireguard-vpn.nix:7

Sinks:
- 10-infrastructure/wireguard-vpn.nix:7
- 00-core/ids-report.md:215

## CFG.server.lanIP

Sources:
- 10-infrastructure/adguardhome.nix:10
- 10-infrastructure/adguardhome.nix:27
- 00-core/configs.nix:74
- 00-core/configs.nix:131

Sinks:
- 10-infrastructure/adguardhome.nix:10
- 10-infrastructure/adguardhome.nix:27
- 00-core/ids-report.md:224
- 00-core/configs.nix:74
- 00-core/configs.nix:131
- 00-core/configs.nix:134

## CFG.server.tailscaleIP

Sources:
- 00-core/configs.nix:82
- 00-core/configs.nix:137
- 10-infrastructure/adguardhome.nix:14
- 10-infrastructure/adguardhome.nix:28

Sinks:
- 00-core/ids-report.md:240
- 00-core/configs.nix:82
- 00-core/configs.nix:137
- 00-core/configs.nix:140
- 10-infrastructure/adguardhome.nix:14
- 10-infrastructure/adguardhome.nix:28

## CFG.system.stateVersion

Sources:
- configuration.nix:45

Sinks:
- configuration.nix:45
- 00-core/ids-report.md:256

## CFG.system.swap

Sources:
- configuration.nix:49

Sinks:
- configuration.nix:49
- 00-core/ids-report.md:265

## CFG.systemd.sabnzbd.bindsTo

Sources:
- 90-policy/security-assertions.nix:41

Sinks:
- 00-core/ids-report.md:274
- 90-policy/security-assertions.nix:41

## CFG.systemd.sshd.restartPolicy

Sources:
- 90-policy/security-assertions.nix:49

Sinks:
- 90-policy/security-assertions.nix:49
- 00-core/ids-report.md:283

## CFG.systemd.sshd.wantedBy

Sources:
- 90-policy/security-assertions.nix:53

Sinks:
- 90-policy/security-assertions.nix:53
- 00-core/ids-report.md:292

## CFG.systemd.traefik.environmentFile

Sources:
- 90-policy/security-assertions.nix:37

Sinks:
- 00-core/ids-report.md:301
- 90-policy/security-assertions.nix:37

## CFG.users.authorizedKeys

Sources:
- 90-policy/security-assertions.nix:45

Sinks:
- 90-policy/security-assertions.nix:45
- 00-core/ids-report.md:310

## CFG.vpn.privado.address

Sources:
- 00-core/configs.nix:93
- 10-infrastructure/wireguard-vpn.nix:15
- 10-infrastructure/wireguard-vpn.nix:32

Sinks:
- 10-infrastructure/wireguard-vpn.nix:15
- 10-infrastructure/wireguard-vpn.nix:32
- 00-core/ids-report.md:319
- 00-core/configs.nix:93

## CFG.vpn.privado.dns

Sources:
- 10-infrastructure/wireguard-vpn.nix:19
- 10-infrastructure/wireguard-vpn.nix:33
- 00-core/configs.nix:100

Sinks:
- 00-core/ids-report.md:332
- 10-infrastructure/wireguard-vpn.nix:19
- 10-infrastructure/wireguard-vpn.nix:33
- 00-core/configs.nix:100

## CFG.vpn.privado.endpoint

Sources:
- 10-infrastructure/wireguard-vpn.nix:27
- 10-infrastructure/wireguard-vpn.nix:35
- 00-core/configs.nix:107

Sinks:
- 10-infrastructure/wireguard-vpn.nix:27
- 10-infrastructure/wireguard-vpn.nix:35
- 00-core/ids-report.md:345
- 00-core/configs.nix:107

## CFG.vpn.privado.publicKey

Sources:
- 00-core/configs.nix:114
- 10-infrastructure/wireguard-vpn.nix:23
- 10-infrastructure/wireguard-vpn.nix:34

Sinks:
- 00-core/ids-report.md:358
- 00-core/configs.nix:114
- 10-infrastructure/wireguard-vpn.nix:23
- 10-infrastructure/wireguard-vpn.nix:34

