# meta:
#   owner: gemini
#   status: active
#   scope: assistant-only
#   summary: Wichtige Kontexte für zukünftige KI-Assistenten
#   specIds: [LLM-001]

# 🤖 KI-Kontext (Für Gemini/Claude)

Dieses Dokument hilft dir, wenn du dem User bei diesem System hilfst.

## ⚠️ System-Eigenheiten
- **Bootloader:** `systemd-boot`. Partition ist mit 96MB extrem klein! Niemals ohne Garbage Collection bauen.
- **Git-Repo:** Liegt in `/etc/nixos/`. Gehört dem User `moritz` (Gruppe `users`). **Niemals `sudo git` verwenden**, da dies die Berechtigungen zerschießt!
- **Variablen-Pfade:** Greife immer auf `config.my.configs.*` zu (siehe `00-core/configs.nix`). Hardcodierte IPs oder Usernamen sind verboten.
- **Firewall:** Nur NFTables (`networking.nftables.enable = true`). Iptables ist legacy.

## 🔑 Secret handling
Secrets werden über eine lokale ENV-Datei geladen: `/etc/secrets/homelab-runtime-secrets.env`.
In Nix-Files wird darauf via `config.my.secrets.files.sharedEnv` verwiesen.

## ⌨️ Tastatur
Layout ist **ISO-DE**. Konfiguration liegt zentral in `00-core/locale.nix`.

## 📌 Wichtige Befehle
- Rebuild: `sudo nixos-rebuild switch`
- GC: `sudo nix-collect-garbage -d`
- Traceability prüfen: `rg "source-id:" /etc/nixos`
