{ ... }:

{
  # ── SSH SERVER ─────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin      = "no";    # Root-Login verboten
      PasswordAuthentication = false; # Nur Key-Login erlauben
    };
  };
}
