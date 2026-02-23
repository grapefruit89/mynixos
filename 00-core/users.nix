{ ... }:
{
  # ── BENUTZER ─────────────────────────────────────────────────────────────
  users.users.moritz = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" "render" ];
  };
}
