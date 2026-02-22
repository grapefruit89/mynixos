{ config, pkgs, lib, ... }:

{
  # ── SOPS (Secrets Management) ──────────────────────────────────────────────
  sops = {
    # Pfad zur zentralen Secrets-Datei
    defaultSopsFile = ../../../secrets.sops.yaml;

    # Definiere die Geheimnisse, die entschlüsselt werden sollen.
    # Der Wert wird dann unter config.sops.secrets.<name> verfügbar.
    # secrets = {
    #   "example_secret" = {};
    #   # "sabnzbd_api_key" = {};
    #   # "cloudflare_api_token" = {};
    # };

    # Konfiguration für den sops-nix Dienst
    # age.keyFile = "/var/lib/sops/age.key"; # Standard-Pfad für den System-Key
    age.sshKeyPaths = []; # Wir verwenden Age, keine SSH-Keys
  };
}
