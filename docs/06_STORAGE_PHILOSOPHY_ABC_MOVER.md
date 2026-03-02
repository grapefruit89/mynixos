---
title: NixOS Homelab Storage Philosophy (ABC & MergerFS)
project: NMS v2.3
last_updated: 2026-03-02
status: Fundamental Design Decision (Enriched)
type: Architecture Rationale
---

# 💾 STORAGE PHILOSOPHY: ABC-TIERING & MERGERFS

## 🛠️ Designentscheidung: Warum ext4 + MergerFS?

Die Wahl fiel nach langen Diskussionen gegen ZFS und für **ext4**, da dies die einzige Konfiguration ist, die einen **zuverlässigen HDD-Spindown** bei minimaler Komplexität garantiert.

### Der "Atomic Move" Trick
Um die HDDs weiter zu entlasten, nutzt das System die **Same-Disk-Staging** Logik:
- Neue Daten werden erst in einem versteckten `.staging/` Ordner auf derselben physischen Platte vorbereitet.
- Der finale "Move" in den MergerFS-Pool ist dadurch eine atomare Metadaten-Operation und kein langwieriger Schreibvorgang.

---

## 📊 Das ABC-Klassifizierungsmodell

| Typ | Hardware | Beschreibung |
|---|---|---|
| **Tier A** | NVMe | "Die Seele": DBs, SSH-Keys, Secrets. Maximale Performance. |
| **Tier B** | SSD | "Die Work-Zone": Downloads, Metadaten-Cache. Schont die HDDs. |
| **Tier C** | HDDs | "Das Datengrab": Große Medienarchive. 99% Spindown Zeit. |

---

## 🚀 Die Smart-Mover Logik (SSD -> HDD)

Das Mover-Script agiert als intelligenter SRE-Agent:
1.  **Vermeidung von Spin-ups**: Es verschiebt nur, wenn die Platte via `hdparm -C` als `active/idle` gemeldet wird.
2.  **SSD-Affinity**: Alle Schreibvorgänge werden durch die `ff` (First Found) Policy von MergerFS auf Tier-B (SSD) gezwungen.
3.  **Kapazitäts-Trigger**: Bei 85% Füllstand der SSD wird eine HDD-Leerung erzwungen, unabhängig vom Power-Status.

> **[NixOS Expert-Einschub: MergerFS Optimierung]**
> Für maximale Stabilität und HDD-Schonung sollten in NixOS folgende Mount-Optionen für MergerFS gesetzt sein:
> - `category.create=ff`: Zwingt Schreibvorgänge strikt auf das erste verfügbare Drive (Tier-B SSD).
> - `minfreespace=50G`: Verhindert, dass eine Disk zu 100% vollläuft (Dateisystem-Overhead).
> - `dropcacheonclose=true`: Hilft dem Kernel, den RAM-Cache schneller freizugeben, was den Spindown-Timer von `hd-idle` begünstigt.

## 🚫 Abgelehnte Pooling-Konzepte
- **RAID (mdadm/ZFS)**: Abgelehnt, da beim Zugriff auf eine Datei *alle* Platten hochdrehen würden.
- **Btrfs-RAID**: Abgelehnt wegen CPU-Overhead und komplexerem Recovery-Weg auf NixOS.
