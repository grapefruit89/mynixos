# meta:
#   owner: infrastructure
#   status: active
#   scope: shared
#   summary: Traefik Aggregator-Import
#   source-ids: none (nur Import-Sammler)
#   note: traefik-routes-public.nix existiert noch nicht.
#         Platzhalter-Import auskommentiert bis Implementierung erfolgt.
#         Tracking: TODO-TRAEFIK-PUBLIC-001
#
# analysis (2026-02-25, repository root /workspace/mynixos):
# - rg -n "traefik-routes-public" /workspace/mynixos
#   -> 10-infrastructure/traefik.nix + commented line in configuration.nix
# - rg -n "traefik\.nix" /workspace/mynixos/configuration.nix
#   -> no matches (aggregator currently not imported)
# - rg -n "traefik\.nix" /workspace/mynixos
#   -> no .nix import references found

{ ... }:
{
  # source-id: CFG.infrastructure.traefik.modules
  # sink: bündelt Traefik-Teilmodule in einer optionalen Aggregator-Datei
  imports = [
    ./traefik-core.nix
    # ./traefik-routes-public.nix  # TODO-TRAEFIK-PUBLIC-001: noch nicht implementiert
    ./traefik-routes-internal.nix
  ];
}
