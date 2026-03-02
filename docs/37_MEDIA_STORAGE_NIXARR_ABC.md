---
title: Nixarr-Style ABC Storage Architecture
project: NMS v2.3
last_updated: 2026-03-02
status: Active Standard
type: Storage Specification
---

# 🏗️ NIXARR-STYLE ABC STORAGE ARCHITECTURE

Dieses Dokument definiert die physische und logische Verteilung von Mediendaten über dein ABC-Tiering, inspiriert durch das **Nixarr**-Projekt.

## 📊 Das Drei-Schichten-Modell (Physikalisch)

| Tier | Hardware | Mount-Pfad | Nutzung |
|---|---|---|---|
| **Tier A** | NVMe | `/data/state` | Datenbanken, Configs, Metadaten-DBs. |
| **Tier B** | SSD | `/mnt/fast-pool` | Aktive Downloads (Usenet/Torrent), Incomplete Files. |
| **Tier C** | HDD | `/mnt/media` | Finale Bibliotheken (Filme, Serien, Musik). |

## 📂 Die logische Verzeichnisstruktur

Um maximale Kompatibilität mit den "Arrs" zu gewährleisten, nutzen wir folgende Struktur:

### ⚡ Tier B (Aktive Zone)
- `/mnt/fast-pool/downloads/torrents/`
- `/mnt/fast-pool/downloads/usenet/`
- `/mnt/fast-pool/downloads/incomplete/`

### 🎞️ Tier C (Bibliotheks-Zone)
- `/mnt/media/movies/`
- `/mnt/media/tv/`
- `/mnt/media/music/`
- `/mnt/media/books/`
- `/mnt/media/podcasts/`

## 🔒 Berechtigungen (SRE Standard)
Alle Medien-Ordner unterliegen der zentralen Gruppe **`media` (GID 169)**.
- **Permissions**: `775` (Besitzer & Gruppe dürfen schreiben).
- **Setgid Bit**: Alle Ordner haben das Setgid-Bit (`chmod g+s`), damit neue Dateien automatisch der Gruppe `media` gehören. Dies verhindert "Permission Denied" Fehler zwischen Sonarr und Jellyfin.

## 🚀 Der "Atomic Move"
Dank **MergerFS** und der `ff` (First Found) Policy landen neue Daten immer zuerst auf der SSD (Tier B). Der **Smart-Mover** verschiebt sie später auf die HDD (Tier C), ohne dass der Pfad für Jellyfin bricht.
