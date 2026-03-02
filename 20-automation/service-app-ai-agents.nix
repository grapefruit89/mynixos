/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-001
 *   title: "Ai Agents (Ollama & Claude)"
 *   layer: 20
 * summary: Local AI orchestration with Ollama (GPU-accelerated) and Claude Code.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/ollama.nix
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
  # 🚀 OLLAMA EXHAUSTION
  services.ollama = {
    enable = true;
    # SRE Hardware Acceleration: Vulkan für UHD 630 nutzen falls möglich
    package = if config.my.configs.hardware.intelGpu then pkgs.ollama-vulkan else pkgs.ollama;
    loadModels = [ "kimi-k2.5:cloud" ];
  };

  # ── SRE TOOLS ───────────────────────────────────────────────────────────
  environment.systemPackages = [
    kimiClaudeScript
    pkgs.ollama
    pkgs.nodejs_22
  ];

  # Alias für den schnellen Zugriff
  programs.bash.shellAliases.kimi = "kimi-claude";

  # ── SRE HARDENING ───────────────────────────────────────────────────────
  systemd.services.ollama.serviceConfig = {
    # GPU Zugriff sicherstellen
    DeviceAllow = [ "/dev/dri/renderD128 rw" ];
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    # OOM-Schutz: KI-Modelle fressen viel RAM
    OOMScoreAdjust = 500;
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
