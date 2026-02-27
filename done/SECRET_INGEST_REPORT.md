# 📄 SRE-Bericht: Automatisiertes Secret-Management (Level 99)

**Datum:** 27. Februar 2026  
**Technologie:** Systemd Path Units + Inotify Kernel Events + Python Ingest Agent

---

## 🏗️ 1. Das Konzept: "Secret Landing Zone"
Anstatt sensible Zugangsdaten manuell in verschlüsselte Dateien zu kopieren, wurde ein isomorpher, automatisierter Prozess implementiert.

*   **Landing Zone:** `/etc/nixos/secret-landing-zone/` (Streng limitiert auf Root-Zugriff).
*   **Trigger:** Der Kernel überwacht den Ordner via `inotify`. Sobald eine Datei abgelegt wird, erwacht der Agent.
*   **Sicherheit:** Rohe Dateien werden nach der Verarbeitung mit `shred -u` (mehrfaches Überschreiben) physisch vernichtet.

---

## 🛠️ 2. Der Ingest-Prozess (Agent)
Der Agent scannt Dateien nach vordefinierten Mustern (aktuell WireGuard Standard):

1.  **Verschlüsselung (SOPS):** Der `PrivateKey` wird automatisch via `sops set` in die `secrets.yaml` geschrieben.
2.  **Architektur (Nix):** Öffentliche Daten (`PublicKey`, `Endpoint`, `Address`, `DNS`) werden in die Datei `10-infrastructure/vpn-live-config.nix` exportiert.
3.  **Override:** Diese Live-Konfiguration überschreibt automatisch die Standard-Werte in der `configs.nix`.

---

## 🚀 3. Dein neuer Workflow
Wenn du neue VPN-Daten (z.B. von Privado) hast:

1.  Lade die `.conf` Datei herunter.
2.  Schiebe sie in den Ordner: `/etc/nixos/secret-landing-zone/`.
3.  Warte eine Sekunde (der Agent verarbeitet die Datei und löscht sie).
4.  Tippe `nsw` (Rebuild) – Fertig!

---

## ✅ Status & Verifikation
*   **Path Unit:** `secret-ingest.path` ist aktiv (waiting).
*   **Service:** `secret-ingest.service` ist bereit.
*   **Alias:** `ingest-check` zeigt das Log der letzten Verarbeitungen.

**Systemzustand: VOLLAUTOMATISIERTES SECRET-HANDLING AKTIV**
