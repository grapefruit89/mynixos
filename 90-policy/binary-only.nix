/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-90-POL-003
 *   title: "Binary-Only Policy"
 *   layer: 90
 * summary: Enforces a strict download-only workflow by forbidding local compilation.
 * ---
 */
{ config, lib, ... }:
{
  config = {
    # ── HARD ENFORCEMENT ──────────────────────────────────────────────────
    # Wir setzen max-jobs auf 0, um lokale Build-Slots komplett zu sperren.
    nix.settings.max-jobs = lib.mkForce 0;

    # ── ASSERTIONS ────────────────────────────────────────────────────────
    assertions = [
      {
        # Sicherstellen, dass niemand das Verbot lokal umgeht
        assertion = config.nix.settings.max-jobs == 0;
        message = "🚫 [POLICY-VIOLATION] Lokales Kompilieren ist auf diesem System verboten! 'nix.settings.max-jobs' muss 0 sein.";
      }
    ];
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
