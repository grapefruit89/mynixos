{
  config,
  lib,
  pkgs,
  ...
}: let
  nms = {
    id = "NIXH-50-KNW-005";
    title = "Linkwarden (SRE Hardened)";
    description = "Collaborative bookmark manager with automatic archiving and DynamicUser sandboxing.";
    layer = 50;
    nixpkgs.category = "services/web-apps";
    capabilities = ["web/bookmarks" "archive/offline" "security/sandboxing"];
    audit.last_reviewed = "2026-03-03";
    audit.complexity = 2;
  };

  port = config.my.ports.linkwarden or 3000;
  domain = config.my.configs.identity.domain;
  # 🔑 SOPS Secret Identifier: linkwarden_env (Needs to be added to secrets.nix)
  # secretEnv = config.sops.secrets.linkwarden_env.path;
in {
  options.my.meta.linkwarden = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for linkwarden module";
  };

  options.my.services.linkwarden = {
    enable = lib.mkEnableOption "Linkwarden";
  };

  config = lib.mkIf config.my.services.linkwarden.enable {
    services.linkwarden = {
      enable = true;
      environment = {
        NEXTAUTH_URL = "https://links.${domain}/api/v1/auth";
      };
    };

    services.caddy.virtualHosts."links.${domain}" = {
      extraConfig = "import sso_auth\nreverse_proxy 127.0.0.1:${toString port}";
    };

    # 🛡️ SYSTEMD SANDBOXING
    systemd.services.linkwarden = {
      serviceConfig = {
        DynamicUser = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        SystemCallFilter = ["@system-service" "~@privileged"];
        OOMScoreAdjust = 300;
        StateDirectory = "linkwarden";
      };
    };
  };
}
/**
* ---
 * technical_integrity:
 *   checksum: sha256:956cedd86c000fb1f608adfd1bb8bcadb897d7662fbbd839bbcea8c4bedd700a
 *   eof_marker: NIXHOME_VALID_EOF* ---
*/

