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
    # SSH Public Key – moritz@nobara
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJRDbyFjT4SEL8yxNwZuEBPORD82qlJJhdr2r4qz1vCX moritz@nobara"
    ];
  };
  # Passwortlose sudo-Rechte für Benutzer in der 'wheel'-Gruppe
  security.sudo.wheelNeedsPassword = false;
}
