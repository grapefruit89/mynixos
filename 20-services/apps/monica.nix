/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-20-APP-SRV-008
 *   title: "Monica"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   status: audited
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

/**
 * ---
 * technical_integrity:
 *   checksum: sha256:176be139640537b303f67a2803956bd09867388a2b3ecbc3db2c22fc56866de9
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
