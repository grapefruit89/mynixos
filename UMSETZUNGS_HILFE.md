# 🚀 Umsetzungs-Hilfe: Audit-Fixes & Optimierungen

Diese Anleitung hilft dir, die vorgenommenen Änderungen am System zu verstehen und zu verifizieren.

## 1. Änderungen anwenden
Ich habe alle Dateien bereits vorbereitet und auf GitHub gepusht. Um sie auf dein System anzuwenden, nutze den neuen Workflow:

```bash
ncfg        # Ins Verzeichnis wechseln
nsw         # sudo nixos-rebuild switch ausführen
```

## 2. Verifizierung der Fixes

### Hardware (Intel GuC/HuC)
Prüfe, ob die Firmware korrekt geladen wurde:
```bash
dmesg | grep -i guc
```
Du solltest Meldungen über geladene GuC/HuC Binaries sehen.

### Hardware (Microcode)
```bash
dmesg | grep microcode
```

### Sicherheit (SSH)
Teste die neuen Timeouts:
1. Verbinde dich per SSH.
2. Warte ohne Eingabe. Die Verbindung sollte nach den definierten Intervallen (5 Min) geprüft werden.
3. Versuche dich mit falschem Passwort einzuloggen. Nach 3 Versuchen sollte der Disconnect erfolgen.

## 3. Der neue Shell-Workflow
Dein Terminal sieht jetzt professioneller aus!
- **MOTD:** Beim Einloggen siehst du sofort den Status von Traefik, SSH und Jellyfin.
- **Aliase:** Benutze `ll` für eine schicke Dateiliste (`eza`) oder `cat` für Syntax-Highlighting (`bat`).
- **Nix-Tools:** Probiere `nix-tree` aus, um Abhängigkeiten zu sehen.

## 4. Platzmangel beheben
Falls deine Boot-Partition wieder voll läuft, nutze den neuen Befehl:
```bash
nclean
```
Dieser löscht alte Generationen (>5) und führt die Garbage Collection aus.
