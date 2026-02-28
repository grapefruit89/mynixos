/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-20-SRV-008
 *   title: "Monica"
 *   layer: 20
 * architecture:
 *   req_refs: [REQ-SRV]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
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
 *   checksum: sha256:64e1d2985105cde4bbf38452642eee1dc1e4da6a32fab627a9ee7448b02d1a10
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
