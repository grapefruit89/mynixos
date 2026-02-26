# 🚀 Umsetzungs-Hilfe: Audit-Fixes & Optimierungen (V2)

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
Du solltest Meldungen über geladene GuC/HuC Binaries (z.B. `kbl_guc_70.1.1.bin`) sehen.

### Hardware (Microcode)
```bash
dmesg | grep microcode
```

### Sicherheit (SSH)
Teste die neuen Timeouts und Limits:
*   Login-Prompt bricht nach 20s ab.
*   Nach 3 Fehlversuchen wird die Verbindung getrennt.

### Traefik
Prüfe die Rate-Limits in den Logs, falls du viele parallele Anfragen machst.

## 3. Der neue Shell-Workflow
Dein Terminal sieht jetzt professioneller aus!
- **MOTD:** Beim Einloggen siehst du sofort den Status von Traefik, SSH und Jellyfin.
- **Aliase:** Benutze `ll` für eine schicke Dateiliste (`eza`) oder `cat` für Syntax-Highlighting (`bat`).

## 4. Platzmangel beheben
Falls deine Boot-Partition wieder voll läuft, nutze den neuen Befehl:
```bash
nclean
```
Dieser löscht alte Generationen (>5) und führt die Garbage Collection aus.
