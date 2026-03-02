# /etc/nixos/30-analysis/default.nix
# Aggregator für den Observability & Analysis Layer
{
  imports = [
    ./netdata.nix
    ./scrutiny.nix
    # Loki & Grafana werden später hinzugefügt
  ];
}
