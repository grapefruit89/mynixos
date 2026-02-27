{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    aider-chat         # Git-KI
    uv                 # Notwendig für nix-mcp
    blesh              # Graue History-Vorschläge (Auto-Complete)
    inshellisense      # IDE-Style Menüs für Befehle (Discovery)
  ];

  programs.bash.interactiveShellInit = ''
    # 1. ble.sh laden und Multiline-Modus deaktivieren (Enter führt sofort aus)
    source ${pkgs.blesh}/share/blesh/ble.sh --no-multiline
    bind 'RETURN: accept-line'

    # 2. inshellisense für gemini aktivieren
    # Erzeugt beim Tippen von 'gemini ' ein Auswahlmenü der Befehle
    if command -v inshellisense > /dev/null; then
      alias gemini='inshellisense bind gemini -- gemini'
    fi
  '';
}
