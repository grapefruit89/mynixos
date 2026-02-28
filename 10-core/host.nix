/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Host
 * TRACE-ID:     NIXH-CORE-001
 * REQ-REF:      REQ-CORE
 * LAYER:        10
 * STATUS:       Stable
 * INTEGRITY:    SHA256:6d572eaa3e3741fd0b0f56278c08441dc038f86a0d7d7fdf5f7e92ceb1611aee
 */

{ config, lib, ... }:
{
  # source-id: CFG.identity.host
  networking.hostName = lib.mkForce config.my.configs.identity.host;
}
