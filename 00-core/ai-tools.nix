{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    aider-chat         # Git-KI
    uv                 # Notwendig für nix-mcp
    blesh              # Graue History-Vorschläge (Auto-Complete)
    inshellisense      # IDE-Style Menüs für Befehle (Discovery)
    fzf                # Bonus: Schnelle Dateisuche
  ];

  programs.bash.interactiveShellInit = ''
    # 1. ble.sh laden und Multiline-Modus deaktivieren (Enter führt sofort aus)
    if [[ -f ${pkgs.blesh}/share/blesh/ble.sh ]]; then
      source ${pkgs.blesh}/share/blesh/ble.sh --no-multiline
      bind 'RETURN: accept-line'
    fi

    # 2. inshellisense für gemini aktivieren
    if command -v inshellisense > /dev/null; then
      alias gemini='inshellisense bind gemini -- gemini'
    fi
  '';
}
