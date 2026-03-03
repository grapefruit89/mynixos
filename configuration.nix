{ lib, pkgs, config, inputs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-00-SYS-ROOT-001";
    title = "System Entrypoint";
    description = "Consolidated system entrypoint using the 'Perfect Order' layer structure.";
    layer = 00;
    nixpkgs.category = "system/settings";
    capabilities = [ "system/entrypoint" "architecture/hubs" "architecture/perfect-order" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };
in
{
  options.my.meta.configuration = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for configuration module";
  };

  imports = [
    inputs.sops-nix.nixosModules.sops
    ./00-core/_imports.nix
    ./10-gateway/_imports.nix
    ./20-infrastructure/_imports.nix
    ./30-automation/_imports.nix
    ./40-media/_imports.nix
    ./50-knowledge/_imports.nix
    ./60-apps/_imports.nix
    ./80-monitoring/_imports.nix
    ./90-policy/_imports.nix
  ];

  config = {
    system.stateVersion = "25.11";
    networking.hostName = "nixhome";
    swapDevices = [ { device = "/var/lib/swapfile"; size = 4096; } ];
  };
}
