{ config, lib, pkgs, ... }:
let
  nms = {
    id = "NIXH-20-INF-003";
    title = "Secret Ingest";
    description = "Watcher for secret landing zone.";
    layer = 10;
    nixpkgs.category = "services/admin";
    capabilities = [ "automation/secrets" "security/ingest" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };
  python = pkgs.python311;
in
{
  options.my.meta.secret_ingest = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata";
  };

  config = lib.mkIf (config.my.services.secretIngest.enable or true) {
    systemd.paths.secret-ingest = {
      description = "Wächter für Secret Landing Zone";
      wantedBy = [ "multi-user.target" ];
      pathConfig = { DirectoryNotEmpty = "/etc/nixos/secret-landing-zone"; MakeDirectory = true; };
    };

    systemd.services.secret-ingest = {
      description = "Secret Ingest Agent";
      path = with pkgs; [ sops coreutils ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeScript "ingest-run" "#!${python}/bin/python\nimport os, re, subprocess, glob\n..."; # Shortened
        User = "root";
      };
    };
  };
}
