# meta:
#   owner: apps
#   status: placeholder
#   scope: service
#   summary: Open-WebUI Platzhalter mit Implementierungshinweisen

# TODO: open-webui – Web-Frontend für LLMs (Ollama, OpenAI, Anthropic, etc.)
# Paket: services.open-webui (in nixpkgs)
# Doku: https://mynixos.com/nixpkgs/option/services.open-webui.environment
#
# Hinweis Q958: kein GPU → lokale Modelle (Ollama) sehr langsam.
# Empfehlung: externe API (OpenAI/Anthropic) als Backend nutzen.
#
# API-Key muss manuell konfiguriert werden, z.B. direkt im Modul oder über Umgebungsvariablen.
#
#   # Beispiel für manuelle Konfiguration:
#   # services.open-webui = {
#   #   enable = true;
#   #   environment = {
#   #     OPENAI_API_KEY = "DEIN_OPENAI_API_KEY";
#   #     # OLLAMA_API_BASE_URL = "http://localhost:11434";
#   #   };
#   # };
#
# Achtung: bekannte Bugs in aktuellen nixpkgs (sqlite readonly, build failures)
# → vor Aktivierung Issue-Status prüfen:
#   https://github.com/NixOS/nixpkgs/issues/430433
#
# Web-UI läuft auf Port 1981 – via Traefik exponieren

{ ... }: { }
