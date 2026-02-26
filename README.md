# 🚀 Fujitsu Q958 NixOS Homelab

Willkommen in der Konfiguration deines Homelabs. Dieses Repository ist modular aufgebaut, sicherheitsgehärtet und für den Intel i3-9100 optimiert.

## 📚 Dokumentation

Hier findest du alle wichtigen Informationen zum Betrieb und zur Architektur:

*   **[Betriebsanleitung](docs/operations.md)** – Aliase, Workflow und Wartung.
*   **[Architektur & Netzwerk](docs/architecture.md)** – Aufbau der Module und Firewall-Konzept.
*   **[Fehlerbehebung](docs/recovery.md)** – Notfallpläne für SSH und Boot-Probleme.
*   **[Projektstatus](docs/status.md)** – Aktueller Stand und Roadmap.
*   **[Historie](docs/history.md)** – Chronik der wichtigsten Änderungen.

## 🛠️ Schnellstart

Wenn du Änderungen vorgenommen hast:

```bash
ncfg    # Ins Verzeichnis wechseln
ntest   # Änderungen temporär testen
nsw     # Änderungen dauerhaft aktivieren (switch)
ngit    # Git-Status prüfen
```

## 🛡️ Sicherheit

*   **Firewall:** NFTables-only.
*   **SSH:** Gehärtet auf Port 53844.
*   **Secrets:** Verwaltet über `/etc/secrets/homelab-runtime-secrets.env`.

---
*Support: [GitHub Repository](https://github.com/grapefruit89/mynixos)*
