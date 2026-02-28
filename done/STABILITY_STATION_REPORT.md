# 🛰️ STABILITY STATION REPORT: Hardening & Optimization
**Datum:** 28.02.2026
**Status:** IMPLEMENTIERT & VERIFIZIERT

Dieses Dokument fasst die Maßnahmen zusammen, die ergriffen wurden, um die Systemstabilität zu erhöhen, die Performance zu optimieren und den "Kein-Legacy"-Standard für moderne Consumer-Hardware umzusetzen.

## 1. Nix-Build-Strategie (Smart-Fallback)
**Problem:** Installationen von unfreier Software (z.B. `n8n`) brachen ab, wenn keine Binärpakete im Cache verfügbar waren.
**Lösung:** Implementierung einer Fallback-Logik in `/etc/nixos/00-core/nix-tuning.nix`.
*   **Fallback:** `fallback = true` erlaubt lokales Kompilieren, falls der Download fehlschlägt.
*   **Ressourcen-Bremse:** `max-jobs = 1` und `cores = 1` stellen sicher, dass das System während eines Hintergrund-Builds nicht einfriert.
*   **Priorität:** Build-Daemon läuft mit niedriger CPU-Priorität (`idle`).
*   **Workflow:** Neuer Alias `nsw-dry` eingeführt, um vor jedem Update Transparenz über Downloads vs. Builds zu erhalten.

## 2. Kernel-Säuberung (Aggressive Slimming)
**Maßnahme:** Bereinigung der Kernel-Lade-Logik in `/etc/nixos/00-core/kernel-slim.nix`.
*   **Blacklisting:** Harte Sperrung von Modulen für Technik der 90er/frühen 2000er (Floppy, ISDN, Gameports, Amateur-Radio, Uralt-Dateisysteme wie `minix`).
*   **Security:** Deaktivierung der 32-Bit Emulation (`ia32_emulation=0`), um eine gesamte Klasse von Legacy-Exploits zu blockieren.
*   **Initrd Hardening:** Die `initrd` wurde auf das absolute Minimum reduziert (NVMe, AHCI, USB-Storage, Ext4/VFat). Dies beschleunigt den Bootvorgang und minimiert die Angriffsfläche im frühen Stadium.

## 3. "Breaking Glass" Architektur
**Maßnahme:** Sicherstellung des Headless-Zugriffs in Notfällen.
*   **Tailscale Bypass:** Caddy erlaubt nun administrativen Zugriff aus dem Tailscale-Netz (`100.64.0.0/10`), selbst wenn der SSO-Dienst (PocketID) offline ist.
*   **SSH Recovery Window:** Ein 15-minütiges Fenster nach dem Boot öffnet einen dedizierten SSH-Dienst auf Port 2222 für Passwort-Logins.

## ⚠️ Wichtige Betriebshinweise

### Der WireGuard "Loop"
Der `wireguard-vault.service` verfügt nun über einen aktiven Health-Check (Ping). 
*   **Gefahr:** Da der hinterlegte Key kompromittiert ist, schlägt der Ping fehl. Systemd wird versuchen, den Dienst alle 30s neu zu starten.
*   **Aktion:** Führe `sudo systemctl stop wireguard-vault.service` aus, bis du einen neuen Key generiert und via SOPS eingespielt hast.

### Home Assistant (OTBR Fehler)
Falls Home Assistant über fehlende Module (`python_otbr_api`) klagt:
*   Nutze `nsw-dry`. Prüfe, ob NixOS ein repariertes Paket aus dem Cache laden will. Da wir nun `fallback = true` aktiv haben, wird er fehlende Module notfalls lokal nachbauen, anstatt abzustürzen.

---
*Dokumentation abgeschlossen. Systemzustand: Stabil, Gehärtet, Modern.*
