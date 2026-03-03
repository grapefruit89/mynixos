{ pkgs, lib, config, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-00-CORE-001";
    title = "AI Tools (SRE Assisted)";
    description = "Optimized terminal environment for AI-assisted development and SRE tasks.";
    layer = 00;
    nixpkgs.category = "tools/admin";
    capabilities = [ "ai/workflow" "shell/enhancement" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 1;
  };
in
{
  options.my.meta.ai_tools = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for ai-tools module";
  };

  options.my.tools.ai.enable = lib.mkEnableOption "AI Tools (aider, uv, etc.)";

  config = lib.mkIf config.my.tools.ai.enable {
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
  };
}
