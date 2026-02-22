{ ... }:

{
  # ── NIX EINSTELLUNGEN ──────────────────────────────────────────────────────
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ]; # Flakes aktivieren
    auto-optimise-store   = true;                        # Speicher sparen
  };

  # Alte Systemgenerationen automatisch aufräumen (älter als 7 Tage)
  nix.gc = {
    automatic = true;
    dates     = "weekly";
    options   = "--delete-older-than 7d";
  };

  # Proprietäre Software erlauben
  nixpkgs.config.allowUnfree = true;
}
