/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Monica
 * TRACE-ID:     NIXH-SRV-017
 * REQ-REF:      REQ-SRV
 * LAYER:        30
 * STATUS:       Stable
 * INTEGRITY:    SHA256:088b674b2e96d60107276783294c8f28a3703b9905dd61ff38483161ac8fb2a9
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
