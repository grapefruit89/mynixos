{ ... }:
{
  imports = [
    ./traefik-core.nix
    ./traefik-routes-public.nix
    ./traefik-routes-internal.nix
  ];
}
