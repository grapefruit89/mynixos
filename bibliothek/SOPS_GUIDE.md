---
title: SOPS_GUIDE
category: Architektur
status: done
trace_ids: []
last_reviewed: 2026-02-28
checksum: f0b8ffba22a9dc76e59c1e6aa69f2a8cd812fc4475d50a760e07579487ebf6aa
---
# 🔐 SOPS-Nix & Zero-Store Geheimnis-Management

Dieses Repository nutzt **SOPS** (Secrets OPerational Support) und **sops-nix**, um Geheimnisse sicher zu verwalten. 

## 🏗️ Das Sicherheitskonzept (TPM + Age)

Wir nutzen asymmetrische Verschlüsselung (Public/Private Key), um Geheimnisse vom Code zu trennen:

1.  **Der Briefschlitz (Public Keys):** In der `.sops.yaml` sind die öffentlichen Schlüssel definiert. Jeder kann damit Geheimnisse in den Safe "einwerfen", aber nicht wieder herausholen.
2.  **Der Safe-Schlüssel (Private Keys):**
    *   **Server-Key:** Der SSH-Host-Key des Q958-Servers (hardware-gebunden). Er erlaubt dem System, beim Booten automatisch alles zu entschlüsseln.
    *   **Notfall-Key (Age):** Dein persönlicher Offline-Schlüssel für die manuelle Bearbeitung oder Recovery.

## 📁 Dateistruktur

*   `/etc/nixos/secrets.yaml`: Die **verschlüsselte** Datenbank (darf/soll zu GitHub).
*   `/etc/nixos/.sops.yaml`: Die Konfiguration (wer darf verschlüsseln).
*   `/run/secrets/`: Hier liegen die Geheimnisse **entschlüsselt** im Arbeitsspeicher (RAM-Disk, niemals auf der Festplatte).
*   `/run/secrets-rendered/secrets.env`: Eine automatisch generierte Datei im `KEY=VAL` Format für Systemd-Dienste.

---

## 🛠️ Benutzung (Workflow)

### 1. Geheimnisse bearbeiten (Safe öffnen)
Um den Safe zu öffnen, brauchst du deinen Age-Key in `~/.config/sops/age/keys.txt`.

```bash
sops /etc/nixos/secrets.yaml
```
Dies öffnet deinen Standard-Editor. Nach dem Speichern verschlüsselt SOPS die Datei automatisch neu.

### 2. Ein Secret hinzufügen (Briefschlitz-Modus)
Du kannst Werte hinzufügen, ohne die Datei zu öffnen:

```bash
sops --set '["neues_passwort"] "super-geheim"' /etc/nixos/secrets.yaml
```

### 3. Integration in NixOS
In deinen `.nix` Modulen greifst du nie direkt auf Werte zu. Du nutzt Pfade:

```nix
# Für Systemd Dienste
systemd.services.mein-dienst.serviceConfig.EnvironmentFile = config.my.secrets.files.sharedEnv;

# In Shell-Skripten
source "${config.my.secrets.files.sharedEnv}"
```

---

## 🚨 Notfall-Wiederherstellung (Recovery)

Sollte der Server-Key verloren gehen, kannst du mit deinem **Age Private Key** die Datei auf jedem beliebigen Rechner entschlüsseln:

```bash
export SOPS_AGE_KEY="AGE-SECRET-KEY-..."
sops -d /etc/nixos/secrets.yaml
```

---

## ⚠️ Goldene Regeln
1. **Niemals** `import` auf eine Secret-Datei anwenden (leakt in den Nix-Store).
2. **Niemals** Geheimnisse in `home.sessionVariables` oder `environment.variables` schreiben.
3. Änderungen an der Struktur müssen immer in `00-core/secrets.nix` im Template nachgepflegt werden.
