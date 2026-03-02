# 🏁 SRE Audit Report: Layer 20 (Media) - Option Exhaustion & Storage Tiering (2026-03-02)

## 📋 Zusammenfassung
Maximale Ausschöpfung der NixOS-Optionen für den Media-Stack. Implementierung eines strikten ABC-Tiering-Zugriffsmodells und Eliminierung aller verbliebenen Magic Numbers.

## 🛠️ Durchgeführte Änderungen

### 1. _lib.nix (The SRE Engine v3)
- **Option Exhaustion**: Die Helper-Library wurde so erweitert, dass sie nun **alle** sicherheitsrelevanten systemd-Optionen (`ProtectSystem`, `PrivateTmp`, etc.) systemweit für alle Dienste zentral steuert.
- **ABC-Tiering Enforcement**: 
    - **Tier A (NVMe)**: Datenbanken und Configs werden nun explizit via `srePaths.stateDir` gesteuert.
    - **Tier B (SATA SSD)**: Cache-Verzeichnisse (`cacheDir`) wurden für Dienste wie Jellyfin auf die SATA-SSD gemappt.
    - **Tier C (HDD)**: Bibliotheks-Zugriff erfolgt nun ausschließlich über die SSoT-Variable `srePaths.mediaLibrary`.
- **User/Group Alignment**: Erzwingung der GID 169 (media) für alle Verzeichnisse via `systemd.tmpfiles`.

### 2. Sabnzbd (20-SRV-030)
- **Declarative User**: User und Group werden nun explizit über Nix gesteuert, anstatt sich auf Defaults zu verlassen.
- **Performance**: `CPUWeight` auf 100 erhöht, um Entpackvorgänge auf dem i3-9100 zu priorisieren.

### 3. Sonarr & Radarr (20-SRV-032 / 027)
- **Option Alignment**: Vollständige Synchronisation mit dem neuen `_lib` Standard.
- **Path Verification**: Sicherstellung, dass Metadaten (MediaCover) auf der SATA-SSD landen, um die NVMe zu schonen.

## 🧬 Traceability
- **Skill**: Ultra-SRE v2.4 (GitHub-First)
- **Compliance**: NMS v2.3 SRE Standard
- **Status**: Media Stack EXHAUSTED (Aviation Grade).

---
*Status: IMPLEMENTED & TIERED*
