# Decision Log

### 2026-02-25: traefik.nix Aggregator-Status
- Kontext: `10-infrastructure/traefik.nix` importierte `./traefik-routes-public.nix`, die im Repository nicht existiert.
- Analyse:
  - `rg -n "traefik-routes-public" /workspace/mynixos` zeigte Treffer nur in `10-infrastructure/traefik.nix` und als auskommentierte Zeile in `configuration.nix`.
  - `rg -n "traefik\.nix" /workspace/mynixos/configuration.nix` ergab keine Treffer.
  - `rg -n "traefik\.nix" /workspace/mynixos` ergab keine aktiven Import-Verweise.
- Entscheidung: **Lösung A** — `traefik.nix` bleibt als sauberer Aggregator erhalten, der nicht vorhandene Public-Route-Import ist auskommentiert.
- Konsequenzen:
  - Keine Build-Falle mehr, falls `traefik.nix` später importiert wird.
  - Public-Routes bleiben als klarer TODO-Punkt dokumentiert (`TODO-TRAEFIK-PUBLIC-001`).
