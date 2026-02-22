{ pkgs, ... }:

{
  # ── TAILSCALE (Secure Mesh Network) ────────────────────────────────────────
  # Ermöglicht einfachen und sicheren Zugriff auf den Server von überall.
  # Nach dem ersten Build: 'sudo tailscale up' ausführen.
  services.tailscale.enable = true;

  # MagicDNS aktivieren, damit der Server andere Geräte im Tailnet per Namen findet.
  services.tailscale.useTailnetDNS = true;
}
