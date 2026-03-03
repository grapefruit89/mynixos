{ config, lib, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-90-POL-002";
    title = "Security Assertions";
    description = "Global security assertions to ensure critical hardening settings are active in production.";
    layer = 90;
    nixpkgs.category = "system/policy";
    capabilities = [ "policy/enforcement" "security/hardening" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };
  bastelmodus = config.my.configs.bastelmodus;
  must = assertion: message: { inherit assertion message; };
  sshSettings = config.services.openssh.settings;
in
{
  options.my.meta.security_assertions = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for security-assertions module";
  };

  config.assertions = lib.optionals (!bastelmodus) [
    (must (config.networking.firewall.enable == true) "[SEC-NET-001] Firewall aktiv.")
    (must (config.networking.nftables.enable == true) "[SEC-NET-002] NFTables aktiv.")
    (must (sshSettings.PermitRootLogin == "no") "[SEC-SSH-002] No Root SSH.")
  ];
}
