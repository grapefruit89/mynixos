---
title: Home Assistant & SLZB-06 SRE Strategy
project: NMS v2.3
last_updated: 2026-03-02
status: Draft (Expert Advice)
type: IoT Architecture
---

# 🏠 HOME ASSISTANT & SLZB-06 (ETHERNET ZIGBEE)

Dein **SLZB-06 (SMLIGHT)** ist ein Ethernet-basierter Zigbee-Koordinator. Das ist die absolute Königsklasse für ein stabiles Homelab, da du keine USB-Passthrough-Probleme hast.

## ❓ Brauchst du MQTT oder Zigbee2MQTT?

Es gibt zwei Wege, deinen Stick einzubinden:

### Weg A: ZHA (Direkt in Home Assistant)
- **Konzept**: HA verbindet sich direkt via LAN mit dem Stick (socket://<IP>:6638).
- **Vorteil**: Extrem einfach, kein MQTT nötig, "One-Stop-Shop" in der UI.
- **Nachteil**: Wenn HA abstürzt oder neu startet, ist dein gesamtes Zigbee-Netz weg.

### Weg B: Zigbee2MQTT + Mosquitto (Aviation Grade) 🚀
- **Konzept**: Ein eigener Dienst (**Zigbee2MQTT**) hält die Verbindung zum Stick und schickt die Daten an einen Broker (**Mosquitto**). HA hört nur am Broker mit.
- **Vorteil**: 
  - **Entkopplung**: Wenn du Home Assistant updatest, bleibt dein Zigbee-Netzwerk online. 
  - **Kompatibilität**: Unterstützt deutlich mehr exotische Geräte als ZHA.
  - **Unix-Philosophie**: Ein Dienst macht eine Sache (Zigbee -> MQTT) perfekt.
- **Urteil**: Für einen "Endgegner-Build" auf NixOS ist **Weg B** der Standard.

---

## 🏗️ ABC-STORAGE MAPPING (NIXARR STYLE)

Wir mappen die "perfekte Ordnerstruktur" von Nixarr auf dein ABC-Tiering:

| Tier | Pfad (Beispiel) | Daten-Typ | NixOS Mount |
|---|---|---|---|
| **Tier A** (NVMe) | `/data/state/jellyfin` | Datenbanken, Metadaten, Thumbnails | `/` (Persistent) |
| **Tier B** (SSD) | `/mnt/fast-pool/downloads` | Aktive Downloads, Incomplete Files | `/mnt/fast-pool` |
| **Tier C** (HDD) | `/mnt/media/movies` | Finale Film-Bibliothek | `/mnt/media` |
| **Tier C** (HDD) | `/mnt/media/tv` | Finale Serien-Bibliothek | `/mnt/media` |

### Der "Atomic Move" Vorteil:
Durch diese Struktur kann der **Smart-Mover** Daten von Tier B nach Tier C schieben, ohne dass Jellyfin den Pfad verliert, da wir via **MergerFS** beide Tiers unter `/mnt/media` bündeln können.
