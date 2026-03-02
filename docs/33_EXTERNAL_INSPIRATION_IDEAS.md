---
title: NixOS Homelab External Inspiration & Ideas
project: NMS v2.3
last_updated: 2026-03-02
status: Consolidated (NixOS Expert Enriched)
type: Research & Development
---

# 💡 EXTERNAL INSPIRATION & IDEAS

Dieses Dokument listet Best Practices aus führenden Community-Repositories, die als Blaupause für künftige Phasen dienen.

## 🛡️ VPN Confinement (Inspiration: Nixarr)
- **Idee**: Weg vom Killswitch, hin zu Netzwerk-Namespaces.
- **Nutzen**: Dienste sehen physisch nur das VPN-Interface; Leaks werden unmöglich.

## 🚀 Storage Tuning (Inspiration: IronicBadger)
- **MFS Policy**: `category.create=mfs` für gleichmäßige HDD-Abnutzung.
- **VFS-Caching**: Aggressives RAM-Caching von Metadaten, um HDDs im Spindown zu lassen.

> **[NixOS Expert-Einschub: MergerFS vs. Spindown]**
> MergerFS kann den HDD-Spindown stören, wenn Apps (wie Jellyfin) ständig nach neuen Dateien scannen.
> **Lösung**: `cache.readdir=true` und `dropcacheonclose=true` in den MergerFS-Optionen nutzen. Dies hält die Directory-Struktur im RAM-Cache, sodass die Platten für Datei-Auflistungen nicht hochdrehen müssen.

## 📊 Observability (Inspiration: Ryan4yin)
- **Dashboarding**: Deklarative Grafana/Prometheus Dashboards via Nix-Code.

> **[NixOS Expert-Einschub: Self-Hosted Binary Caches]**
> Neben **Cachix** ist **Attic** der neue Standard für 2026. Es lässt sich nativ auf NixOS hosten und nutzt S3 (oder lokalen Storage) als Backend.
> **Vorteil**: Keine 5GB Limits wie beim Free-Tier von Cachix. Ideal, um kompilierte AI-Tools (Kimi/Ollama) zwischen Server und Workstation zu sharen. 
> **Alternative**: `Gachix` nutzt Git-Internals als Backend und kann den Storage-Bedarf für den Cache um bis zu 82% reduzieren.
