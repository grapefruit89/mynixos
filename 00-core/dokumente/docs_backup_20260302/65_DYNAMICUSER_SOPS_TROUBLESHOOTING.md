---
title: DynamicUser & sops-nix Troubleshooting Guide
project: NMS v2.3
last_updated: 2026-03-02
status: Active Standard
type: Troubleshooting Guide
---

# 🛡️ DYNAMICUSER & SECRETS TROUBLESHOOTING

Dieses Dokument beschreibt Lösungen für Berechtigungskonflikte, die beim Einsatz von `DynamicUser = true` in Kombination mit `sops-nix` auftreten können.

## 🔑 Der n8n Encryption-Key Fall
Nach dem Rollout verweigerte `n8n` den Start mit der Fehlermeldung: `Mismatching encryption keys`.

### Ursache
1.  **Mismatch**: Der in sops-nix hinterlegte Standard-Key ("changeme") passte nicht zum Key in der bestehenden Datenbank.
2.  **Berechtigungen**: Bei `DynamicUser` hat der Dienst keine feste UID. Fragile Konstrukte wie `N8N_ENCRYPTION_KEY_FILE` können zu `EACCES` (Permission Denied) führen, wenn der Service die Datei im sops-Pfad nicht lesen darf.

### Lösung
*   **Key-Extraktion**: Der korrekte Key wurde direkt aus der alten n8n-Config extrahiert (`gCXaCy...`).
*   **Stabile Injection**: Umstellung von Datei-basierter Key-Übergabe auf direkte Umgebungsvariablen in `n8n.nix`. Da die Nix-Datei selbst durch restriktive Dateirechte (`0600`) geschützt ist, bleibt die Sicherheit gewahrt.

## 📂 Best-Practices für DynamicUser
Wenn ein Dienst mit `DynamicUser` auf persistente Daten zugreifen muss:

1.  **StateDirectory**: Nutze immer `serviceConfig.StateDirectory = "appname"`. Systemd sorgt dann automatisch dafür, dass `/var/lib/appname` dem dynamischen User gehört.
2.  **Permissions**: Wenn externe Pfade (wie `/mnt/media`) gelesen werden müssen, füge den DynamicUser der entsprechenden Gruppe hinzu:
    ```nix
    users.groups.media.members = [ "appname" ];
    ```
3.  **sops-nix**: Bei `DynamicUser` ist es oft einfacher, Secrets direkt via `EnvironmentFile` oder Umgebungsvariablen zu übergeben, anstatt sich auf UID-basierte ACLs im sops-Pfad zu verlassen.

---
*Status: DOCUMENTED*
