{ lib, ... }:
let
  nms = {
    id = "NIXH-90-POL-002";
    title = "Flat Layout Enforcement";
    description = "Strict enforcement of zero-depth directory structure.";
    layer = 90;
    nixpkgs.category = "system/policy";
    capabilities = [ "policy/enforcement" "architecture/integrity" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

  layersToCheck = [
    ../00-core
    ../10-gateway
    ../20-infrastructure
    ../30-automation
    ../40-media
    ../50-knowledge
    ../60-apps
    ../80-monitoring
    ../90-policy
  ];

  hasSubdirs = dir: 
    let
      contents = builtins.readDir dir;
      dirs = lib.filterAttrs (n: v: v == "directory") contents;
    in
      (builtins.length (builtins.attrNames dirs)) > 0;

  offendingLayers = lib.filter (dir: hasSubdirs dir) layersToCheck;
in
{
  options.my.meta.flat_layout = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata";
  };

  config.assertions = [
    {
      assertion = (builtins.length offendingLayers) == 0;
      message = "🛑 NIXHOME STRUCTURE VIOLATION: Subdirectories are strictly forbidden!";
    }
  ];
}
