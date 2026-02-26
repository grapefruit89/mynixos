# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: Zentrale Betriebsanleitung für den Fujitsu Q958 NixOS-Stack
#   specIds: [OPS-001, OPS-002]

# 📖 System-Bedienung & Wartung

Dieses Dokument beschreibt, wie du das System im Alltag bedienst, Updates fährst und die Ordnung hältst.

## 🚀 Wichtige Aliase (Shortcuts)
Ich habe dir praktische Befehle eingerichtet, damit du nicht so viel tippen musst:

| Befehl | Aktion | Beschreibung |
| :--- | :--- | :--- |
| `ncfg` | `cd /etc/nixos` | Springt direkt in dein Konfigurations-Verzeichnis. |
| `ngit` | `git status -sb` | Zeigt dir kurz und knapp den Git-Status. |
| `nsw` | `sudo nixos-rebuild switch` | **Der wichtigste Befehl:** Aktiviert deine Änderungen. |
| `ndry` | `sudo nixos-rebuild dry-run` | Simuliert den Build (gut zum Testen auf Fehler). |
| `nix-deploy` | Skript | Führt Test, Switch und Git-Sync in einem Rutsch aus. |

## 🛠️ Der Workflow (Änderungen vornehmen)
1.  Gehe in das Verzeichnis: `ncfg`
2.  Editiere eine Datei (z.B. mit `nano` oder `micro`).
3.  Testen: `ndry`
4.  Aktivieren: `nsw`
5.  Speichern: `git add -A && git commit -m "Deine Nachricht" && git push`

## 🧹 Wartung & Platzmangel (WICHTIG!)
Da deine Boot-Partition (`/boot`) mit **96MB extrem klein** ist, musst du regelmäßig aufräumen, sonst schlagen Updates fehl.

### Platz schaffen
Wenn der Fehler "No space left on device" kommt:
1.  Alte Versionen löschen:
    ```bash
    sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +3
    ```
2.  Müll einsammeln:
    ```bash
    sudo nix-collect-garbage -d
    ```

### Warum ist /boot so klein?
NixOS wurde wahrscheinlich mit Standard-Partitionierung installiert. Ein Vergrößern ist nur über ein externes Tool (GParted Live USB) möglich, **nicht** über die Nix-Konfiguration selbst.

## 🔑 Secrets (Passwörter & Keys)
Deine Passwörter liegen **nicht** im Git, sondern lokal in:
- `/etc/secrets/homelab-runtime-secrets.env`
Wenn du dort etwas änderst, musst du die betroffenen Dienste neu starten (z.B. `sudo systemctl restart traefik`).
