/**
 * ---
 * nms_version: 2.1
 * unit:
 *   id: NIXH-20-APP-SRV-008
 *   title: "Monica"
 *   layer: 20
 *   req_refs: [REQ-SRV]
 *   status: stable
 * traceability:
 *   parent: NIXH-20-SYS-ROOT
 *   depends_on: []
 *   conflicts_with: []
 * security:
 *   integrity_hash: "sha256:176be139640537b303f67a2803956bd09867388a2b3ecbc3db2c22fc56866de9"
 *   trust_level: 5
 *   last_audit: "2026-02-28"
 * automation:
 *   complexity_score: 2
 *   auto_fix: true
 * ---
 */

{ config, lib, ... }:
let
  myLib = import ../../lib/helpers.nix { inherit lib; };
  appKeyFile = "/var/lib/monica/app-key";
  serviceBase = myLib.mkService {
    inherit config;
    name = "monica";
    useSSO = true;
    description = "Personal CRM";
  };
in
lib.mkMerge [
  serviceBase
  {
    services.monica = {
      enable = true;
      hostname = "nix-monica.${config.my.configs.identity.domain}";
      appURL = "https://nix-monica.${config.my.configs.identity.domain}";
      inherit appKeyFile;

      nginx.listen = [
        {
          addr = "127.0.0.1";
          port = config.my.ports.monica;
          ssl = false;
        }
      ];
    };

    system.activationScripts.monicaAppKeyFile.text = ''
      set -eu
      install -d -m 0750 -o monica -g monica /var/lib/monica
      if [ ! -s ${appKeyFile} ]; then
        head -c 32 /dev/urandom | base64 > ${appKeyFile}
      fi
      chown monica:monica ${appKeyFile}
      chmod 0600 ${appKeyFile}
    '';
  }
]
