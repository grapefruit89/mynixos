/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-90-POL-FLAT
 *   title: "Radical Flat Layout Enforcement"
 *   layer: 90
 * summary: Strict enforcement of zero-depth directory structure in ALL layer-folders (00-90).
 * ---
 */
{ lib, ... }:
let
  layersToCheck = [
    ../00-core
    ../10-infrastructure
    ../20-automation
    ../30-media
    ../40-knowledge
    ../50-iot
    ../60-comms
    ../70-tools
    ../80-analyse
    ../90-policy
  ];

  hasSubdirs = dir: 
    let
      contents = builtins.readDir dir;
      dirs = lib.filterAttrs (n: v: v == "directory") contents;
    in
      (builtins.length (builtins.attrNames dirs)) > 0;

  offendingLayers = lib.filter (dir: hasSubdirs dir) layersToCheck;
  formatOffenders = dirs: lib.concatStringsSep ", " (map (d: builtins.baseNameOf d) dirs);

in {
  assertions = [
    {
      assertion = (builtins.length offendingLayers) == 0;
      message = ''
        🛑 NIXHOME STRUCTURE VIOLATION: Subdirectories are strictly forbidden!
        Illegal subdirectories found in: ${formatOffenders offendingLayers}
        Flatten these directories to depth 0 immediately.
      '';
    }
  ];
}
