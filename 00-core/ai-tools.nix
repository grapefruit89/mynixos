/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        AI & Automation Tools
 * TRACE-ID:     NIXH-CORE-023
 * PURPOSE:      Installation von AI-Agenten-Tools (Aider, Gemini CLI) & Bash-Tweaks.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   []
 * LAYER:        00-core
 * STATUS:       Stable
 */

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    aider-chat uv python3 blesh inshellisense fzf jq curl
  ];

  programs.bash.interactiveShellInit = ''
    if [[ -f ${pkgs.blesh}/share/blesh/ble.sh ]]; then
      source ${pkgs.blesh}/share/blesh/ble.sh
      bleopt edit_multi_line=0 2>/dev/null || true
    fi

    if command -v inshellisense > /dev/null; then
       alias gemini-hint='inshellisense bind gemini -- gemini'
      alias p-graph='python3 /etc/nixos/scripts/generate-mermaid.py'
    fi
  '';
}
