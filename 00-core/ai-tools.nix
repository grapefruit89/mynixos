/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-001
 *   title: "AI Tools (SRE Assisted)"
 *   layer: 00
 * summary: Optimized terminal environment for AI-assisted development and SRE tasks.
 * ---
 */
{ pkgs, ... }:
{
  # ── SRE TOOLBELT ────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    aider-chat uv python3 blesh inshellisense fzf jq curl
  ];

  # ── SHELL UI ENHANCEMENT ────────────────────────────────────────────────
  programs.bash.interactiveShellInit = ''
    # Integriert blesh für Syntax-Highlighting und Auto-Suggestions
    if [[ -f ${pkgs.blesh}/share/blesh/ble.sh ]]; then
      source ${pkgs.blesh}/share/blesh/ble.sh
      bleopt edit_multi_line=0 2>/dev/null || true
    fi

    # AI Integration Aliase
    if command -v inshellisense > /dev/null; then
      alias gemini-hint='inshellisense bind gemini -- gemini'
      # SRE: Automatisierte Architektur-Visualisierung
      alias p-graph='python3 /etc/nixos/scripts/generate-mermaid.py'
    fi
  '';
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
