# Configs Centralization Shortlist (Refined)

Goal: only centralize values that are reused across multiple files/services and are likely to change per user/host.
Non-goal: do not centralize service-specific settings or universally stable constants.

## Worth Centralizing (shared + changeable)

1. identity.domain
- Example current: `m7c5.de`
- Found in: traefik-core, homepage, pocket-id, traefik routes, media defaults, multiple app routers.
- Rationale: global hostname pattern and host routing; high fan-out.

2. identity.email
- Example current: `moritzbaumeister@gmail.com`
- Found in: traefik ACME + optional app config.
- Rationale: tied to TLS/ACME, changes per user.

3. identity.user
- Example current: `moritz`
- Found in: host/users/system paths.
- Rationale: primary interactive user; likely to change per machine.

4. identity.host
- Example current: `nixhome`
- Found in: host config, mDNS.
- Rationale: host naming + .local; changes per machine.

5. network.lanCidrs
- Example current: `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`
- Found in: firewall, ssh, fail2ban, traefik allowlists.
- Rationale: shared trust boundary; should be consistent.

6. network.tailnetCidrs
- Example current: `100.64.0.0/10`
- Found in: firewall, ssh, traefik allowlists.
- Rationale: shared trust boundary; should be consistent.

7. network.dnsResolvers (system)
- Example current: `1.1.1.1`, `9.9.9.9`, `one.one.one.one`, `dns.quad9.net`
- Found in: locale + adguard + traefik resolver.
- Rationale: policy choice; should be consistent.

8. time.profile / time.ntp
- Example current: locale profile -> NTP pools + timezone
- Found in: locale.nix
- Rationale: already centralized; keep as canonical source.

## Should Stay Local (service-specific or universal constants)

1. 127.0.0.1 / loopback bindings
- Too universal and safe; no reason to centralize.

2. per-service ports and listen addrs
- Already handled by `00-core/ports.nix` or should remain local.

3. per-service URLs / internal service wires
- Should stay near service definitions.

4. wireguard endpoints / provider configs
- Service-specific, often secret/ad-hoc.

## Traceability Rules (for centralized values)

- Use IDs: `CFG.<group>.<key>`
- Add `source-id` and `sink-id` comments where values are used.
- Keep comments short and useful; avoid noisy duplication.

Example:
  # source-id: CFG.identity.domain
  # sink-id:   traefik router domain

