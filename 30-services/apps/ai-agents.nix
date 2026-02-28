/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Ai Agents
 * TRACE-ID:     NIXH-SRV-001
 * REQ-REF:      REQ-SRV
 * LAYER:        30
 * STATUS:       Stable
 * INTEGRITY:    SHA256:f3669772aaef6391882851667e66da283562943229dda96cb385cdc68a8c989d
 */

{ config, lib, pkgs, ... }:
let
  kimiClaudeScript = pkgs.writeShellScriptBin "kimi-claude" ''
    set -euo pipefail
    echo "🤖 Starte Kimi K2.5 Cloud-Modell..."
    ${pkgs.ollama}/bin/ollama run kimi-k2.5:cloud
    
    echo "🚀 Launche Claude Code mit Kimi-Backend..."
    ${pkgs.nodejs_22}/bin/npx -y @anthropic-ai/claude-code --model kimi-k2.5:cloud
  '';
in
{
  services.ollama.enable = true;
  services.ollama.package = if config.my.configs.hardware.intelGpu then pkgs.ollama-vulkan else pkgs.ollama;
  services.ollama.loadModels = [ "kimi-k2.5:cloud" ];

  environment.systemPackages = [
    kimiClaudeScript
    pkgs.ollama
    pkgs.nodejs_22
  ];

  programs.bash.shellAliases.kimi = "kimi-claude";
}
