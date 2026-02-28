/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        AI Agents Workflow
 * TRACE-ID:     NIXH-SRV-002
 * PURPOSE:      Ollama & AI-Tooling (Kimi-Claude Integration).
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [00-core/configs.nix]
 * LAYER:        20-services
 * STATUS:       Stable
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
