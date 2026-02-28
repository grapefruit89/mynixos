/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-001
 *   title: "Ai Agents"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
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










/**
 * ---
 * technical_integrity:
 *   checksum: sha256:fd78e9231476c8621b26338677cb0f22f3c34036ada08b2d75134fec69ae860f
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
