# 🏁 SRE Audit Report: App Performance & Stability (2026-03-02)

## 📋 Zusammenfassung
Optimierung der Kern-Anwendungen (n8n, Paperless, OliveTin) für das Fujitsu Q958 Profil (i3-9100 / 16GB RAM). Fokus auf Ressourcen-Management und operative Kontrolle.

## 🛠️ Durchgeführte Änderungen

### 1. n8n (20-services/apps/n8n.nix)
- **RAM-Limit**: Node.js Heap-Size auf **2GB** begrenzt (`max-old-space-size=2048`).
- **Concurrency**: Begrenzung auf **5 parallele Produktion-Workflows**, um CPU-Spikes auf dem i3-9100 zu glätten.
- **SSoT**: Explizite Definition der `N8N_NODE_OPTIONS`.

### 2. Paperless-ngx (20-services/apps/paperless.nix)
- **Valkey Integration**: Wechsel vom internen Redis auf den zentralen **Valkey-Cluster (Layer 10)** für stabilere Task-Queues.
- **OCR-Drosselung**: Begrenzung auf **2 Worker** (1 Thread/Worker). Verhindert, dass das System beim Import von Dokumenten einfriert.

### 3. OliveTin (10-infrastructure/olivetin.nix)
- **Operationale Kontrolle**: Neue Schaltfläche für den **Smart Mover Status** hinzugefügt.
- **Transparenz**: Ermöglicht manuelle Überprüfung der HDD/SSD Tiering-Zustände via Web-UI.

## 🧬 Traceability
- **Skill**: Ultra-SRE v2.4 (GitHub-First)
- **Identity**: NIXH-20-SRV-009, NIXH-20-SRV-012, NIXH-10-INF-010
- **Layer**: 10 (Infrastruktur), 20 (Services)

---
*Status: IMPLEMENTED & VERIFIED*
