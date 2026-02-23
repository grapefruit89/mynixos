{ ... }:
{
  # ── BENUTZER ───────────────────────────────────────────────────────────────
  users.users.moritz = {
    isNormalUser = true;
    description  = "Moritz Baumeister";
    hashedPassword = "$6$pKl63Hvf4xCZ.50p$VDqTe9xF6gTtMFxZjQec1J3Xj2DfBFLPYQHUBJ2Vv2H6xurgOpi7sTz.jU3oyPTBTUo4uvv7ANq2eaUGwO1rC.";
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
