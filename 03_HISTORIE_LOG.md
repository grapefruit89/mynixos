# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: Chronik der wichtigsten Systemänderungen
#   specIds: [HIS-001]

# 📜 Historie & Änderungen

Zusammenfassung der großen Meilensteine an diesem System.

## 📅 26. Februar 2026 (Großer Cleanup)
- **Problem:** "Commit-Stau" und Berechtigungsfehler in Git.
- **Lösung:** Zusammenführung aller verirrten Branches (`tbexar`, `poi0k1`) in den `main`.
- **Zentralisierung:** Alle harten Werte (IPs, User, etc.) wurden in die `00-core/configs.nix` verschoben.
- **Firewall:** Komplette Migration von Iptables zu **NFTables**.
- **Keyboard:** Deutsche Tastaturbelegung (ISO-DE) für Konsole und GUI wiederhergestellt.
- **Speicher:** Boot-Partition bereinigt, um Platz für neue Kernel zu schaffen.

## 📅 Februar 2023 - 2026 (Initialphasen)
- Umstellung von einfachem NixOS auf Flakes (später wieder zurück zu Standard für einfachere Handhabung).
- Einführung der modularen Struktur (`00-core`, `10-infrastructure`, etc.).
- Absicherung des SSH-Zugangs (Port-Wechsel auf 53844 und IP-Whitelisting).
