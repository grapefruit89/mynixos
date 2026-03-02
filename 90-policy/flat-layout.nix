/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-90-POL-FLAT
 *   title: "Flat Layout Enforcement"
 *   layer: 90
 * summary: Strict enforcement of zero-depth directory structure in layer-folders.
 * ---
 */
{ lib, ... }:
let
  # Verzeichnisse, die auf Flachheit geprüft werden
  layersToCheck = [
    ../00-core
    ../10-infrastructure
    ../20-services
    ../30-analysis
    ../90-policy
  ];

  # Funktion: Prüft ob ein Verzeichnis Unterordner enthält
  hasSubdirs = dir: 
    let
      contents = builtins.readDir dir;
      dirs = lib.filterAttrs (n: v: v == "directory") contents;
    in
      (builtins.length (builtins.attrNames dirs)) > 0;

  # Liste der Verzeichnisse mit illegalen Unterordnern
  offendingLayers = lib.filter (dir: hasSubdirs dir) layersToCheck;
  
  # Formatierung für Fehlermeldung
  formatOffenders = dirs: lib.concatStringsSep ", " (map (d: builtins.baseNameOf d) dirs);

in {
  assertions = [
    {
      assertion = (builtins.length offendingLayers) == 0;
      message = ''
        🛑 NIXHOME STRUCTURE VIOLATION: Subdirectories are strictly forbidden in Layer-Folders!
        Illegal subdirectories found in: ${formatOffenders offendingLayers}
        Please flatten these directories to depth 0 to comply with Aviation Grade standards.
      '';
    }
  ];
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
