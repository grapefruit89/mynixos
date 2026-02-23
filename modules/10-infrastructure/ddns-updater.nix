# TODO: ddns-updater – dynamisches DNS für wechselnde IP
# Paket: services.ddns-updater (in nixpkgs)
# Doku: https://mynixos.com/nixpkgs/option/services.ddns-updater.enable
#
# Konfiguration erfolgt über eine JSON-Datei mit den DNS-Provider-Credentials.
# Dies muss manuell konfiguriert werden, z.B. direkt im Modul oder über Umgebungsvariablen.
#
#   # Beispiel für manuelle Konfiguration:
#   # services.ddns-updater = {
#   #   enable = true;
#   #   settings = {
#   #     # Deine DNS-Provider-Credentials hier eintragen
#   #     "your-provider".api_key = "DEIN_API_KEY";
#   #   };
#   # };
#
# Firewall: ddns-updater braucht ausgehenden HTTP/HTTPS (bereits offen)
# Web-UI läuft auf Port 8000 – nur intern via Traefik exponieren!

{ ... }: { }
