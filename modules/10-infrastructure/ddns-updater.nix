# TODO: ddns-updater – dynamisches DNS für wechselnde IP
# Paket: services.ddns-updater (in nixpkgs)
# Doku: https://mynixos.com/nixpkgs/option/services.ddns-updater.enable
#
# Konfiguration erfolgt über eine JSON-Datei mit den DNS-Provider-Credentials.
# Diese muss als sops-Secret eingebunden werden:
#
#   sops.secrets."ddns_config" = { owner = "ddns-updater"; };
#
#   services.ddns-updater = {
#     enable = true;
#     environment.CONFIG = builtins.readFile config.sops.secrets."ddns_config".path;
#   };
#
# Firewall: ddns-updater braucht ausgehenden HTTP/HTTPS (bereits offen)
# Web-UI läuft auf Port 8000 – nur intern via Traefik exponieren!

{ ... }: { }
