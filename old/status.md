# Aktueller Projektstatus — Fujitsu Q958 NixOS

## ✅ Abgeschlossene Optimierungen (Stand: 26.02.2026)

1.  **Hardware-Fixes & Optimierung:**
    *   Intel Microcode-Updates aktiviert.
    *   Intel GuC/HuC Firmware-Loading aktiviert für UHD 630.
    *   Boot-Timeout auf 3 Sekunden reduziert.
    *   Jellyfin: Intel VPL Runtime & Hardware-Pfad Korrekturen (`/var/cache/jellyfin`).

2.  **Sicherheit & Härtung:**
    *   SSH: Login-Limits, Timeouts und Keep-Alives gehärtet.
    *   Kernel: Sysctl-Hardening gegen Spoofing und SYN-Floods.
    *   Traefik: Rate-Limiting verschärft (50 avg / 100 burst).
    *   Services: Systemd-Sandboxing für fast alle aktiven Dienste.

3.  **Architektur & Workflow:**
    *   Port-Kollision gelöst: Pocket-ID auf 10010 verschoben.
    *   Dokumentations-Refactoring: Ein zentrales Master-README und ein sauberer `docs/`-Ordner.
    *   Modularer Shell-Workflow: Dashboard-MOTD und moderne Tools.
    *   Git-Chaos beseitigt und alle Branches in `main` konsolidiert.

## ⏳ Nächste Schritte (Roadmap)

*   [ ] **Monitoring:** Dashboard-Integration für Netdata und Scrutiny.
*   [ ] **Backups:** Sicherung von `/data/state` automatisieren.
*   [ ] **Secrets:** Migration zu `sops-nix` (erfordert Flakes).
*   [ ] **Public Routes:** Implementierung der externen Traefik-Routen.
