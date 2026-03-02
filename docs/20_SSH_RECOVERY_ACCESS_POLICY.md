---
title: NixOS Homelab SSH Recovery & Access Policy
project: NMS v2.3
last_updated: 2026-03-02
status: Active Security Standard
type: Access Policy
---

# 🔐 SSH RECOVERY & ACCESS POLICY

Dieses Dokument beschreibt die mehrstufige Zugriffsstrategie für den Fernzugriff und die Notfall-Wiederherstellung.

## 🛡️ SSH Security Baseline

Das System folgt dem Prinzip der minimalen Angriffsfläche:
- **Custom Port**: `53844` (Definiert in `my.ports.ssh`).
- **Whitelisting**: Zugriff nur aus RFC1918 (Heimnetz) und Tailscale-IPs (`100.64.0.0/10`) erlaubt.
- **Root Login**: Strikt auf `no` gesetzt.
- **Härtung**: `LoginGraceTime 20`, `MaxAuthTries 3`, `ClientAliveInterval 300`.

## 🆘 Recovery-Window (Das 5-Minuten Fenster)

Um ein vollständiges Lockout (z.B. bei Verlust des SSH-Keys) zu verhindern, existiert ein automatisierter Notfallanker:

1.  **Start**: Unmittelbar nach dem Bootvorgang wird ein separates SSH-Fenster auf Port **2222** geöffnet.
2.  **Auth**: In diesem Fenster ist `PasswordAuthentication` für 5 Minuten aktiv.
3.  **Ende**: Nach Ablauf der 5 Minuten wird der Dienst automatisch beendet und das Fenster geschlossen.
4.  **Audit**: Jeder Login-Versuch in diesem Fenster wird separat geloggt (`ssh-recovery-audit`).

## 🔑 Key-Aware Fallback Logik

In der regulären SSH-Konfiguration (`ssh.nix`) gilt:
- **Key vorhanden**: Passwort-Login ist permanent deaktiviert.
- **Kein Key**: Das System erlaubt (mit Warnmeldung im Log) temporär einen Passwort-Login als "Notnagel", bis der erste Key hinterlegt wurde.

## 📺 TTY-Notnagel
`PermitTTY = true` ist systemweit erzwungen und bleibt immer aktiv, um im Notfall über das Dashboard oder die serielle Konsole Befehle absetzen zu können.

---
*Dokument Ende.*
