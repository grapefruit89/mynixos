{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    aider-chat uv python3 blesh inshellisense fzf jq curl
  ];

  programs.bash.interactiveShellInit = ''
    # ble.sh laden (Fix: Ohne ungültige Flags)
    if [[ -f ${pkgs.blesh}/share/blesh/ble.sh ]]; then
      source ${pkgs.blesh}/share/blesh/ble.sh
      # Multiline-Modus via bleopt deaktivieren, falls unterstützt
      bleopt edit_multi_line=0 2>/dev/null || true
    fi

    # inshellisense nur bei Bedarf
    if command -v inshellisense > /dev/null; then
       alias gemini-hint='inshellisense bind gemini -- gemini'
    fi
  '';
}
