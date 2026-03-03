{
  config,
  lib,
  ...
}: let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-00-COR-016";
    title = "Host";
    description = "Basic hostname and identity configuration for the server.";
    layer = 00;
    nixpkgs.category = "system/settings";
    capabilities = ["system/identity"];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 1;
  };
in {
  options.my.meta.host = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for host module";
  };

  config = {
    networking.hostName = lib.mkForce config.my.configs.identity.host;
  };
}
