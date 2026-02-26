# Aktueller Projektstatus — Fujitsu Q958 NixOS

## ✅ Abgeschlossene Optimierungen (Stand: 26.02.2026)

1.  **Hardware-Fixes:**
    *   Intel Microcode-Updates aktiviert (Security).
    *   Intel GuC/HuC Firmware-Loading (i915) aktiviert für UHD 630.
    *   Boot-Timeout auf 3 Sekunden optimiert.
    *   Jellyfin: Intel VPL Runtime hinzugefügt für bessere Codec-Unterstützung.

2.  **Sicherheits-Härtung:**
    *   SSH: `MaxAuthTries`, `LoginGraceTime` und `ClientAlive` Timeouts verschärft.
    *   Kernel: Umfangreiche `sysctl`-Härtung (RP Filter, ICMP ignore, SYN Flood Schutz).

3.  **Performance & Workflow:**
    *   Nix-Store: `max-jobs` auf 4 erhöht, `keep-outputs`/`keep-derivations` entfernt (spart Platz).
    *   Modularer Shell-Workflow: Migration von `aliases.nix` zu einem vollwertigen `shell.nix` Modul mit professionellem MOTD und modernen Tools (`eza`, `bat`, `fd`).
    *   Build-Befehle (`nsw`, `ntest`) auf Standard-Nix-Channel Logik umgestellt (kein `--flake` mehr).

4.  **Cleanup:**
    *   Veraltete Stubs (`server-rules.nix`, `de-config.nix`) gelöscht.
    *   Import-Struktur in `configuration.nix` bereinigt.

## ⏳ Offene Punkte (Roadmap)

*   [ ] **Monitoring:** Implementierung von Netdata/Scrutiny Dashboards.
*   [ ] **Backups:** Automatisierte Backups der State-Verzeichnisse (`/data/state`).
*   [ ] **Secrets:** Migration von ENV-Files zu `sops-nix` (sobald Flakes erwünscht sind).
*   [ ] **Public Services:** Implementierung von `traefik-routes-public.nix`.
