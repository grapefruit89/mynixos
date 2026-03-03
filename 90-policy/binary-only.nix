{ config, lib, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-90-POL-003";
    title = "Binary-Only Policy";
    description = "Enforces a strict download-only workflow by forbidding local compilation to protect system resources.";
    layer = 90;
    nixpkgs.category = "system/policy";
    capabilities = [ "policy/enforcement" "system/stability" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 1;
  };
in
{
  options.my.meta.binary_only = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for binary-only module";
  };

  config = {
    nix.settings.max-jobs = lib.mkForce 0;
    assertions = [ { assertion = config.nix.settings.max-jobs == 0; message = "🚫 [POLICY-VIOLATION] Lokales Kompilieren ist verboten!"; } ];
  };
}
