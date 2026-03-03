# 🛰️ NixHome MetaBibliothek (NMS v2.3)
## Code ↔ Docs ↔ Knowledge — Die Isomorphie-Zentrale

Willkommen in der **MetaBibliothek**. Dies ist die Single Source of Truth für das gesamte Wissen deines Fujitsu Q958 Homelabs. Sie vereint deine realen NixOS-Konfigurationen mit dem geistigen Erbe aus über 650 historischen Dokumenten (11.000+ Wissens-Chunks).

---

### 📂 Architektur-Layer (Isomorph zum Repo)

Jeder Ordner hier spiegelt exakt einen Layer in `/etc/nixos/` wider:

*   **[00-core](./00-core/)**: Das Fundament. Sicherheit, Hardware-Profile (Q958), SSoT-Configs und Shell-Premium.
*   **[10-infrastructure](./10-infrastructure/)**: Die Plattform. Caddy Edge Proxy, AdGuard DNS, Pocket-ID (SSO) und PostgreSQL.
*   **[20-automation](./20-automation/)**: Intelligenz & Steuerung. Lokale KI (Ollama/Claude), Home-Assistant und n8n.
*   **[30-media](./30-media/)**: Der Media-Stack. Jellyfin mit HW-Beschleunigung, *arr-Suite und ABC-Tiering Storage.
*   **[40-knowledge](./40-knowledge/)**: Wissensmanagement. Paperless-ngx und RSS-Reader.
*   **[50-apps](./50-apps/)**: Zusätzliche Web-Apps wie Vaultwarden, Monica und Matrix.
*   **[80-analyse](./80-analyse/)**: Observability. Echtzeit-Monitoring mit Netdata und Scrutiny.
*   **[90-policy](./90-policy/)**: Die Leitplanken. Binary-Only Policy und Sicherheits-Assertions.

---

### 🛠️ SRE Standards & Metadaten

Alle Dokumente folgen dem **NMS v2.3 Standard**. Jedes File enthält einen maschinenlesbaren Header:

```yaml
id: "NIXH-LAYER-CAT-NUM"  # Eindeutige Identität
ref.code: "path/to.nix"   # Direkte Verbindung zum echten Code
audit.doc_status: "enriched" # Status der Wissens-Anreicherung
```

---

### 🚀 Schnelleinstieg für Obsidian
*   **[Master Config (SSoT)](./00-core/configs.md)**: Wer bin ich? (IPs, Domains, Quotas)
*   **[Edge Proxy (Caddy)](./10-infrastructure/caddy.md)**: Wer darf rein? (Ingress, Geoblock, SSO)
*   **[Storage Strategy](./00-core/storage.md)**: Wo liegen die Daten? (mergerfs, Tiering)
*   **[Security Policy](./90-policy/security-assertions.md)**: Bin ich sicher? (Automatisierte Compliance)

---
*Generiert am 2026-03-02 — Synthetisiert aus realem Code & historischem Wissen.*
