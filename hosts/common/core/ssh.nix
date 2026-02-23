{ ... }:

{
  # ── SSH SERVER ─────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      Port = 53844;
      PermitRootLogin      = "no";    # Root-Login verboten
      PasswordAuthentication = false; # Nur Key-Login erlauben
    };
  };
}
