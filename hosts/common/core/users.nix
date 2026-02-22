{ ... }:

{
  # ── BENUTZER ───────────────────────────────────────────────────────────────
  users.users.moritz = {
    isNormalUser = true;
    description  = "Moritz Baumeister";
    extraGroups  = [
      "networkmanager"   # Netzwerk verwalten
      "wheel"            # sudo-Rechte
      "video"            # GPU-Zugriff (für Jellyfin/QuickSync)
      "render"           # GPU-Zugriff (für Jellyfin/QuickSync)
    ];
  };

  # Passwortlose sudo-Rechte für Benutzer in der 'wheel'-Gruppe
  security.sudo.wheelNeedsPassword = false;
}
