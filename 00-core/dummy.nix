# meta:
#   owner: core
#   status: template
#   scope: shared
#   summary: Kopiervorlage für neue Nix-Module (einheitliche Struktur)

# TEMPLATE-STRUKTUR
# 1) meta-header
# 2) Argumente { lib, config, ... }
# 3) let-Block nur wenn nötig
# 4) options unter my.<domain>.*
# 5) config via lib.mkIf
# 6) assertions mit klarer Fehlermeldung

{ lib, config, ... }:
let
  cfg = config.my.example;
in
{
  options.my.example = {
    enable = lib.mkEnableOption "example module";

    # Feste Standardbezeichner:
    # - enable (bool)
    # - host/domain (string)
    # - port aus my.ports.*
    host = lib.mkOption {
      type = lib.types.str;
      default = "example.local";
      description = "Beispiel-Host für die Modulvorlage.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.host != "";
        message = "my.example.host darf nicht leer sein.";
      }
    ];

    # source: options.my.example.*
    # sink:   hier konkrete services.*-Konfiguration einsetzen
  };
}
