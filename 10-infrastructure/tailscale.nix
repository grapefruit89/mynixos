{ pkgs, ... }:

{
  # ── TAILSCALE (Secure Mesh Network) ────────────────────────────────────────
  # Ermöglicht einfachen und sicheren Zugriff auf den Server von überall.
  # Nach dem ersten Build: 'sudo tailscale up' ausführen.
  services.tailscale.enable = true;

  # MagicDNS wird bei Aktivierung von Tailscale automatisch konfiguriert.
  # Die alte Option 'useTailnetDNS' wurde entfernt.
}
