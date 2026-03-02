---
title: TTY Recovery & UX Reform Protocol
project: NMS v2.3
last_updated: 2026-03-02
status: Active Standard
type: Recovery Protocol
---

# 🆘 TTY RECOVERY & UX REFORM

Im März 2026 wurde das SSH-Recovery-System grundlegend reformiert, um die Benutzbarkeit der physischen Konsole (TTY) bei gleichzeitiger Sicherheit zu garantieren.

## 🚫 Das Problem: Der blockierende Countdown
Das alte System nutzte eine `for`-Schleife mit `echo -ne ""` und `sleep 1`, die sekündlich auf `/dev/tty1` schrieb. 
*   **Folge**: Jede Eingabe des Benutzers am Gerät wurde innerhalb von maximal 1 Sekunde überschrieben. Ein Einloggen oder Absetzen von Befehlen war faktisch unmöglich.
*   **Kategorie**: Kritischer Designfehler (Deadlock by Design).

## ✅ Die Lösung: Passiver Rescue-Mode

Der Recovery-Mechanismus wurde auf ein **non-blocking** Modell umgestellt:

1.  **Hintergrund-Timer**: Der SSH-Dienst auf Port `2222` startet beim Booten und wartet passiv via `sleep 300` (5 Minuten).
2.  **MOTD-Hinweis**: Statt eines blinkenden Countdowns wird beim Start der interaktiven Shell einmalig eine Warnmeldung im MOTD ausgegeben:
    `🚨 RECOVERY WINDOW ACTIVE (Port 2222)`
3.  **Terminal-Guards**: In der `bash.interactiveShellInit` wird nun explizit geprüft, ob eine interaktive Shell an einem echten Terminal vorliegt (`[[ -t 1 ]]`), bevor SRE-Skripte ausgeführt werden.

## 🛠️ Manuelle Aktivierung
Sollte das 5-Minuten-Fenster nach dem Boot verpasst werden, kann das Fenster jederzeit manuell geöffnet werden:
```bash
ssh-recovery-enable  # Alias für systemctl start ssh-recovery-manual
```
Dies öffnet den Passwort-Login für weitere 10 Minuten.

## 📊 Status-Abfrage
Der aktuelle Status des Fensters kann jederzeit mit folgendem Befehl geprüft werden:
```bash
ssh-recovery-status
```

---
*Status: REFORMED & USER-FRIENDLY*
