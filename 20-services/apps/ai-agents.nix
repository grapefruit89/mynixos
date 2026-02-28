{ config, lib, pkgs, ... }:
let
  # Wrapper für den Kimi-Claude Workflow
  kimiClaudeScript = pkgs.writeShellScriptBin "kimi-claude" ''
    set -euo pipefail
    echo "🤖 Starte Kimi K2.5 Cloud-Modell..."
    ${pkgs.ollama}/bin/ollama run kimi-k2.5:cloud
    
    echo "🚀 Launche Claude Code mit Kimi-Backend..."
    # Falls 'ollama launch' ein Plugin/Zusatztool ist, rufen wir es hier auf.
    # Wir setzen voraus, dass 'claude-code' installiert ist.
    # Da Claude Code meist via npm kommt:
    ${pkgs.nodejs_22}/bin/npx -y @anthropic-ai/claude-code --model kimi-k2.5:cloud
  '';
in
{
  # Ollama Dienst aktivieren
  services.ollama = {
    enable = true;
    acceleration = if config.my.configs.hardware.intelGpu then "vulkan" else null; # Intel GPU Support
    loadModels = [ "kimi-k2.5:cloud" ];
  };

  # Tools für den Agenten
  environment.systemPackages = [
    kimiClaudeScript
    pkgs.ollama
    pkgs.nodejs_22
  ];

  # Alias für schnellen Zugriff
  programs.bash.shellAliases = {
    "kimi" = "kimi-claude";
  };
}
